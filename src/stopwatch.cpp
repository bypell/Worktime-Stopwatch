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
    ClassDB::bind_method(D_METHOD("set_check_godot_window_foreground", "check"), &Stopwatch::set_check_godot_window_foreground);
    ClassDB::bind_method(D_METHOD("set_check_other_windows_foreground", "check"), &Stopwatch::set_check_other_windows_foreground);
    ClassDB::bind_method(D_METHOD("set_other_windows_keywords", "titles"), &Stopwatch::set_other_windows_keywords);
}

// Start the stopwatch.
void Stopwatch::start()
{
    if (!is_running)
    {
        is_blocked = false;
        start_time = std::chrono::steady_clock::now();
        is_running = true;
    }
}

// Stop the stopwatch.
void Stopwatch::stop()
{
    if (is_running)
    {
        auto now = std::chrono::steady_clock::now();
        elapsed_time += std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time);
        is_running = false;
    }
}

// Reset the stopwatch.
void Stopwatch::reset()
{
    elapsed_time = std::chrono::milliseconds{0};
    is_running = false;
}

// Get the current time in milliseconds.
uint32_t Stopwatch::get_current_time() const
{
    if (is_running)
    {
        auto now = std::chrono::steady_clock::now();
        auto current_elapsed_time = elapsed_time + std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time);
        return static_cast<uint32_t>(current_elapsed_time.count());
    }
    else
    {
        return static_cast<uint32_t>(elapsed_time.count());
    }
}

// Set the current time in milliseconds.
uint32_t Stopwatch::set_current_time(uint32_t time)
{
    elapsed_time = std::chrono::milliseconds{time};
    return time;
}

// Checks the current window title
void Stopwatch::refresh_check_current_window()
{

    // if both checks are false, return
    if (!check_godot_window_foreground && !check_other_windows_foreground)
    {
        return;
    }

    bool should_block = false;

    // godot window check
    if (check_godot_window_foreground)
    {
        // print to godot console
        UtilityFunctions::print("Checking godot window");

        PackedInt32Array windows = DisplayServer::get_singleton()->get_window_list();
        for (int i = 0; i < windows.size(); i++)
        {
            // check if foreground
            if (DisplayServer::get_singleton()->window_is_focused(windows[i]))
            {
                should_block = false;
                UtilityFunctions::print("decided to not block");
                break;
            }
            else
            {
                should_block = true;
                UtilityFunctions::print("decided to block");
            }
        }
    }

    // other windows check
    std::string title_str = _get_active_window_title();
    if ((should_block || !check_godot_window_foreground) && check_other_windows_foreground)
    {
        UtilityFunctions::print("checking other windows");
        for (int i = 0; i < other_windows_keywords.size(); i++)
        {
            String keyword = other_windows_keywords[i];
            String title = String(title_str.c_str()).to_lower();
            keyword = keyword.to_lower();

            if (title.find(keyword) != -1)
            {
                should_block = false;
                UtilityFunctions::print("decided to not block");
                break;
            }
            else
            {
                should_block = true;
                UtilityFunctions::print("decided to block");
            }
        }
    }

    UtilityFunctions::print("--------------------");

    // apply
    if (should_block)
    {
        if (is_running)
        {
            is_blocked = true;
            stop();
        }
    }
    else
    {
        if (is_blocked)
        {
            is_blocked = false;
            start();
        }
    }
}

// Set the check for the godot window foreground
void Stopwatch::set_check_godot_window_foreground(const bool check)
{
    check_godot_window_foreground = check;
}

// Set the check for the other windows foreground
void Stopwatch::set_check_other_windows_foreground(const bool check)
{
    check_other_windows_foreground = check;
}

// Set the titles of the other windows to check
void Stopwatch::set_other_windows_keywords(const TypedArray<String> &titles)
{
    other_windows_keywords = titles;
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