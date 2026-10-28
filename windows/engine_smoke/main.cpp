#include <chrono>
#include <cstdio>
#include <string>
#include <thread>
#include <vector>

#include "again_audio_engine.h"

namespace {

int g_failures = 0;

void Check(bool condition, const char* message) {
  if (condition) {
    std::printf("  [ok]   %s\n", message);
  } else {
    std::printf("  [FAIL] %s\n", message);
    ++g_failures;
  }
}

again::AudioStatus WaitForReady(again::AudioEngine& engine, int timeout_ms) {  const int step = 25;
  for (int waited = 0; waited < timeout_ms; waited += step) {
    const again::AudioStatus status = engine.status();
    if (!status.loading) {
      return status;
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(step));
  }
  return engine.status();
}

void Print(const char* label, const again::AudioStatus& status) {
  std::printf("  %-18s state=%d loading=%d pos=%lldms dur=%lldms%s%s\n", label,
              status.state, status.loading ? 1 : 0,
              static_cast<long long>(status.position_ms),
              static_cast<long long>(status.duration_ms),
              status.error.empty() ? "" : " error=", status.error.c_str());
}

bool Equals(const std::vector<uint8_t>& actual,
            const std::vector<uint8_t>& expected) {
  return actual == expected;
}

// 声道交换的数值校验 (听感之外唯一能自动验证的部分)。
void RunSwapUnitTests() {
  std::printf("[0] 声道交换字节级校验\n");

  // 16bit 立体声, 2 帧: L1=0x0001 R1=0x0002 / L2=0x0003 R2=0x0004
  {
    std::vector<uint8_t> data = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00};
    const std::vector<uint8_t> expected = {0x02, 0x00, 0x01, 0x00,
                                           0x04, 0x00, 0x03, 0x00};
    again::SwapStereoChannels(data.data(), 2, 4, 2);
    Check(Equals(data, expected), "16bit stereo swapped");
  }

  // 32bit float 立体声 (设备混音格式常见情况), 1 帧: L=1.0f R=2.0f
  {
    std::vector<uint8_t> data = {0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x00, 0x40};
    const std::vector<uint8_t> expected = {0x00, 0x00, 0x00, 0x40,
                                           0x00, 0x00, 0x80, 0x3F};
    again::SwapStereoChannels(data.data(), 1, 8, 2);
    Check(Equals(data, expected), "32bit float stereo swapped");
  }

  // 24bit 立体声, 1 帧
  {
    std::vector<uint8_t> data = {0x11, 0x22, 0x33, 0x44, 0x55, 0x66};
    const std::vector<uint8_t> expected = {0x44, 0x55, 0x66, 0x11, 0x22, 0x33};
    again::SwapStereoChannels(data.data(), 1, 6, 2);
    Check(Equals(data, expected), "24bit stereo swapped");
  }

  // 6 声道 16bit: 只交换前两个声道, 其余不动
  {
    std::vector<uint8_t> data = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    for (int channel = 0; channel < 6; ++channel) {
      data[static_cast<size_t>(channel) * 2] = static_cast<uint8_t>(channel + 1);
    }
    const std::vector<uint8_t> expected = {2, 0, 1, 0, 3, 0, 4, 0, 5, 0, 6, 0};
    again::SwapStereoChannels(data.data(), 1, 12, 6);
    Check(Equals(data, expected), "6ch swaps only L/R");
  }
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    std::printf("usage: engine_smoke <audio file>\n");
    return 1;
  }
  const std::string path = argv[1];
  std::printf("file: %s\n", path.c_str());

  RunSwapUnitTests();
  std::printf("\n");

  again::AudioEngine engine;
  // 静音跑: 只验证解码/输出/进度/seek/声道交换链路, 不发出声音
  // (冒烟测试没有听感判断, 让扬声器响纯属打扰)。
  engine.SetVolume(0.0);
  engine.SetChannelSwap(false);

  std::printf("\n[1] load\n");
  Check(engine.SetSource(path), "setSource accepted");
  again::AudioStatus status = WaitForReady(engine, 10000);
  Print("after load", status);
  Check(!status.loading, "loading finished");
  Check(status.error.empty(), "no load error");
  Check(status.duration_ms > 0, "duration reported");
  if (!status.error.empty()) {
    return 1;
  }

  std::printf("\n[2] play\n");
  engine.Play();
  std::this_thread::sleep_for(std::chrono::milliseconds(700));
  const again::AudioStatus playing = engine.status();
  Print("playing", playing);
  Check(playing.state == again::kPlaying, "state is playing");
  Check(playing.position_ms > 0, "position advanced");

  std::printf("\n[3] channel swap on (播放中切换声道)\n");
  engine.SetChannelSwap(true);
  std::this_thread::sleep_for(std::chrono::milliseconds(700));
  const again::AudioStatus swapped = engine.status();
  Print("swapped", swapped);
  Check(swapped.state == again::kPlaying, "still playing after swap");
  Check(swapped.position_ms > playing.position_ms, "position kept advancing");
  engine.SetChannelSwap(false);

  std::printf("\n[4] seek to middle\n");
  const int64_t middle = status.duration_ms / 2;
  engine.Seek(middle);
  std::this_thread::sleep_for(std::chrono::milliseconds(600));
  const again::AudioStatus seeked = engine.status();
  Print("after seek", seeked);
  Check(seeked.position_ms >= middle - 1500 && seeked.position_ms <= middle + 3000,
        "position near seek target");

  std::printf("\n[5] pause\n");
  engine.Pause();
  std::this_thread::sleep_for(std::chrono::milliseconds(300));
  const again::AudioStatus paused = engine.status();
  Print("paused", paused);
  Check(paused.state == again::kPaused, "state is paused");
  std::this_thread::sleep_for(std::chrono::milliseconds(500));
  const again::AudioStatus paused_later = engine.status();
  Check(paused_later.position_ms - paused.position_ms <= 400,
        "position frozen while paused");

  std::printf("\n[6] resume\n");
  engine.Play();
  std::this_thread::sleep_for(std::chrono::milliseconds(700));
  const again::AudioStatus resumed = engine.status();
  Print("resumed", resumed);
  Check(resumed.state == again::kPlaying, "state is playing again");
  Check(resumed.position_ms > paused_later.position_ms, "position advanced again");

  std::printf("\n[7] play to end (完成回调)\n");
  engine.Seek(status.duration_ms - 1200);
  engine.Play();
  again::AudioStatus finished;
  for (int waited = 0; waited < 8000; waited += 50) {
    finished = engine.status();
    if (finished.state == again::kCompleted) {
      break;
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(50));
  }
  Print("completed", finished);
  Check(finished.state == again::kCompleted, "state is completed at end of file");
  Check(finished.position_ms >= status.duration_ms - 200,
        "position reaches duration");

  std::printf("\n[8] release\n");
  engine.Release();
  const again::AudioStatus released = engine.status();
  Print("released", released);
  Check(released.state == again::kStopped, "state is stopped");

  std::printf("\n%s (%d failure(s))\n", g_failures == 0 ? "PASS" : "FAIL",
              g_failures);
  return g_failures == 0 ? 0 : 1;
}
