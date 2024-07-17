#ifndef FOCUSED_WINDOW_WATCHER_H
#define FOCUSED_WINDOW_WATCHER_H

#ifdef _WIN32
#include <windows.h>
#endif

#include <string>
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/ref.hpp>

namespace godot
{

    class FocusedWindowWatcher : public RefCounted
    {
        GDCLASS(FocusedWindowWatcher, RefCounted)

    protected:
        static void _bind_methods();

    public:
        String get_active_window_title();
    };

}

#endif