#include "again_audio_channel.h"

#include <flutter/standard_method_codec.h>

#include <string>

namespace again {
namespace {

constexpr char kChannelName[] = "again/audio";

const flutter::EncodableValue* MapValue(const flutter::EncodableMap& map,
                                       const char* key) {
  const auto iterator = map.find(flutter::EncodableValue(std::string(key)));
  if (iterator == map.end()) {
    return nullptr;
  }
  return &iterator->second;
}

int64_t IntArgument(const flutter::EncodableMap& map, const char* key,
                    int64_t fallback) {
  const flutter::EncodableValue* value = MapValue(map, key);
  if (value == nullptr) {
    return fallback;
  }
  if (const auto* number = std::get_if<int32_t>(value)) {
    return *number;
  }
  if (const auto* number = std::get_if<int64_t>(value)) {
    return *number;
  }
  if (const auto* number = std::get_if<double>(value)) {
    return static_cast<int64_t>(*number);
  }
  return fallback;
}

double DoubleArgument(const flutter::EncodableMap& map, const char* key,
                      double fallback) {
  const flutter::EncodableValue* value = MapValue(map, key);
  if (value == nullptr) {
    return fallback;
  }
  if (const auto* number = std::get_if<double>(value)) {
    return *number;
  }
  if (const auto* number = std::get_if<int32_t>(value)) {
    return static_cast<double>(*number);
  }
  if (const auto* number = std::get_if<int64_t>(value)) {
    return static_cast<double>(*number);
  }
  return fallback;
}

bool BoolArgument(const flutter::EncodableMap& map, const char* key,
                  bool fallback) {
  const flutter::EncodableValue* value = MapValue(map, key);
  if (value == nullptr) {
    return fallback;
  }
  if (const auto* flag = std::get_if<bool>(value)) {
    return *flag;
  }
  return fallback;
}

std::string StringArgument(const flutter::EncodableMap& map, const char* key) {
  const flutter::EncodableValue* value = MapValue(map, key);
  if (value == nullptr) {
    return std::string();
  }
  if (const auto* text = std::get_if<std::string>(value)) {
    return *text;
  }
  return std::string();
}

flutter::EncodableValue StatusToValue(const AudioStatus& status) {
  flutter::EncodableMap map;
  map[flutter::EncodableValue(std::string("position"))] =
      flutter::EncodableValue(static_cast<int64_t>(status.position_ms));
  map[flutter::EncodableValue(std::string("duration"))] =
      flutter::EncodableValue(static_cast<int64_t>(status.duration_ms));
  map[flutter::EncodableValue(std::string("state"))] =
      flutter::EncodableValue(static_cast<int32_t>(status.state));
  map[flutter::EncodableValue(std::string("loading"))] =
      flutter::EncodableValue(status.loading);
  map[flutter::EncodableValue(std::string("error"))] =
      status.error.empty() ? flutter::EncodableValue()
                           : flutter::EncodableValue(status.error);
  return flutter::EncodableValue(map);
}

}  // namespace

AudioChannel::AudioChannel(flutter::BinaryMessenger* messenger) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, kChannelName,
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) { HandleMethodCall(call, std::move(result)); });
}

AudioChannel::~AudioChannel() = default;

void AudioChannel::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  static const flutter::EncodableMap kEmptyArguments;
  const flutter::EncodableValue* raw_arguments = call.arguments();
  const flutter::EncodableMap* typed_arguments =
      raw_arguments != nullptr
          ? std::get_if<flutter::EncodableMap>(raw_arguments)
          : nullptr;
  const flutter::EncodableMap& arguments =
      typed_arguments != nullptr ? *typed_arguments : kEmptyArguments;

  const std::string& method = call.method_name();

  if (method == "setSource") {
    const bool loaded = engine_.SetSource(StringArgument(arguments, "path"));
    result->Success(flutter::EncodableValue(loaded));
    return;
  }
  if (method == "play") {
    engine_.Play();
    result->Success();
    return;
  }
  if (method == "pause") {
    engine_.Pause();
    result->Success();
    return;
  }
  if (method == "stop") {
    engine_.Stop();
    result->Success();
    return;
  }
  if (method == "release") {
    engine_.Release();
    result->Success();
    return;
  }
  if (method == "seek") {
    engine_.Seek(IntArgument(arguments, "position", 0));
    result->Success();
    return;
  }
  if (method == "setVolume") {
    engine_.SetVolume(DoubleArgument(arguments, "volume", 1.0));
    result->Success();
    return;
  }
  if (method == "setChannelSwap") {
    engine_.SetChannelSwap(BoolArgument(arguments, "swap", false));
    result->Success();
    return;
  }
  if (method == "status") {
    result->Success(StatusToValue(engine_.status()));
    return;
  }

  result->NotImplemented();
}

}  // namespace again
