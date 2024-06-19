@tool
extends ColorRect

var in_progress : bool = false
var skipped : bool = false
var day_number : int = 1
var time := 0
var target_time := 0
var date : Dictionary

@onready var day_number_label : Label = $DayNumberLabel
@onready var time_label : Label = $TimeLabel
@onready var time_difference_label : Label = $TimeDifferenceLabel

@onready var success_color : Color = Color(0.0, 1.0, 0.0)
@onready var failed_color : Color = Color(1.0, 0.0, 0.0)


func _ready() -> void:
	color = get_theme_color("dark_color_1", "Editor")
	
	day_number_label.text = "Day " + str(day_number)
	
	if in_progress:
		time_label.text = "..."
		time_difference_label.hide()
		return
	elif skipped:
		time_label.text = "X"
		time_label.add_theme_color_override("font_color", failed_color)
		time_label.add_theme_font_size_override("font_size", 18)
		time_difference_label.hide()
		return
	
	time_label.text = _format_time(time)
	
	var prefix = ""
	var diff = (time - target_time)
	if diff > 0:
		prefix = "+"
	elif diff < 0:
		prefix = "-"
	time_difference_label.text = prefix + str(_format_time(diff))
	
	if prefix == "+":
		time_difference_label.add_theme_color_override("font_color", success_color)
	elif prefix == "-":
		time_difference_label.add_theme_color_override("font_color", failed_color)


func _format_time(milliseconds : float) -> String:
	var t := abs(milliseconds)
	var total_seconds = int(t) / 1000
	var hours = int(total_seconds / 3600)
	var minutes = int(total_seconds / 60) % 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
