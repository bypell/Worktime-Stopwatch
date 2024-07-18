@tool
extends RefCounted
class_name WorktimeStopwatch


var _start_timestamp := -1.0
var _last_ping_timestamp := -1.0
var _total_elapsed_time := 0.0
var _is_running := false
var _is_blocked := false
var _check_godot_window_foreground := false
var _check_other_windows_foreground := false
var _other_windows_keywords: Array[String]
var _focused_window_watcher: FocusedWindowWatcher


func start():
	if not _is_running:
		var now := Time.get_ticks_msec() 
		_last_ping_timestamp = now
		_is_blocked = false
		_start_timestamp = now
		_is_running = true


func stop():
	if _is_running:
		var now := Time.get_ticks_msec()
		if _start_timestamp < 0.0:
			_start_timestamp = now
		
		_total_elapsed_time += now - _start_timestamp
		_is_running = false


func reset():
	if _is_running:
		stop()
	
	_total_elapsed_time = 0.0
	_is_running = false


func get_current_time() -> float:
	if _is_running:
		var now := Time.get_ticks_msec()
		
		if _start_timestamp < 0.0:
			return _total_elapsed_time
		
		var current_elapsed_time = _total_elapsed_time + (now - _start_timestamp)
		return current_elapsed_time
	else:
		return _total_elapsed_time


func set_current_time(work_time: float):
	var was_running = _is_running
	
	if _is_running:
		stop()
	
	_total_elapsed_time = work_time
	
	if was_running:
		start()


func refresh_check_current_window():
	if not _check_godot_window_foreground and not _check_other_windows_foreground:
		return
	
	var should_block = false
	
	if not _focused_window_watcher:
		_focused_window_watcher = FocusedWindowWatcher.new()
	
	# godot window check
	if _check_godot_window_foreground:
		should_block = not _focused_window_watcher.is_active_window_belonging_to_godot_project_process()
	
	# other windows check
	var title = _focused_window_watcher.get_active_window_title().to_lower()
	if (should_block or not _check_godot_window_foreground) and _check_other_windows_foreground:
		for keyword: String in _other_windows_keywords:
			keyword = keyword.to_lower()
			
			if keyword in title:
				should_block = false
				break
			else:
				should_block = true
	
	if should_block:
		if _is_running:
			_is_blocked = true
			stop()
	else:
		if _is_blocked:
			_is_blocked = false
			start()


func ping():
	var now := Time.get_ticks_msec()
	if _last_ping_timestamp < 0.0:
		_last_ping_timestamp = now
		return
	
	var time_since_last_ping = now - _last_ping_timestamp
	
	_last_ping_timestamp = now
	
	if time_since_last_ping > 30_000:
		_start_timestamp += time_since_last_ping


func set_check_godot_window_foreground(enabled: bool):
	_check_godot_window_foreground = enabled


func set_check_other_windows_foreground(enabled: bool):
	_check_other_windows_foreground = enabled


func set_other_windows_keywords(keywords: Array[String]):
	_other_windows_keywords = keywords
