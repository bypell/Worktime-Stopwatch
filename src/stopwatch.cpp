#include "stopwatch.h"

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void Stopwatch::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("get_current_time"), &Stopwatch::get_current_time);
    ClassDB::bind_method(D_METHOD("set_current_time", "time"), &Stopwatch::set_current_time);
    ClassDB::bind_method(D_METHOD("refresh_check_current_window"), &Stopwatch::refresh_check_current_window);
    ClassDB::bind_method(D_METHOD("start"), &Stopwatch::start);
    ClassDB::bind_method(D_METHOD("stop"), &Stopwatch::stop);
    ClassDB::bind_method(D_METHOD("reset"), &Stopwatch::reset);
    ClassDB::bind_method(D_METHOD("ping"), &Stopwatch::ping);
    ClassDB::bind_method(D_METHOD("set_check_godot_window_foreground", "check"), &Stopwatch::set_check_godot_window_foreground);
    ClassDB::bind_method(D_METHOD("set_check_other_windows_foreground", "check"), &Stopwatch::set_check_other_windows_foreground);
    ClassDB::bind_method(D_METHOD("set_other_windows_keywords", "titles"), &Stopwatch::set_other_windows_keywords);
}

// Start the stopwatch.
void Stopwatch::start()
{
    if (!_is_running)
    {
        _is_blocked = false;
        _start_time = std::chrono::steady_clock::now();
        _is_running = true;
    }
}

// Stop the stopwatch.
void Stopwatch::stop()
{
    if (_is_running)
    {
        auto now = std::chrono::steady_clock::now();

        if (_start_time == std::chrono::steady_clock::time_point())
        {
            _start_time = now;
        }

        _elapsed_time += std::chrono::duration_cast<std::chrono::milliseconds>(now - _start_time);
        _is_running = false;
    }
}

// Stop and reset the stopwatch.
void Stopwatch::reset()
{
    if (_is_running)
    {
        stop();
    }

    _elapsed_time = std::chrono::milliseconds{0};
    _is_running = false;
}

// Get the current time in milliseconds.
uint32_t Stopwatch::get_current_time()
{
    if (_is_running)
    {
        auto now = std::chrono::steady_clock::now();

        if (_start_time == std::chrono::steady_clock::time_point())
        {
            return static_cast<uint32_t>(_elapsed_time.count());
        }

        auto current_elapsed_time = _elapsed_time + std::chrono::duration_cast<std::chrono::milliseconds>(now - _start_time);
        return static_cast<uint32_t>(current_elapsed_time.count());
    }
    else
    {
        return static_cast<uint32_t>(_elapsed_time.count());
    }
}

// Set the current time in milliseconds. Also stops the stopwatch beforehand.
uint32_t Stopwatch::set_current_time(uint32_t time)
{
    if (_is_running)
    {
        stop();
    }

    _elapsed_time = std::chrono::milliseconds{time};
    return time;
}

// Checks the current window title and blocks the stopwatch if necessary
void Stopwatch::refresh_check_current_window()
{

    // if both checks are false, return
    if (!_check_godot_window_foreground && !_check_other_windows_foreground)
    {
        return;
    }

    bool should_block = false;

    // godot window check
    if (_check_godot_window_foreground)
    {
        // UtilityFunctions::print("Checking godot window");

        PackedInt32Array windows = DisplayServer::get_singleton()->get_window_list();
        for (int i = 0; i < windows.size(); i++)
        {
            // check if foreground
            if (DisplayServer::get_singleton()->window_is_focused(windows[i]))
            {
                should_block = false;
                // UtilityFunctions::print("decided to not block");
                break;
            }
            else
            {
                should_block = true;
                // UtilityFunctions::print("decided to block");
            }
        }
    }

    // other windows check
    std::string title_str = _get_active_window_title();
    if ((should_block || !_check_godot_window_foreground) && _check_other_windows_foreground)
    {
        // UtilityFunctions::print("checking other windows");
        for (int i = 0; i < _other_windows_keywords.size(); i++)
        {
            String keyword = _other_windows_keywords[i];
            String title = String(title_str.c_str()).to_lower();
            keyword = keyword.to_lower();

            if (title.find(keyword) != -1)
            {
                should_block = false;
                // UtilityFunctions::print("decided to not block");
                break;
            }
            else
            {
                should_block = true;
                // UtilityFunctions::print("decided to block");
            }
        }
    }

    // UtilityFunctions::print("--------------------");

    // apply
    if (should_block)
    {
        if (_is_running)
        {
            _is_blocked = true;
            stop();
        }
    }
    else
    {
        if (_is_blocked)
        {
            _is_blocked = false;
            start();
        }
    }
}

// Pings the stopwatch (if time between pings is too long, the stopwatch will undo the time elapsed)
// this is to make sure that the stopwatch can realise when the user has put their OS into hibernation and that the start time should not be trusted
void Stopwatch::ping()
{
    if (_last_ping_time == std::chrono::steady_clock::time_point())
    {
        _last_ping_time = std::chrono::steady_clock::now();
        return;
    }

    auto now = std::chrono::steady_clock::now();
    auto time_since_last_ping = std::chrono::duration_cast<std::chrono::milliseconds>(now - _last_ping_time);
    _last_ping_time = now;

    if (time_since_last_ping.count() > 10000)
    {
        _start_time += time_since_last_ping;
    }
}

// Set the check for the godot window foreground
void Stopwatch::set_check_godot_window_foreground(const bool check)
{
    _check_godot_window_foreground = check;
}

// Set the check for the other windows foreground
void Stopwatch::set_check_other_windows_foreground(const bool check)
{
    _check_other_windows_foreground = check;
}

// Set the titles of the other windows to check
void Stopwatch::set_other_windows_keywords(const TypedArray<String> &titles)
{
    _other_windows_keywords = titles;
}

// Function to get the title of the foreground  window
std::string Stopwatch::_get_active_window_title()
{
    HWND hwnd = GetForegroundWindow(); // get handle of currently active window
    HWND topLevelHwnd = GetAncestor(hwnd, GA_ROOT);
    wchar_t wnd_title[256];
    GetWindowTextW(topLevelHwnd, wnd_title, sizeof(wnd_title) / sizeof(wnd_title[0]));

    // Convert wide string to narrow string
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, wnd_title, -1, NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, wnd_title, -1, &strTo[0], size_needed, NULL, NULL);
    return strTo;
}