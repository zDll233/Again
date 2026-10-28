#ifndef RUNNER_AGAIN_AUDIO_CHANNEL_H_
#define RUNNER_AGAIN_AUDIO_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <memory>

#include "again_audio_engine.h"

namespace again {

// 把 `again/audio` MethodChannel 绑定到 [AudioEngine]。
// Dart 侧对应 lib/services/audio/audio_engine.dart。
class AudioChannel {
 public:
  explicit AudioChannel(flutter::BinaryMessenger* messenger);
  ~AudioChannel();

  AudioChannel(const AudioChannel&) = delete;
  AudioChannel& operator=(const AudioChannel&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  AudioEngine engine_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

}  // namespace again

#endif  // RUNNER_AGAIN_AUDIO_CHANNEL_H_
