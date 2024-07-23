@tool
extends ColorRect

var in_progress : bool = false
var skipped : bool = false
var day_number : int = 1
var time := 0
var target_time : int
var date : Dictionary

@onready var day_number_label : Label = $DayNumberLabel
@onready var time_label : Label = $TimeLabel
@onready var time_difference_label : Label = $TimeDifferenceLabel

@onready var success_color : Color = Color(0.0, 1.0, 0.0)
@onready var failed_color : Color = Color(1.0, 0.0, 0.0)


func _ready() -> void:
	color = get_theme_color("dark_color_1", "Editor")
	
	if not date:
		return
	
	_set_tooltip()
	
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
	
	var displayed_diff := float(int(time / 1000) - int(target_time / 1000)) * 1000
	time_difference_label.text = prefix + str(_format_time(displayed_diff))
	
	if prefix == "+":
		time_difference_label.add_theme_color_override("font_color", success_color)
	elif prefix == "-":
		time_difference_label.add_theme_color_override("font_color", failed_color)
	

func _set_tooltip():
	var tooltip_str := ""
	
	var date_str = Time.get_date_string_from_unix_time((Time.get_unix_time_from_datetime_dict(date)))
	
	tooltip_text = "%s%s%s%s%s%s" % [
		date_str,
		"\n\nDay %s:" % str(day_number),
		"\nToday (in progress)" if in_progress else "",
		"\nThis day was skipped \n(project was not opened at all)" if skipped else "",
		("\nMinimum work time: " + _format_time(target_time) if target_time else ""),
		("\nWork time done: " + _format_time(time) if time or target_time else ""),
	]


func _format_time(milliseconds : float) -> String:
	var t := absf(milliseconds)
	var total_seconds = int(t) / 1000
	var hours = total_seconds / 3600
	var minutes = (total_seconds / 60) % 60
	var seconds = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
