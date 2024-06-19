@tool
extends Node

var settings : Object

@onready var focused_godot_check_box: CheckBox = %FocusedGodotCheckBox
@onready var focused_other_check_box: CheckBox = %FocusedOtherCheckBox
@onready var focused_other_text_edit: TextEdit = %FocusedOtherTextEdit
@onready var save_button: Button = %SaveButton
@onready var cancel_button: Button = %CancelButton
@onready var reset_button: Button = %ResetButton


func setup(p_settings: Object):
	settings = p_settings
	_set_ui_to_settings()
	save_button.disabled = true
	cancel_button.disabled = true
	reset_button.disabled = settings.are_settings_default()


func _setting_changed():
	save_button.disabled = false
	cancel_button.disabled = false
	reset_button.disabled = settings.are_settings_default()


func _read_ui_and_save_settings():
	# focused window section
	settings.godot_project_window = focused_godot_check_box.button_pressed
	settings.other_windows = focused_other_check_box.button_pressed
	settings.other_windows_keywords = focused_other_text_edit.text
	
	settings.save()
	
	save_button.disabled = true
	cancel_button.disabled = true
	reset_button.disabled = settings.are_settings_default()


func _set_ui_to_settings():
	# focused window section
	focused_godot_check_box.button_pressed = settings.godot_project_window
	focused_other_check_box.button_pressed = settings.other_windows
	focused_other_text_edit.text = settings.other_windows_keywords
	
	save_button.disabled = true
	cancel_button.disabled = true
	reset_button.disabled = settings.are_settings_default()


func _reset_settings_requested() -> void:
	%ResetConfirmationDialog.popup_centered()


func _reset_settings_accepted() -> void:
	settings.load_default_settings()
	_set_ui_to_settings()
	_read_ui_and_save_settings()
	reset_button.disabled = true
