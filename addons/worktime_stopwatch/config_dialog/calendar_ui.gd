@tool
extends Node

const DayBox := preload("res://addons/worktime_stopwatch/calendar/day_box.tscn")

var starting_date : Dictionary

@onready var days_grid: GridContainer = %DaysGrid


func update_displayed_info(saved_data_instance: Resource):
	#TODO: refactor :D (or not)
	
	starting_date = saved_data_instance.starting_date
	var starting_date_string = Time.get_date_string_from_unix_time((Time.get_unix_time_from_datetime_dict(starting_date)))
	%StartingDateLabel.text = "Starting date: " + starting_date_string
	
	var current_day_data = saved_data_instance.current_day_data
	var previous_days_data = saved_data_instance.previous_days_data
	
	for c in days_grid.get_children():
		days_grid.remove_child(c)
		c.queue_free()
	
	# load previous days boxes (and add skipped day boxes if there's any hole in the data)
	# stops at the last previous day with data
	var last_real_verified_day_number = 0 # last day with actual data before days without data (skipped days)
	if not previous_days_data.is_empty():
		for day_data in previous_days_data:
			var day_box = DayBox.instantiate()
			day_box.day_number = day_data.day_number
			day_box.date = day_data.date
			day_box.time = day_data.work_time
			day_box.target_time = day_data.target_work_time
			
			_add_skipped_days_before_day(day_box, last_real_verified_day_number)
			
			days_grid.add_child(day_box)
			last_real_verified_day_number = day_box.day_number
	
	# load current day box (and pad the front with skipped day boxes, if any)
	if current_day_data:
		var day_box = DayBox.instantiate()
		day_box.day_number = current_day_data.day_number
		day_box.date = current_day_data.date
		day_box.in_progress = true
		
		_add_skipped_days_before_day(day_box, last_real_verified_day_number)
		
		days_grid.add_child(day_box)


# adds day boxes with an 'X' for every day from the last given verified day number to the given day box
func _add_skipped_days_before_day(day_box : Control, last_real_verified_day_number : int):
	var nb_skipped_days: int = (day_box.day_number - last_real_verified_day_number) - 1
	var unix_date_day_box := Time.get_unix_time_from_datetime_dict(day_box.date)
	
	for i in range(nb_skipped_days):
		var skipped_day_box = DayBox.instantiate()
		skipped_day_box.day_number = last_real_verified_day_number + i + 1
		skipped_day_box.skipped = true
		
		# set date
		const seconds_in_a_day := (24 * 60 * 60)
		var unix_date_skipped_day := unix_date_day_box - (seconds_in_a_day * (nb_skipped_days - i))
		var date_dict_skipped_day := Time.get_datetime_dict_from_unix_time(unix_date_skipped_day)
		skipped_day_box.date = date_dict_skipped_day
		
		days_grid.add_child(skipped_day_box)
