extends Object

signal settings_updated

const FILE_PATH := "res://addons/worktime_stopwatch_settings.cfg"

var config : ConfigFile

var godot_project_window: bool
var other_windows: bool
var other_windows_keywords: String


func _init() -> void:
	config = ConfigFile.new()


func load_default_settings():
	godot_project_window = true
	other_windows = true
	other_windows_keywords = \
			 "Blender, Krita, Paint, Aseprite, LMMS, Audacity, FL Studio"


func are_settings_default() -> bool:
	var checks : Array[Callable] = [
		func(): return godot_project_window == true,
		func(): return other_windows == true,
		func(): return other_windows_keywords == \
				"Blender, Krita, Paint, Aseprite, LMMS, Audacity, FL Studio"
	]
	
	for c in checks:
		if not c.call():
			return false
	
	return true


func load_settings() -> int:
	# load the file
	config = ConfigFile.new()
	var err := config.load(FILE_PATH)

	if err != OK:
		return err
	
	# apply the values in the config to the member variables
	godot_project_window = config.get_value("focused_window_behavior", "godot_project_window")
	other_windows = config.get_value("focused_window_behavior", "other_windows")
	other_windows_keywords = config.get_value("focused_window_behavior", "other_windows_keywords")
	
	settings_updated.emit()
	
	return err


func save():
	# we put the values of the member variables in the config file and then save it
	config.set_value("focused_window_behavior", "godot_project_window", godot_project_window)
	config.set_value("focused_window_behavior", "other_windows", other_windows)
	config.set_value("focused_window_behavior", "other_windows_keywords", other_windows_keywords)
	
	config.save(FILE_PATH)
	settings_updated.emit()
