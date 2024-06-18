#include "stopwatch.h"

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Stopwatch::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("get_current_time"), &Stopwatch::get_current_time);
    ClassDB::bind_method(D_METHOD("set_current_time", "time"), &Stopwatch::set_current_time);
    ClassDB::bind_method(D_METHOD("start"), &Stopwatch::start);
    ClassDB::bind_method(D_METHOD("stop"), &Stopwatch::stop);
    ClassDB::bind_method(D_METHOD("reset"), &Stopwatch::reset);
}

Stopwatch::Stopwatch()
{
    // Initialize any variables here.
}

Stopwatch::~Stopwatch()
{
    // Add your cleanup here.
}

void Stopwatch::start()
{
    if (!is_running)
    {
        start_time = std::chrono::steady_clock::now();
        is_running = true;
    }
}

void Stopwatch::stop()
{
    if (is_running)
    {
        auto now = std::chrono::steady_clock::now();
        elapsed_time += std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time);
        is_running = false;
    }
}

void Stopwatch::reset()
{
    elapsed_time = std::chrono::milliseconds{0};
    is_running = false;
}

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

uint32_t Stopwatch::set_current_time(uint32_t time)
{
    elapsed_time = std::chrono::milliseconds{time};
    return time;
}