@tool
extends MarginContainer

signal csv_export_destination_chosen(path: String, delimiter: String)

@onready var save_csv_dialog: FileDialog = %SaveCSVDialog
@onready var csv_export_delimiter_line_edit: LineEdit = %CSVExportDelimiterLineEdit


func _on_export_csv_pressed() -> void:
	save_csv_dialog.popup_centered()


func _on_save_csv_dialog_confirmed() -> void:
	var delimiter := csv_export_delimiter_line_edit.text.strip_edges()
	csv_export_destination_chosen.emit(save_csv_dialog.current_path, delimiter if delimiter.length() == 1 else ",")
