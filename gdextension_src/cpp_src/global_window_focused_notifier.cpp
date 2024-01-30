#include <Windows.h>
#include <iostream>
#include "global_window_focused_notifier.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

static GlobalWindowFocusedNotifier* g_notifier_instance = nullptr;

void GlobalWindowFocusedNotifier::_bind_methods() {
    ClassDB::bind_method(D_METHOD("start_notifying"), &GlobalWindowFocusedNotifier::start_notifying);
    ClassDB::bind_method(D_METHOD("stop_notifying"), &GlobalWindowFocusedNotifier::stop_notifying);

    ADD_SIGNAL(MethodInfo("window_focused", PropertyInfo(Variant::STRING, "window_title")));
}

GlobalWindowFocusedNotifier::GlobalWindowFocusedNotifier() {
    // Initialize any variables here.
    g_notifier_instance = this;
}

GlobalWindowFocusedNotifier::~GlobalWindowFocusedNotifier() {
    // Add your cleanup here.
    g_notifier_instance = nullptr;
}

// Define the event handler
void CALLBACK GlobalWindowFocusedNotifier::HandleWindowEvent(HWINEVENTHOOK hWinEventHook, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD dwEventThread, DWORD dwmsEventTime) {
    if (g_notifier_instance != nullptr && event == EVENT_SYSTEM_FOREGROUND) {
        // Get the window title
        char windowTitle[256];
        GetWindowTextA(hwnd, windowTitle, sizeof(windowTitle));

        // Emit the signal
        g_notifier_instance->emit_signal("window_focused", String(windowTitle));
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