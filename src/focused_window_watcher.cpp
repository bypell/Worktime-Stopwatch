#include "focused_window_watcher.h"

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void FocusedWindowWatcher::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("get_active_window_title"), &FocusedWindowWatcher::get_active_window_title);
    ClassDB::bind_method(D_METHOD("is_active_window_belonging_to_godot_project_process"), &FocusedWindowWatcher::is_active_window_belonging_to_godot_project_process);
}

// Function to check if the foreground window's process id is the same as the current project's process id
bool FocusedWindowWatcher::is_active_window_belonging_to_godot_project_process()
{
    // Windows implementation
#ifdef _WIN32

    DWORD dwForegroundProcessId;
    GetWindowThreadProcessId(GetForegroundWindow(), &dwForegroundProcessId);
    return dwForegroundProcessId == OS::get_singleton()->get_process_id();

#endif
    // Windows implementation end

    return true;
}

// Function to get the title of the foreground window (Windows-only, right now)
String FocusedWindowWatcher::get_active_window_title()
{
    // Windows implementation
#ifdef _WIN32

    HWND hwnd = GetForegroundWindow(); // get handle of currently active window
    HWND topLevelHwnd = GetAncestor(hwnd, GA_ROOT);
    wchar_t wnd_title[256];
    GetWindowTextW(topLevelHwnd, wnd_title, sizeof(wnd_title) / sizeof(wnd_title[0]));

    // Convert wide string to narrow string
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, wnd_title, -1, NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, wnd_title, -1, &strTo[0], size_needed, NULL, NULL);
    return String(strTo.c_str());

#endif
    // Windows implementation end

    return "";
}
