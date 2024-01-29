@tool
extends Resource

const SAVE_DATA_PATH := "res://addons/worktime_stopwatch_saved_data.tres"

@export var starting_date : Dictionary = {}
@export var current_day_data : Resource = null
@export var previous_days_data : Array[Resource] = []


func save_data() -> int:
	return ResourceSaver.save(self, SAVE_DATA_PATH)


static func load_saved_data() -> Resource:
	return load(SAVE_DATA_PATH)


static func verify_saved_data_exists() -> bool:
	return ResourceLoader.exists(SAVE_DATA_PATH)
