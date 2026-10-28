#include "again_audio_engine.h"

#include <cmath>
#include <cstdio>
#include <cstring>

namespace again {
namespace {

// KSDATAFORMAT_SUBTYPE_IEEE_FLOAT (避免额外链接 ksguid.lib)
const GUID kIeeeFloatSubFormat = {0x00000003,
                                  0x0000,
                                  0x0010,
                                  {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}};

// WASAPI 每次需要数据时最多补这么多 (200ms, 100ns 为单位)。
// 缓冲越小, 「左右声道对调」/seek/暂停的生效延迟越低; 200ms 下解码线程
// 每轮只需解出 200ms 音频 (本地文件远快于实时), 不会欠载。
constexpr REFERENCE_TIME kBufferDuration = 2000000;

std::wstring Utf8ToWide(const std::string& value) {
  if (value.empty()) {
    return std::wstring();
  }
  const int length = MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.c_str(),
      static_cast<int>(value.size()), nullptr, 0);
  if (length <= 0) {
    return std::wstring();
  }
  std::wstring wide(static_cast<size_t>(length), L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.c_str(),
                      static_cast<int>(value.size()), wide.data(), length);
  return wide;
}

std::string HexCode(long code) {
  char buffer[32] = {0};
  std::snprintf(buffer, sizeof(buffer), "0x%08lX", static_cast<unsigned long>(code));
  return std::string(buffer);
}

bool IsFloatFormat(const WAVEFORMATEX* format) {
  if (format == nullptr) {
    return false;
  }
  if (format->wFormatTag == WAVE_FORMAT_IEEE_FLOAT) {
    return true;
  }
  if (format->wFormatTag == WAVE_FORMAT_EXTENSIBLE &&
      format->cbSize >=
          sizeof(WAVEFORMATEXTENSIBLE) - sizeof(WAVEFORMATEX)) {
    const auto* extended = reinterpret_cast<const WAVEFORMATEXTENSIBLE*>(format);
    return IsEqualGUID(extended->SubFormat, kIeeeFloatSubFormat) != 0;
  }
  return false;
}

}  // namespace

AudioEngine::AudioEngine() = default;

AudioEngine::~AudioEngine() {
  Release();
}

void SwapStereoChannels(uint8_t* data, int64_t frames, uint16_t block_align,
                        uint16_t channels) {
  if (data == nullptr || frames <= 0 || block_align == 0 || channels < 2) {
    return;
  }
  const size_t sample_bytes =
      static_cast<size_t>(block_align) / static_cast<size_t>(channels);
  if (sample_bytes == 0) {
    return;
  }
  uint8_t* frame = data;
  for (int64_t i = 0; i < frames; ++i) {
    for (size_t byte = 0; byte < sample_bytes; ++byte) {
      const uint8_t temporary = frame[byte];
      frame[byte] = frame[sample_bytes + byte];
      frame[sample_bytes + byte] = temporary;
    }
    frame += block_align;
  }
}

// ---------------------------------------------------------------------------
// 平台线程 API
// ---------------------------------------------------------------------------

bool AudioEngine::SetSource(const std::string& utf8_path) {
  if (utf8_path.empty()) {
    return false;
  }

  StopThread();

  loading_ = true;
  ClearError();
  seek_request_ms_ = -1;
  reopen_requested_ = false;
  playing_ = false;
  state_ = kStopped;
  position_ms_ = 0;
  duration_ms_ = 0;

  // 线程已退出, 这些成员此刻不会被并发访问
  reader_.Reset();
  client_.Reset();
  render_.Reset();
  volume_control_.Reset();
  mix_storage_.clear();
  pending_.clear();
  pending_offset_ = 0;
  eof_ = false;
  device_started_ = false;
  frames_written_ = 0;
  frames_base_ = 0;
  applied_volume_ = -1.0;

  stop_event_ = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (stop_event_ == nullptr) {
    loading_ = false;
    SetError("创建音频停止事件失败");
    return false;
  }

  running_ = true;
  {
    std::lock_guard<std::mutex> lock(thread_mutex_);
    thread_ = std::thread(&AudioEngine::ThreadMain, this, utf8_path);
  }
  return true;
}

void AudioEngine::Play() {
  if (state_.load() == kCompleted) {
    // 播放结束后再按播放: 从头重播
    seek_request_ms_ = 0;
    position_ms_ = 0;
  }
  playing_ = true;
  if (!loading_.load()) {
    state_ = kPlaying;
  }
}

void AudioEngine::Pause() {
  playing_ = false;
  if (state_.load() == kPlaying) {
    state_ = kPaused;
  }
}

void AudioEngine::Stop() {
  playing_ = false;
  state_ = kStopped;
  position_ms_ = 0;
  seek_request_ms_ = 0;
}

void AudioEngine::Release() {
  playing_ = false;
  state_ = kStopped;
  position_ms_ = 0;
  duration_ms_ = 0;
  loading_ = false;
  seek_request_ms_ = -1;
  StopThread();
  reader_.Reset();
  client_.Reset();
  render_.Reset();
  volume_control_.Reset();
  mix_storage_.clear();
  pending_.clear();
  pending_offset_ = 0;
  eof_ = false;
  device_started_ = false;
  frames_written_ = 0;
  frames_base_ = 0;
  applied_volume_ = -1.0;
}

void AudioEngine::Seek(int64_t position_ms) {
  const int64_t duration = duration_ms_.load();
  int64_t target = position_ms < 0 ? 0 : position_ms;
  if (duration > 0 && target > duration) {
    target = duration;
  }
  seek_request_ms_ = target;
  position_ms_ = target;
  if (state_.load() == kCompleted && playing_.load()) {
    state_ = kPlaying;
  }
}

void AudioEngine::SetVolume(double volume) {
  if (volume < 0.0) {
    volume = 0.0;
  }
  if (volume > 1.0) {
    volume = 1.0;
  }
  volume_ = volume;
}

void AudioEngine::SetChannelSwap(bool swap) {
  channel_swap_ = swap;
}

AudioStatus AudioEngine::status() const {
  AudioStatus result;
  result.position_ms = position_ms_.load();
  result.duration_ms = duration_ms_.load();
  result.state = state_.load();
  result.loading = loading_.load();
  {
    std::lock_guard<std::mutex> lock(error_mutex_);
    result.error = error_;
  }
  return result;
}

// ---------------------------------------------------------------------------
// 音频线程
// ---------------------------------------------------------------------------

void AudioEngine::ThreadMain(const std::string& path) {
  CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  const HRESULT mf_result = MFStartup(MF_VERSION, MFSTARTUP_NOSOCKET);

  if (FAILED(mf_result)) {
    SetError("初始化 Media Foundation 失败 (" + HexCode(mf_result) + ")");
  } else {
    std::string error;
    if (!OpenSession(path, &error)) {
      SetError(error);
    } else {
      ClearError();
      loading_ = false;
      state_ = playing_.load() ? kPlaying : kStopped;
      Loop(path);
    }
  }

  loading_ = false;
  CloseSession();
  if (SUCCEEDED(mf_result)) {
    MFShutdown();
  }
  CoUninitialize();
}

bool AudioEngine::OpenSession(const std::string& utf8_path, std::string* error) {
  if (!OpenOutput(error)) {
    return false;
  }
  if (!InitializeOutput(error)) {
    CloseSession();
    return false;
  }
  if (!OpenReader(utf8_path, error)) {
    CloseSession();
    return false;
  }
  return true;
}

bool AudioEngine::OpenOutput(std::string* error) {
  Microsoft::WRL::ComPtr<IMMDeviceEnumerator> enumerator;
  HRESULT hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr,
                                CLSCTX_ALL, IID_PPV_ARGS(&enumerator));
  if (FAILED(hr)) {
    *error = "无法创建音频设备枚举器 (" + HexCode(hr) + ")";
    return false;
  }

  Microsoft::WRL::ComPtr<IMMDevice> device;
  hr = enumerator->GetDefaultAudioEndpoint(eRender, eMultimedia, &device);
  if (FAILED(hr)) {
    *error = "没有可用的音频输出设备 (" + HexCode(hr) + ")";
    return false;
  }

  hr = device->Activate(
      __uuidof(IAudioClient), CLSCTX_ALL, nullptr,
      reinterpret_cast<void**>(client_.ReleaseAndGetAddressOf()));
  if (FAILED(hr) || !client_) {
    *error = "无法激活音频输出设备 (" + HexCode(hr) + ")";
    return false;
  }

  WAVEFORMATEX* mix = nullptr;
  hr = client_->GetMixFormat(&mix);
  if (FAILED(hr) || mix == nullptr) {
    *error = "无法读取设备混音格式 (" + HexCode(hr) + ")";
    return false;
  }

  // 直接采用设备混音格式 (共享模式唯一保证能成功的格式),
  // 解码器侧再把音源转成同样的采样率/声道/采样格式。
  const size_t mix_size = sizeof(WAVEFORMATEX) + mix->cbSize;
  mix_storage_.assign(reinterpret_cast<const uint8_t*>(mix),
                      reinterpret_cast<const uint8_t*>(mix) + mix_size);
  format_ = *mix;
  output_is_float_ = IsFloatFormat(mix);
  CoTaskMemFree(mix);
  return true;
}

bool AudioEngine::InitializeOutput(std::string* error) {
  if (!client_ || mix_storage_.empty()) {
    *error = "音频输出设备尚未初始化";
    return false;
  }

  auto* mix = reinterpret_cast<WAVEFORMATEX*>(mix_storage_.data());
  // 先尝试事件驱动 (延迟最低); 部分虚拟声卡不支持, 回退到定时轮询。
  HRESULT hr = client_->Initialize(
      AUDCLNT_SHAREMODE_SHARED, AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
      kBufferDuration, 0, mix, nullptr);
  if (FAILED(hr)) {
    hr = client_->Initialize(AUDCLNT_SHAREMODE_SHARED, 0, kBufferDuration, 0,
                             mix, nullptr);
  }
  if (FAILED(hr)) {
    *error = "无法初始化音频输出 (" + HexCode(hr) + ")";
    return false;
  }

  hr = client_->GetBufferSize(&buffer_frames_);
  if (FAILED(hr) || buffer_frames_ == 0) {
    *error = "无法读取音频输出缓冲大小 (" + HexCode(hr) + ")";
    return false;
  }

  hr = client_->GetService(IID_PPV_ARGS(render_.ReleaseAndGetAddressOf()));
  if (FAILED(hr) || !render_) {
    *error = "无法获取音频渲染接口 (" + HexCode(hr) + ")";
    return false;
  }

  // 音量控制失败不影响播放 (只是失去应用内音量)
  if (FAILED(client_->GetService(
          IID_PPV_ARGS(volume_control_.ReleaseAndGetAddressOf())))) {
    volume_control_.Reset();
  }

  render_event_ = CreateEventW(nullptr, FALSE, FALSE, nullptr);
  if (render_event_ != nullptr &&
      FAILED(client_->SetEventHandle(render_event_))) {
    CloseHandle(render_event_);
    render_event_ = nullptr;
  }
  return true;
}


bool AudioEngine::OpenReader(const std::string& utf8_path, std::string* error) {
  const std::wstring wide = Utf8ToWide(utf8_path);
  if (wide.empty()) {
    *error = "音频文件路径无法解析";
    return false;
  }

  // Source Reader 从 Windows 8 起会自动插入音频转换器 (重采样/声道转换),
  // 因此这里只需要请求目标格式, 不需要额外的转换属性。
  HRESULT hr = MFCreateSourceReaderFromURL(
      wide.c_str(), nullptr, reader_.ReleaseAndGetAddressOf());
  if (FAILED(hr) || !reader_) {
    *error = "无法打开音频文件 (" + HexCode(hr) + ")";
    return false;
  }

  reader_->SetStreamSelection(static_cast<DWORD>(MF_SOURCE_READER_ALL_STREAMS),
                              FALSE);
  hr = reader_->SetStreamSelection(
      static_cast<DWORD>(MF_SOURCE_READER_FIRST_AUDIO_STREAM), TRUE);
  if (FAILED(hr)) {
    *error = "文件中没有可用的音频流 (" + HexCode(hr) + ")";
    return false;
  }

  // 请求解码成设备混音格式 (采样率/声道/位深一致), 必要时由 MF 重采样。
  Microsoft::WRL::ComPtr<IMFMediaType> type;
  hr = MFCreateMediaType(type.ReleaseAndGetAddressOf());
  if (SUCCEEDED(hr)) {
    type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
    type->SetGUID(MF_MT_SUBTYPE,
                  output_is_float_ ? MFAudioFormat_Float : MFAudioFormat_PCM);
    type->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, format_.nChannels);
    type->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, format_.nSamplesPerSec);
    type->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, format_.wBitsPerSample);
    type->SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, format_.nBlockAlign);
    type->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, format_.nAvgBytesPerSec);
    hr = reader_->SetCurrentMediaType(
        static_cast<DWORD>(MF_SOURCE_READER_FIRST_AUDIO_STREAM), nullptr,
        type.Get());
  }
  if (FAILED(hr)) {
    *error = "无法把音频解码为 PCM (" + HexCode(hr) + ")";
    return false;
  }

  PROPVARIANT property;
  PropVariantInit(&property);
  if (SUCCEEDED(reader_->GetPresentationAttribute(
          static_cast<DWORD>(MF_SOURCE_READER_MEDIASOURCE), MF_PD_DURATION,
          &property)) &&
      property.vt == VT_UI8) {
    duration_ms_ = static_cast<int64_t>(property.uhVal.QuadPart / 10000);
  }
  PropVariantClear(&property);

  return true;
}

void AudioEngine::CloseSession() {
  if (device_started_ && client_) {
    client_->Stop();
  }
  device_started_ = false;

  if (render_event_ != nullptr) {
    CloseHandle(render_event_);
    render_event_ = nullptr;
  }
  volume_control_.Reset();
  render_.Reset();
  client_.Reset();
  reader_.Reset();
  mix_storage_.clear();
  pending_.clear();
  pending_offset_ = 0;
  eof_ = false;
  frames_written_ = 0;
  frames_base_ = 0;
  applied_volume_ = -1.0;
}

void AudioEngine::Loop(const std::string& path) {
  while (running_.load()) {
    if (reopen_requested_.exchange(false)) {
      // 输出设备变更 (插拔耳机/切换默认设备): 以当前进度重建整个会话
      const int64_t resume_ms = position_ms_.load();
      const bool was_playing = playing_.load();
      CloseSession();
      std::string error;
      if (!OpenSession(path, &error)) {
        SetError(error);
        if (stop_event_ != nullptr) {
          WaitForSingleObject(stop_event_, 300);
        }
        reopen_requested_ = true;
        continue;
      }
      ClearError();
      if (resume_ms > 0) {
        HandleSeek(resume_ms);
      }
      playing_ = was_playing;
      state_ = was_playing ? kPlaying : kPaused;
    }

    const int64_t seek_target = seek_request_ms_.exchange(-1);
    if (seek_target >= 0) {
      HandleSeek(seek_target);
    }

    HandleVolume();

    if (!playing_.load()) {
      if (device_started_ && client_) {
        client_->Stop();
        device_started_ = false;
      }
      if (stop_event_ != nullptr) {
        WaitForSingleObject(stop_event_, 20);
      }
      continue;
    }

    if (!client_ || !render_) {
      InvalidateOutput();
      continue;
    }

    if (!device_started_) {
      if (FAILED(client_->Start())) {
        InvalidateOutput();
        continue;
      }
      device_started_ = true;
    }

    if (render_event_ != nullptr) {
      HANDLE handles[2] = {stop_event_, render_event_};
      const DWORD waited = WaitForMultipleObjects(2, handles, FALSE, 10);
      if (waited == WAIT_OBJECT_0) {
        break;
      }
    } else if (stop_event_ != nullptr &&
               WaitForSingleObject(stop_event_, 10) == WAIT_OBJECT_0) {
      break;
    }

    UINT32 padding = 0;
    if (FAILED(client_->GetCurrentPadding(&padding))) {
      InvalidateOutput();
      continue;
    }

    if (eof_ && !HasPendingPcm()) {
      if (padding == 0) {
        CompletePlayback();
      }
      continue;
    }

    const UINT32 available =
        buffer_frames_ > padding ? buffer_frames_ - padding : 0;
    if (available == 0) {
      continue;
    }

    BYTE* data = nullptr;
    if (FAILED(render_->GetBuffer(available, &data)) || data == nullptr) {
      InvalidateOutput();
      continue;
    }

    const int64_t decoded = FillFrames(data, static_cast<int64_t>(available));
    if (decoded > 0) {
      if (channel_swap_.load() && format_.nChannels >= 2) {
        SwapChannels(data, decoded);
      }
      const size_t written = static_cast<size_t>(decoded) * format_.nBlockAlign;
      const size_t total = static_cast<size_t>(available) * format_.nBlockAlign;
      if (written < total) {
        std::memset(data + written, 0, total - written);
      }
      frames_written_ += decoded;
      const int64_t played = frames_base_ + frames_written_ -
                             static_cast<int64_t>(padding + available);
      if (played >= frames_base_) {
        position_ms_ = format_.nSamplesPerSec == 0
                           ? 0
                           : played * 1000 /
                                 static_cast<int64_t>(format_.nSamplesPerSec);
      }
    } else {
      std::memset(data, 0, static_cast<size_t>(available) * format_.nBlockAlign);
    }

    if (FAILED(render_->ReleaseBuffer(available, 0))) {
      InvalidateOutput();
    }
  }
}

void AudioEngine::HandleSeek(int64_t position_ms) {
  if (!reader_) {
    return;
  }

  if (device_started_ && client_) {
    client_->Stop();
    device_started_ = false;
  }
  if (client_) {
    client_->Reset();
  }

  PROPVARIANT property;
  PropVariantInit(&property);
  property.vt = VT_I8;
  property.hVal.QuadPart = position_ms * 10000;  // 100ns
  const HRESULT hr = reader_->SetCurrentPosition(GUID_NULL, property);
  PropVariantClear(&property);
  if (FAILED(hr)) {
    SetError("定位播放位置失败 (" + HexCode(hr) + ")");
    return;
  }

  pending_.clear();
  pending_offset_ = 0;
  eof_ = false;
  frames_base_ = format_.nSamplesPerSec == 0
                     ? 0
                     : position_ms * static_cast<int64_t>(format_.nSamplesPerSec) / 1000;
  frames_written_ = 0;
  position_ms_ = position_ms;
  if (state_.load() == kCompleted) {
    state_ = playing_.load() ? kPlaying : kPaused;
  }
}

void AudioEngine::HandleVolume() {
  if (!volume_control_) {
    return;
  }
  const double target = volume_.load();
  if (std::fabs(target - applied_volume_) < 0.001) {
    return;
  }
  if (SUCCEEDED(volume_control_->SetMasterVolume(
          static_cast<float>(target), nullptr))) {
    applied_volume_ = target;
  }
}

bool AudioEngine::ReadNextSample() {
  if (!reader_) {
    return false;
  }

  DWORD flags = 0;
  Microsoft::WRL::ComPtr<IMFSample> sample;
  const HRESULT hr = reader_->ReadSample(
      static_cast<DWORD>(MF_SOURCE_READER_FIRST_AUDIO_STREAM), 0, nullptr,
      &flags, nullptr, sample.ReleaseAndGetAddressOf());
  if (FAILED(hr)) {
    SetError("解码音频失败 (" + HexCode(hr) + ")");
    eof_ = true;
    return false;
  }
  if ((flags & MF_SOURCE_READERF_ENDOFSTREAM) != 0) {
    eof_ = true;
    return false;
  }
  if (!sample) {
    return true;
  }

  Microsoft::WRL::ComPtr<IMFMediaBuffer> buffer;
  if (FAILED(sample->ConvertToContiguousBuffer(buffer.ReleaseAndGetAddressOf())) ||
      !buffer) {
    return true;
  }

  BYTE* data = nullptr;
  DWORD length = 0;
  if (FAILED(buffer->Lock(&data, nullptr, &length)) || data == nullptr) {
    return true;
  }
  if (length > 0) {
    pending_.assign(data, data + length);
    pending_offset_ = 0;
  }
  buffer->Unlock();
  return true;
}

int64_t AudioEngine::FillFrames(uint8_t* dst, int64_t frames) {
  const size_t frame_bytes = format_.nBlockAlign;
  if (frame_bytes == 0) {
    return 0;
  }

  int64_t filled = 0;
  while (filled < frames) {
    if (!HasPendingPcm()) {
      pending_.clear();
      pending_offset_ = 0;
      if (eof_ || !ReadNextSample() || pending_.empty()) {
        break;
      }
    }
    const int64_t available = static_cast<int64_t>(
        (pending_.size() - pending_offset_) / frame_bytes);
    if (available <= 0) {
      pending_offset_ = pending_.size();
      continue;
    }
    const int64_t wanted = frames - filled;
    const int64_t take = available < wanted ? available : wanted;
    std::memcpy(dst + static_cast<size_t>(filled) * frame_bytes,
                pending_.data() + pending_offset_,
                static_cast<size_t>(take) * frame_bytes);
    pending_offset_ += static_cast<size_t>(take) * frame_bytes;
    filled += take;
  }
  return filled;
}

void AudioEngine::SwapChannels(uint8_t* data, int64_t frames) {
  SwapStereoChannels(data, frames, format_.nBlockAlign, format_.nChannels);
}

void AudioEngine::CompletePlayback() {
  if (device_started_ && client_) {
    client_->Stop();
    device_started_ = false;
  }
  const int64_t duration = duration_ms_.load();
  if (duration > 0) {
    position_ms_ = duration;
  }
  state_ = kCompleted;
  playing_ = false;
}

void AudioEngine::InvalidateOutput() {
  if (device_started_ && client_) {
    client_->Stop();
    device_started_ = false;
  }
  reopen_requested_ = true;
  if (stop_event_ != nullptr) {
    WaitForSingleObject(stop_event_, 100);
  }
}

void AudioEngine::StopThread() {
  std::thread worker;
  {
    std::lock_guard<std::mutex> lock(thread_mutex_);
    if (thread_.joinable()) {
      running_ = false;
      if (stop_event_ != nullptr) {
        SetEvent(stop_event_);
      }
      worker = std::move(thread_);
    }
  }
  if (worker.joinable()) {
    worker.join();
  }
  if (stop_event_ != nullptr) {
    CloseHandle(stop_event_);
    stop_event_ = nullptr;
  }
}

void AudioEngine::SetError(const std::string& error) {
  std::lock_guard<std::mutex> lock(error_mutex_);
  error_ = error;
}

void AudioEngine::ClearError() {
  std::lock_guard<std::mutex> lock(error_mutex_);
  error_.clear();
}

}  // namespace again
