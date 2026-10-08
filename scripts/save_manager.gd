extends Node

const SAVE_PATH := "user://core_reactor_save.json"

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Save file could not be opened.")
		return {}
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	file.close()
	if error != OK or typeof(parser.data) != TYPE_DICTIONARY:
		push_warning("Save file is invalid; starting with a clean reactor.")
		return {}
	return parser.data

func save_game(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save file could not be written.")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true