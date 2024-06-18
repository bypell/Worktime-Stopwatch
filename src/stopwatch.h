#ifndef STOPWATCH_H
#define STOPWATCH_H

#ifdef WIN32
#include <windows.h>
#endif

#include <chrono>

#include <godot_cpp/classes/object.hpp>

namespace godot
{

    class Stopwatch : public Object
    {
        GDCLASS(Stopwatch, Object)

    private:
        std::chrono::steady_clock::time_point start_time;
        std::chrono::milliseconds elapsed_time{0};
        bool is_running = false;

    protected:
        static void _bind_methods();

    public:
        Stopwatch();
        ~Stopwatch();

        void start();
        void stop();
        void reset();
        uint32_t get_current_time() const;
        uint32_t set_current_time(uint32_t time);
    };

}

#endif