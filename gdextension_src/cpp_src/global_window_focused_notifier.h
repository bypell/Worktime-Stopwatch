#ifndef GlobalWindowFocusedNotifier_H
#define GlobalWindowFocusedNotifier_H

#include <godot_cpp/classes/object.hpp>
#include <Windows.h>

namespace godot {

class GlobalWindowFocusedNotifier : public Object {
	GDCLASS(GlobalWindowFocusedNotifier, Object)

private:
	HWINEVENTHOOK windowEventHook;
	static void CALLBACK HandleWindowEvent(HWINEVENTHOOK hWinEventHook, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD dwEventThread, DWORD dwmsEventTime);

protected:
	static void _bind_methods();

public:
	GlobalWindowFocusedNotifier();
	~GlobalWindowFocusedNotifier();
	int start_notifying();
	void stop_notifying();
};

}

#endif