@tool
extends Node

const DAY_BOX = preload("res://addons/worktime_stopwatch/calendar/day_box.tscn")

var starting_date : Dictionary

@onready var days_grid: GridContainer = %DaysGrid


func update_displayed_info(saved_data_instance):
	#TODO: refactor :D (or not)
	
	starting_date = saved_data_instance.starting_date
	var starting_date_string = Time.get_date_string_from_unix_time((Time.get_unix_time_from_datetime_dict(starting_date)))
	%StartingDateLabel.text = "Starting date: " + starting_date_string
	
	var current_day_data = saved_data_instance.current_day_data
	var previous_days_data = saved_data_instance.previous_days_data
	
	for c in days_grid.get_children():
		days_grid.remove_child(c)
		c.queue_free()
	
	var last_real_verified_day_number = 0
	if not previous_days_data.is_empty():
		for day_data in previous_days_data:
			var day_box = DAY_BOX.instantiate()
			day_box.day_number = day_data.day_number
			
			var skipped_days = (day_box.day_number - last_real_verified_day_number) - 1
			for i in range(skipped_days):
				var skipped_day_box = DAY_BOX.instantiate()
				skipped_day_box.day_number = last_real_verified_day_number + i + 1
				skipped_day_box.skipped = true
				days_grid.add_child(skipped_day_box)
			
			day_box.date = day_data.date
			day_box.time = day_data.work_time
			day_box.target_time = day_data.target_work_time
			
			days_grid.add_child(day_box)
			last_real_verified_day_number = day_box.day_number
	
	if current_day_data:
		var day_box = DAY_BOX.instantiate()
		day_box.day_number = current_day_data.day_number
		
		var skipped_days = (day_box.day_number - last_real_verified_day_number) - 1
		for i in range(skipped_days):
			var skipped_day_box = DAY_BOX.instantiate()
			skipped_day_box.day_number = last_real_verified_day_number + i + 1
			skipped_day_box.skipped = true
			days_grid.add_child(skipped_day_box)
		
		day_box.in_progress = true
		days_grid.add_child(day_box)