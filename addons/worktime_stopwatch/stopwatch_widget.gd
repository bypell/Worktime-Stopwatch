@tool
extends CenterContainer

signal settings_menu_opening_requested
signal stopped_stopwatch
signal started_stopwatch
signal reset_stopwatch

enum StopwatchStatuses { RESET, COUNTING, STOPPED }

var stopwatch_status = StopwatchStatuses.RESET
var elapsed_time = 0.0

# theme-related variables
@onready var start_icon = get_theme_icon("MainPlay", "EditorIcons")
@onready var pause_icon = get_theme_icon("Pause", "EditorIcons")
@onready var reset_icon = get_theme_icon("Reload", "EditorIcons")
@onready var target_time_not_reached_color = get_theme_color("warning_color", "Editor")

@onready var current_day_button = %CurrentDayButton
@onready var start_pause_button = %StartPauseButton
@onready var reset_button = %ResetButton
@onready var reset_confirmation_dialog: ConfirmationDialog = %ResetConfirmationDialog

@onready var elapsed_time_label = %ElapsedTimeLabel
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
	if stopwatch_status == StopwatchStatuses.RESET:
		reset_button.disabled = true
	
	# first text update to labels
	_update_elapsed_time_label(elapsed_time)
	
	# connect signal
	current_day_button.pressed.connect(func(): settings_menu_opening_requested.emit())
	

func _process(delta):
	# if counting, add to elapsed_time and update the corresponding label
	if stopwatch_status == StopwatchStatuses.COUNTING:
		elapsed_time += delta
		_update_elapsed_time_label(elapsed_time)


func _start_pause_button_pressed():
	match stopwatch_status:
		StopwatchStatuses.RESET, StopwatchStatuses.STOPPED:
			# if previously stopped or reset, should start counting
			stopwatch_status = StopwatchStatuses.COUNTING
			start_pause_button.icon = pause_icon
			reset_button.disabled = false
			set_process(true)
			started_stopwatch.emit()
		StopwatchStatuses.COUNTING:
			# if previously counting, should pause
			stopwatch_status = StopwatchStatuses.STOPPED
			start_pause_button.icon = start_icon
			reset_button.disabled = false
			set_process(false)
			stopped_stopwatch.emit()


func _reset_button_pressed():
	%ResetConfirmationDialog.popup_centered()


func _reset_accepted():
	stopwatch_status = StopwatchStatuses.RESET
	start_pause_button.icon = start_icon
	reset_button.disabled = true
	set_process(false)
	
	elapsed_time = 0.0
	_update_elapsed_time_label(elapsed_time)
	
	reset_stopwatch.emit()


func _update_elapsed_time_label(new_time : float):
	elapsed_time_label.text = _format_time(elapsed_time)


func _format_time(time : float) -> String:
	var hours = int(time) / 3600
	var minutes = (int(time) % 3600) / 60
	var seconds = int(time) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func update_displayed_info(saved_data_instance):
	if elapsed_time > 0:
		stopwatch_status = StopwatchStatuses.STOPPED
	
	var day_number = saved_data_instance.current_day_data.day_number
	var work_time = saved_data_instance.current_day_data.work_time
	var target_time = saved_data_instance.current_day_data.target_work_time
	
	current_day_button.text = "Day " + str(day_number)
	target_time_label.text = _format_time(float(target_time))
	elapsed_time = work_time
	elapsed_time_label.text = _format_time(float(work_time))
