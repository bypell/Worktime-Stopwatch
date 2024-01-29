#include <Windows.h>
#include <iostream>
#include "global_window_focused_notifier.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GlobalWindowFocusedNotifier::_bind_methods() {
    ClassDB::bind_method(D_METHOD("start_notifying"), &GlobalWindowFocusedNotifier::start_notifying);
    ClassDB::bind_method(D_METHOD("stop_notifying"), &GlobalWindowFocusedNotifier::stop_notifying);

    ADD_SIGNAL(MethodInfo("window_focused", PropertyInfo(Variant::STRING, "window_title"), PropertyInfo(Variant::STRING, "window_exec_path")));
}

GlobalWindowFocusedNotifier::GlobalWindowFocusedNotifier() {
    // Initialize any variables here.
    
}

GlobalWindowFocusedNotifier::~GlobalWindowFocusedNotifier() {
    // Add your cleanup here.
    
}

// Define the event handler
void CALLBACK GlobalWindowFocusedNotifier::HandleWindowEvent(HWINEVENTHOOK hWinEventHook, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD dwEventThread, DWORD dwmsEventTime) {
    if (event == EVENT_SYSTEM_FOREGROUND) {
        // Get the window title
        char windowTitle[256];
        GetWindowTextA(hwnd, windowTitle, sizeof(windowTitle));

        UtilityFunctions::print("Window title: " + String(windowTitle));
        //print executable path for the window
        char path[MAX_PATH];
        GetWindowModuleFileNameA(hwnd, path, sizeof(path));
        UtilityFunctions::print("Window path: " + String(path));

        // Emit the signal
    }
}

int GlobalWindowFocusedNotifier::start_notifying() {
    // Event hook setup
    windowEventHook = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, NULL, HandleWindowEvent, 0, 0, WINEVENT_OUTOFCONTEXT);

    if (windowEventHook == NULL) {
        return 1;
    }
    return 0;
}

void GlobalWindowFocusedNotifier::stop_notifying() {
    // Event hook cleanup
    UnhookWinEvent(windowEventHook);
}
