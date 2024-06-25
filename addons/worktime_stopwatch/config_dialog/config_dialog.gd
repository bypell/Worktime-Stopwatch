@tool
extends Window

@onready var scroll_container : ScrollContainer = %ScrollContainer
@onready var calendar_ui: MarginContainer = %Calendar
@onready var settings_ui: MarginContainer = %Settings


func _ready():
	$TabContainer.current_tab = 0
	
	# theming
	if scroll_container.has_theme_stylebox_override("panel"):
		scroll_container.remove_theme_stylebox_override("panel")
	
	scroll_container.add_theme_stylebox_override("panel", get_theme_stylebox("Background", "EditorStyles"))
	$Panel.color = get_theme_color("base_color", "Editor")


func _notification(what : int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		hide()


func update_displayed_info(saved_data_instance):
	calendar_ui.update_displayed_info(saved_data_instance)


func setup_settings_ui(settings: Object):
	settings_ui.setup(settings)
