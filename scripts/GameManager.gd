extends Node

## Autoload singleton that persists progression and counters.
const SAVE_PATH := "user://gentle_tidy_save.json"

signal satisfaction_points_changed(total: int)
signal diorama_item_unlocked(item_id: String)

var satisfaction_points: int = 0
var unlocked_diorama_items: Array[String] = []
var daily_task_completion_counters: Dictionary = {}


func _ready() -> void:
	load_data()


func add_satisfaction_points(amount: int) -> void:
	satisfaction_points += amount
	emit_signal("satisfaction_points_changed", satisfaction_points)
	save_data()


func unlock_diorama_item(item_id: String) -> bool:
	if item_id in unlocked_diorama_items:
		return false
	unlocked_diorama_items.append(item_id)
	emit_signal("diorama_item_unlocked", item_id)
	save_data()
	return true


func mark_daily_task_completed(task_id: String) -> void:
	daily_task_completion_counters[task_id] = int(daily_task_completion_counters.get(task_id, 0)) + 1
	save_data()


func reset_daily_task_completion_counters() -> void:
	daily_task_completion_counters.clear()
	save_data()


func save_data() -> void:
	var payload := {
		"satisfaction_points": satisfaction_points,
		"unlocked_diorama_items": unlocked_diorama_items,
		"daily_task_completion_counters": daily_task_completion_counters
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Unable to open save file for writing: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(payload))
	file.close()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Unable to open save file for reading: %s" % SAVE_PATH)
		return

	var raw_text := file.get_as_text()
	file.close()

	var decoded = JSON.parse_string(raw_text)
	if typeof(decoded) != TYPE_DICTIONARY:
		push_warning("Save data is invalid JSON dictionary. Resetting save.")
		save_data()
		return

	satisfaction_points = int(decoded.get("satisfaction_points", 0))

	unlocked_diorama_items.clear()
	for item in decoded.get("unlocked_diorama_items", []):
		unlocked_diorama_items.append(str(item))

	var raw_counters = decoded.get("daily_task_completion_counters", {})
	if typeof(raw_counters) == TYPE_DICTIONARY:
		daily_task_completion_counters = raw_counters.duplicate(true)
	else:
		daily_task_completion_counters = {}
