@tool
extends EditorPlugin

const SavedData = preload("res://addons/worktime_stopwatch/save_load/saved_data.gd")
const DayData = preload("res://addons/worktime_stopwatch/calendar/day_data.gd")

const MainWidget := preload("res://addons/worktime_stopwatch/dock/stopwatch_dock.tscn")
const CalendarDialog := preload("res://addons/worktime_stopwatch/calendar_dialog/calendar_dialog.tscn")

var saved_data_instance
var main_widget_instance : Control
var calendar_window_instance : Window


func _enter_tree() -> void:
	# load data
	_load_or_create_saved_data()
	
	# instantiation of dock and windows
	main_widget_instance = MainWidget.instantiate()
	calendar_window_instance = CalendarDialog.instantiate()
	
	# connecting signals
	main_widget_instance.settings_menu_opening_requested.connect(_open_settings_menu)
	main_widget_instance.stopped_stopwatch.connect(_save_current_work_time)
	main_widget_instance.reset_stopwatch.connect(_save_current_work_time)
	main_widget_instance.started_stopwatch.connect(_save_current_work_time)
	
	# adding dock and windows
	EditorInterface.get_base_control().add_child(calendar_window_instance)
	_add_widget_as_dock(main_widget_instance)
	
	# update widget displays with data
	_refresh_stopwatch_widget()
	_refresh_calendar_dialog()


func _exit_tree():
	#window_focused_notifier_instance.stop_notifying()
	_save_current_work_time()
	
	remove_control_from_docks(main_widget_instance)
	main_widget_instance.queue_free()
	calendar_window_instance.queue_free()


func _refresh_stopwatch_widget():
	main_widget_instance.update_displayed_info(saved_data_instance)


func _refresh_calendar_dialog():
	calendar_window_instance.update_displayed_info(saved_data_instance)


func _load_or_create_saved_data():
	var current_date = Time.get_date_dict_from_system()
	if SavedData.verify_saved_data_exists():
		# if data file exists, we load it
		saved_data_instance = SavedData.load_saved_data()
		
		# if the current date inside of the saved data is older than the current date, we update it
		if _is_current_date_newer_than_saved_current_date():
			_switch_to_new_day()
	else:
		# if data file doesn't exist, we create one
		saved_data_instance = SavedData.new()
		saved_data_instance.starting_date = current_date
		
		var current_day_data = DayData.new()
		current_day_data.day_number = 1
		current_day_data.date = current_date
		current_day_data.work_time = 0
		current_day_data.target_work_time = 1200 # TODO: not hardcoded
		
		saved_data_instance.current_day_data = current_day_data


func _add_widget_as_dock(widget_instance):
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, widget_instance)
	
	var tabs = widget_instance.get_parent()
	var vsplit = tabs.get_parent()
	
	await get_tree().process_frame #disgusting
	await get_tree().process_frame #disgusting
	await get_tree().process_frame #still disgusting
	
	if vsplit is VSplitContainer:
		vsplit.split_offset = 405


func _open_settings_menu():
	calendar_window_instance.popup_centered()


# Appends data from the current (outdated) day to previous_days_data
# and initializes data for a new day, including day_number, date, work_time = 0, figuring out target_work_time, etc.
func _switch_to_new_day():
	var current_date = Time.get_date_dict_from_system()
	if saved_data_instance.current_day_data.date == current_date:
		printerr("Tried to switch to a new day but the dates are the same.")
		return
	
	saved_data_instance.previous_days_data.append(saved_data_instance.current_day_data)
	
	var previous_current_day_data = saved_data_instance.current_day_data
	var new_current_day_data = DayData.new()
	
	new_current_day_data.day_number = previous_current_day_data.day_number + _get_days_diff_between_date_dicts(
			saved_data_instance.current_day_data.date,
			current_date
			)
	new_current_day_data.date = current_date
	new_current_day_data.work_time = 0
	new_current_day_data.target_work_time = 1200 # TODO: not hardcoded
	
	saved_data_instance.current_day_data = new_current_day_data
	#saved_data_instance.save_data()


# Saves current progress and if the date is no longer the same, makes the necessary calls to switch to a new day
# TODO: separate both actions into different functions
func _save_current_work_time():
	if not SavedData.verify_saved_data_exists():
		push_warning("Couldn't save current work time. (data file not found)")
		return
	
	saved_data_instance.current_day_data.work_time = main_widget_instance.get_elapsed_time()
	saved_data_instance.save_data()
	
	if _is_current_date_newer_than_saved_current_date():
		_switch_to_new_day()
		_refresh_stopwatch_widget()
		_refresh_calendar_dialog()


# Gets the difference in days between two date dictionaries
func _get_days_diff_between_date_dicts(date_dict_1 : Dictionary, date_dict_2 : Dictionary) -> int:
	var date_1 = Time.get_unix_time_from_datetime_dict(date_dict_1)
	var date_2 = Time.get_unix_time_from_datetime_dict(date_dict_2)
	var delta = (date_2 - date_1)
	return (delta / 60 / 60 / 24)


# Returns whether the current date (in the loaded saved data) is no longer the actual date
func _is_current_date_newer_than_saved_current_date() -> bool:
	return _get_days_diff_between_date_dicts(saved_data_instance.current_day_data.date, Time.get_date_dict_from_system()) > 0
