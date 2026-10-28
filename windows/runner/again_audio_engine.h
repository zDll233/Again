#ifndef RUNNER_AGAIN_AUDIO_ENGINE_H_
#define RUNNER_AGAIN_AUDIO_ENGINE_H_

#include <windows.h>

#include <audioclient.h>
#include <mmdeviceapi.h>
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <wrl/client.h>

#include <atomic>
#include <cstdint>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace again {

// 播放状态, 与 Dart 侧 AudioPlaybackState 一一对应。
enum AudioPlaybackStateCode : int {
  kStopped = 0,
  kPlaying = 1,
  kPaused = 2,
  kCompleted = 3,
};

struct AudioStatus {
  int64_t position_ms = 0;
  int64_t duration_ms = 0;
  int state = kStopped;
  bool loading = false;
  std::string error;
};

// 就地交换一帧 PCM 里前两个声道 (左/右) 的采样 — 左右声道对调的核心。
// 样本宽度按 block_align / channels 推算, 因此 16/24/32bit 整型与 32bit
// 浮点都适用; 多于两个声道时只交换前两个, 其余保持原样。
void SwapStereoChannels(uint8_t* data, int64_t frames, uint16_t block_align,
                        uint16_t channels);

// 最小播放引擎: Media Foundation Source Reader 解码成 PCM,
// WASAPI 共享模式输出; 输出前按需交换前两个声道 (左/右) 的采样。
//
// 之所以不用 audioplayers: 播放中实时对调左右声道必须拿到 PCM 采样,
// 插件只能控制整体音量, 没有声道路由能力。
//
// 线程模型:
// - 所有 COM / MF / WASAPI 调用都发生在内部音频线程上;
// - 平台线程 (Flutter) 只读写原子量 (播放/暂停/音量/声道/seek 请求),
//   以及通过 [status] 取状态快照, 因此不会因为设备初始化卡住 UI。
class AudioEngine {
 public:
  AudioEngine();
  ~AudioEngine();

  AudioEngine(const AudioEngine&) = delete;
  AudioEngine& operator=(const AudioEngine&) = delete;

  // 异步加载音源: 立即返回, 结果通过 status() 的 loading/error 反映。
  bool SetSource(const std::string& utf8_path);
  void Play();
  void Pause();
  void Stop();
  void Release();
  void Seek(int64_t position_ms);
  void SetVolume(double volume);  // 0.0 ~ 1.0
  void SetChannelSwap(bool swap);
  bool channel_swap() const { return channel_swap_.load(); }

  AudioStatus status() const;

 private:
  void ThreadMain(const std::string& path);
  bool OpenSession(const std::string& utf8_path, std::string* error);
  bool OpenOutput(std::string* error);
  bool InitializeOutput(std::string* error);
  bool OpenReader(const std::string& utf8_path, std::string* error);
  void CloseSession();
  void Loop(const std::string& path);
  void HandleSeek(int64_t position_ms);
  void HandleVolume();
  bool ReadNextSample();
  bool HasPendingPcm() const {
    return pending_offset_ < pending_.size();
  }
  int64_t FillFrames(uint8_t* dst, int64_t frames);
  void SwapChannels(uint8_t* data, int64_t frames);
  void CompletePlayback();
  void InvalidateOutput();
  void StopThread();
  void SetError(const std::string& error);
  void ClearError();

  // --- 线程 ---
  std::thread thread_;
  std::mutex thread_mutex_;
  std::atomic<bool> running_{false};
  HANDLE stop_event_ = nullptr;

  // --- 平台线程可写状态 ---
  std::atomic<bool> playing_{false};
  std::atomic<bool> channel_swap_{false};
  std::atomic<double> volume_{1.0};
  std::atomic<int64_t> seek_request_ms_{-1};
  std::atomic<int64_t> position_ms_{0};
  std::atomic<int64_t> duration_ms_{0};
  std::atomic<int> state_{kStopped};
  std::atomic<bool> loading_{false};
  std::atomic<bool> reopen_requested_{false};
  mutable std::mutex error_mutex_;
  std::string error_;

  // --- 仅音频线程访问 ---
  HANDLE render_event_ = nullptr;
  Microsoft::WRL::ComPtr<IMFSourceReader> reader_;
  Microsoft::WRL::ComPtr<IAudioClient> client_;
  Microsoft::WRL::ComPtr<IAudioRenderClient> render_;
  Microsoft::WRL::ComPtr<ISimpleAudioVolume> volume_control_;
  WAVEFORMATEX format_{};
  std::vector<uint8_t> mix_storage_;  // 设备混音格式原始字节 (Initialize 用)
  UINT32 buffer_frames_ = 0;
  bool output_is_float_ = false;
  bool device_started_ = false;
  bool eof_ = false;
  int64_t frames_written_ = 0;  // 自上次 seek 起写入设备的数据帧数
  int64_t frames_base_ = 0;     // seek 基准 (数据帧)
  std::vector<uint8_t> pending_;
  size_t pending_offset_ = 0;
  double applied_volume_ = -1.0;
};

}  // namespace again

#endif  // RUNNER_AGAIN_AUDIO_ENGINE_H_
