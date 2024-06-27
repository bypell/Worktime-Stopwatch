#ifndef STOPWATCH_H
#define STOPWATCH_H

#ifdef _WIN32
#include <windows.h>
#endif

#include <chrono>
#include <string>
#include <godot_cpp/classes/object.hpp>

namespace godot
{

    class Stopwatch : public Object
    {
        GDCLASS(Stopwatch, Object)

    private:
        std::string _get_active_window_title();
        std::chrono::steady_clock::time_point _start_time;
        std::chrono::steady_clock::time_point _last_ping_time;
        std::chrono::milliseconds _elapsed_time{0};
        bool _is_running = false;
        bool _is_blocked = false;
        bool _check_godot_window_foreground = false;
        bool _check_other_windows_foreground = false;
        TypedArray<String> _other_windows_keywords;

    protected:
        static void _bind_methods();

    public:
        void start();
        void stop();
        void reset();
        void ping();
        uint32_t get_current_time();
        uint32_t set_current_time(const uint32_t time);
        void refresh_check_current_window();
        void set_check_godot_window_foreground(const bool check);
        void set_check_other_windows_foreground(const bool check);
        void set_other_windows_keywords(const TypedArray<String> &titles);
    };

}

#endif