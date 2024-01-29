@tool
extends EditorPlugin

const SavedData = preload("res://addons/worktime_stopwatch/save_load/saved_data.gd")
const DayData = preload("res://addons/worktime_stopwatch/calendar/day_data.gd")

const MainWidget := preload("res://addons/worktime_stopwatch/stopwatch_widget.tscn")
const SettingsDialog := preload("res://addons/worktime_stopwatch/settings_dialog.tscn")

var saved_data_instance
var main_widget_instance : Control
var settings_dialog_instance : Window

#toremove
@onready var fwn : GlobalWindowFocusedNotifier

func _enter_tree() -> void:
	fwn = GlobalWindowFocusedNotifier.new()
	fwn.start_notifying()
	
	
	
	# load data
	_prepare_data_for_use()
	
	# instantiation
	main_widget_instance = MainWidget.instantiate()
	settings_dialog_instance = SettingsDialog.instantiate()
	
	# injecting data
	settings_dialog_instance.starting_date = saved_data_instance.starting_date
	main_widget_instance.elapsed_time = saved_data_instance.current_day_data.work_time
	if main_widget_instance.elapsed_time > 0:
		main_widget_instance.stopwatch_status = main_widget_instance.StopwatchStatuses.STOPPED
	
	# signals
	main_widget_instance.settings_menu_opening_requested.connect(_open_settings_menu)
	main_widget_instance.stopped_stopwatch.connect(_save_current_work_time)
	main_widget_instance.started_stopwatch.connect(_save_current_work_time)
	
	# adding widget
	EditorInterface.get_base_control().add_child(settings_dialog_instance)
	_add_widget_as_dock(main_widget_instance)
	
	# update widget displays with data
	_update_main_widget_with_current_day_data()
	_update_calendar_dialog()
	settings_dialog_instance.refresh_starting_date_text()


func _exit_tree():
	fwn.stop_notifying()#todelete
	_save_current_work_time()
	
	remove_control_from_docks(main_widget_instance)
	main_widget_instance.queue_free()
	settings_dialog_instance.queue_free()


func _update_main_widget_with_current_day_data():
	var day_number = saved_data_instance.current_day_data.day_number
	var work_time = saved_data_instance.current_day_data.work_time
	var target_time = saved_data_instance.current_day_data.target_work_time
	
	main_widget_instance.update_displayed_info(day_number, target_time, work_time)


func _update_calendar_dialog():
	settings_dialog_instance.update_displayed_info(saved_data_instance.current_day_data, saved_data_instance.previous_days_data)


func _prepare_data_for_use():
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
		saved_data_instance.save_data()


func _add_widget_as_dock(widget_instance):
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, widget_instance)
	
	var tabs = widget_instance.get_parent()
	var vsplit = tabs.get_parent()
	if vsplit is VSplitContainer:
		vsplit.split_offset = 405


func _open_settings_menu():
	settings_dialog_instance.popup_centered()


func _switch_to_new_day():
	var current_date = Time.get_date_dict_from_system()
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
	saved_data_instance.save_data()


func _save_current_work_time():
	if not SavedData.verify_saved_data_exists():
		return
	
	saved_data_instance.current_day_data.work_time = main_widget_instance.elapsed_time
	saved_data_instance.save_data()
	
	if _is_current_date_newer_than_saved_current_date():
		_switch_to_new_day()
		_update_main_widget_with_current_day_data()
		_update_calendar_dialog()


func _get_days_diff_between_date_dicts(date_dict_1 : Dictionary, date_dict_2 : Dictionary) -> int:
	var date_1 = Time.get_unix_time_from_datetime_dict(date_dict_1)
	var date_2 = Time.get_unix_time_from_datetime_dict(date_dict_2)
	var delta = (date_2 - date_1)
	return (delta / 60 / 60 / 24)


func _is_current_date_newer_than_saved_current_date() -> bool:
	return _get_days_diff_between_date_dicts(saved_data_instance.current_day_data.date, Time.get_date_dict_from_system()) > 0
