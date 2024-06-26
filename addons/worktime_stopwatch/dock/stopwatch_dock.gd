@tool
extends CenterContainer

signal settings_menu_opening_requested
signal stopped_stopwatch
signal started_stopwatch
signal reset_stopwatch

enum StopwatchStatuses { RESET, COUNTING, STOPPED }

const REFRESH_CHECK_WINDOW_DELAY := 1.0

var _stopwatch_status = StopwatchStatuses.RESET
var _refresh_check_window_cooldown := REFRESH_CHECK_WINDOW_DELAY

# stopwatch
@onready var _stopwatch := Stopwatch.new()

# theme-related variables
@onready var start_icon = get_theme_icon("MainPlay", "EditorIcons")
@onready var pause_icon = get_theme_icon("Pause", "EditorIcons")
@onready var reset_icon = get_theme_icon("Reload", "EditorIcons")
@onready var target_time_not_reached_color = get_theme_color("warning_color", "Editor")

@onready var current_day_button = %CurrentDayButton
@onready var start_pause_button = %StartPauseButton
@onready var reset_button = %ResetButton
@onready var reset_confirmation_dialog: ConfirmationDialog = %ResetConfirmationDialog

@onready var elapsed_time_label = %CurrentWorkTimeLabel
@onready var target_time_label = %TargetTimeLabel


func _ready():
	# apply icons
	start_pause_button.icon = start_icon
	reset_button.icon = reset_icon
	target_time_label.add_theme_color_override("font_color", target_time_not_reached_color)
	
	# connect signals
	start_pause_button.pressed.connect(_start_pause_button_pressed)
	reset_button.pressed.connect(_reset_button_pressed)
	reset_confirmation_dialog.confirmed.connect(_reset_accepted)
	
	
	# disable the reset button
	if _stopwatch_status == StopwatchStatuses.RESET:
		reset_button.disabled = true
	
	# first text update to labels
	_refresh_elapsed_time_label()
	
	# connect signal
	current_day_button.pressed.connect(func(): settings_menu_opening_requested.emit())


func _process(delta):
	# refresh
	_refresh_check_window_cooldown -= delta
	if _refresh_check_window_cooldown <= 0.0:
		_stopwatch.refresh_check_current_window()
		_stopwatch.ping()
		_refresh_check_window_cooldown = REFRESH_CHECK_WINDOW_DELAY
		
		if Input.is_key_pressed(KEY_0):
			_stopwatch.set_current_time(_stopwatch.get_current_time() + 60000)
	
	# if counting and not blocked, add to _elapsed_time and update the corresponding label
	if _stopwatch_status == StopwatchStatuses.COUNTING:
		_refresh_elapsed_time_label()


func _start_pause_button_pressed():
	match _stopwatch_status:
		StopwatchStatuses.RESET, StopwatchStatuses.STOPPED:
			# if previously stopped or reset, should start counting
			_stopwatch_status = StopwatchStatuses.COUNTING
			start_pause_button.icon = pause_icon
			reset_button.disabled = false
			started_stopwatch.emit()
			_stopwatch.start()
		StopwatchStatuses.COUNTING:
			# if previously counting, should pause
			_stopwatch_status = StopwatchStatuses.STOPPED
			start_pause_button.icon = start_icon
			reset_button.disabled = false
			stopped_stopwatch.emit()
			_stopwatch.stop()


func _reset_button_pressed():
	%ResetConfirmationDialog.popup_centered()


func _reset_accepted():
	_stopwatch_status = StopwatchStatuses.RESET
	start_pause_button.icon = start_icon
	reset_button.disabled = true
	set_process(false)
	
	_stopwatch.reset()
	_refresh_elapsed_time_label()
	
	reset_stopwatch.emit()


func _refresh_elapsed_time_label():
	elapsed_time_label.text = _format_time(_stopwatch.get_current_time())


func _format_time(milliseconds : float) -> String:
	var total_seconds = int(milliseconds) / 1000
	var hours = int(total_seconds / 3600)
	var minutes = int(total_seconds / 60) % 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


# Updates the info displayed in the dock using the given saved data and the stopwatch's current state
func update_displayed_info(saved_data_instance):
	var day_number = saved_data_instance.current_day_data.day_number
	var work_time = saved_data_instance.current_day_data.work_time
	var target_time = saved_data_instance.current_day_data.target_work_time
	
	current_day_button.text = "Day " + str(day_number)
	target_time_label.text = _format_time(float(target_time))
	_stopwatch.set_current_time(work_time)
	elapsed_time_label.text = _format_time(float(work_time))
	
	if _stopwatch.get_current_time() > 0.0:
		_stopwatch_status = StopwatchStatuses.STOPPED
		reset_button.disabled = false


func get_elapsed_time():
	return _stopwatch.get_current_time()


func settings_updated(settings: Object):
	_stopwatch.set_check_godot_window_foreground(settings.godot_project_window)
	_stopwatch.set_check_other_windows_foreground(settings.other_windows)
	
	var keywords: Array[String] = []
	for k in settings.other_windows_keywords.split(",", false):
		keywords.append(k.strip_edges())
	
	_stopwatch.set_other_windows_keywords(keywords)
