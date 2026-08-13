#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter_windows.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // single instance
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Again");
  if (hwnd != NULL) {    
	  ::ShowWindow(hwnd, SW_NORMAL);    
	  ::SetForegroundWindow(hwnd);    
	  return EXIT_FAILURE;  
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // Create the window centered on the primary monitor. Avoids landing on
  // Parsec virtual displays with a different DPI, which breaks the engine's
  // initial DPI and makes window size/content misplaced.
  // Note: Create() scales origin/size by the monitor DPI, so compute the
  // origin in logical coords such that the scaled (physical) window is
  // centered on the primary monitor.
  HMONITOR primary = ::MonitorFromPoint({0, 0}, MONITOR_DEFAULTTOPRIMARY);
  const int dpi = static_cast<int>(FlutterDesktopGetDpiForMonitor(primary));
  const int phys_w = 1280 * dpi / 96;
  const int phys_h = 720 * dpi / 96;
  // Integer math: origin in logical coords such that Create()'s scaling
  // (by dpi/96) lands the physical window centered on the primary monitor.
  Win32Window::Point origin(
      (::GetSystemMetrics(SM_CXSCREEN) - phys_w) * 96 / dpi / 2,
      (::GetSystemMetrics(SM_CYSCREEN) - phys_h) * 96 / dpi / 2);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Again", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
