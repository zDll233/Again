cmake_minimum_required(VERSION 3.20)
project(engine_smoke LANGUAGES CXX)

# 自研播放引擎的独立冒烟测试 (不参与 Flutter 构建):
#   cmake -S windows/engine_smoke -B build/engine_smoke -G "Visual Studio 17 2022" -A x64
#   cmake --build build/engine_smoke --config Release
#   build/engine_smoke/Release/engine_smoke.exe <音频文件>
# 验证解码/输出/进度/seek/暂停/声道对调等基本链路, 无法验证听感。

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(engine_smoke
  "main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/../runner/again_audio_engine.cpp"
)

target_include_directories(engine_smoke PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../runner")
target_compile_options(engine_smoke PRIVATE /W3 /utf-8 /EHsc)
target_compile_definitions(engine_smoke PRIVATE "NOMINMAX")
target_link_libraries(engine_smoke PRIVATE mfplat mfreadwrite mfuuid ole32 propsys)
