extends Node

## Autoload singleton that persists progression, unlocked diorama items, zen tasks, and settings.
const SAVE_PATH := "user://gentle_tidy_save.json"

signal satisfaction_points_changed(total: int)
signal points_added(amount: int)
signal diorama_item_unlocked(item_id: String)
signal task_completed(task_id: String)
signal combo_updated(combo: int)
signal settings_changed()

var satisfaction_points: int = 0
var unlocked_diorama_items: Array[String] = []
var daily_task_completion_counters: Dictionary = {}
var claimed_tasks: Array[String] = []

# Stats
var total_bubbles_popped: int = 0
var total_sheets_cleared: int = 0
var total_surfaces_cleaned: int = 0
var total_breath_cycles: int = 0
var current_combo: int = 0

# Settings
var sfx_enabled: bool = true
var ambience_enabled: bool = true
var haptics_enabled: bool = true

# Catalog of Collectible Cozy Items for the Diorama Room
const DIORAMA_CATALOG: Array[Dictionary] = [
	{
		"id": "succulent_plant",
		"name": "Cozy Succulent",
		"description": "A plump little jade succulent that brings quiet green calm.",
		"cost": 50,
		"color": "#76A07E",
		"category": "Plants"
	},
	{
		"id": "aromatherapy_candle",
		"name": "Lavender Candle",
		"description": "A gentle flame releasing calming lavender scent into the air.",
		"cost": 80,
		"color": "#E6AF82",
		"category": "Warmth"
	},
	{
		"id": "cozy_tea_cup",
		"name": "Chamomile Tea",
		"description": "A steaming ceramic mug of soothing herbal tea with honey.",
		"cost": 120,
		"color": "#E2C391",
		"category": "Comfort"
	},
	{
		"id": "sleeping_cat",
		"name": "Mochi the Cat",
		"description": "A curled-up soft kitten whose rhythmic purrs melt away stress.",
		"cost": 200,
		"color": "#D9C3B0",
		"category": "Friends"
	},
	{
		"id": "fairy_lights",
		"name": "Warm Fairy Lights",
		"description": "Soft glowing string lights casting a dreamy golden radiance.",
		"cost": 250,
		"color": "#F3D27C",
		"category": "Lighting"
	},
	{
		"id": "stack_of_books",
		"name": "Quiet Novels",
		"description": "A peaceful stack of comforting stories with a silk bookmark.",
		"cost": 300,
		"color": "#A680B8",
		"category": "Comfort"
	},
	{
		"id": "bonsai_tree",
		"name": "Zen Juniper",
		"description": "A miniature sculpted tree that anchors the mind in the present.",
		"cost": 400,
		"color": "#588157",
		"category": "Plants"
	},
	{
		"id": "record_player",
		"name": "Vintage Turntable",
		"description": "Spins warm vinyl grooves playing soft lo-fi chillout beats.",
		"cost": 500,
		"color": "#BD7B55",
		"category": "Sound"
	},
	{
		"id": "warm_floor_lamp",
		"name": "Amber Floor Lamp",
		"description": "A minimalist brass floor lamp illuminating peaceful evenings.",
		"cost": 650,
		"color": "#E0A96D",
		"category": "Lighting"
	},
	{
		"id": "plush_cushion",
		"name": "Velvet Beanbag",
		"description": "An irresistibly squishy cushion made for deep relaxation.",
		"cost": 800,
		"color": "#84A98C",
		"category": "Comfort"
	},
	{
		"id": "crystal_geode",
		"name": "Amethyst Cluster",
		"description": "A deep purple healing crystal radiating serene vibrations.",
		"cost": 1000,
		"color": "#9B5DE5",
		"category": "Decor"
	},
	{
		"id": "herbal_terrarium",
		"name": "Mossy Terrarium",
		"description": "A glass bell dome sheltering living green moss and tiny mushrooms.",
		"cost": 1250,
		"color": "#4895EF",
		"category": "Plants"
	}
]

# Daily Mindful Tasks
const DAILY_TASKS: Array[Dictionary] = [
	{
		"id": "pop_25",
		"title": "Mindful Pop",
		"description": "Pop 25 bubbles in the tactile sheet",
		"goal": 25,
		"reward": 50
	},
	{
		"id": "pop_100",
		"title": "Bubble Zen",
		"description": "Pop 100 bubbles total",
		"goal": 100,
		"reward": 100
	},
	{
		"id": "clear_sheet",
		"title": "Clean Slate",
		"description": "Completely clear an entire bubble sheet",
		"goal": 1,
		"reward": 75
	},
	{
		"id": "wipe_surface",
		"title": "Gentle Polish",
		"description": "Wipe a dusty surface until 100% sparkling clean",
		"goal": 1,
		"reward": 75
	},
	{
		"id": "breathe_2",
		"title": "Calm Breath",
		"description": "Complete 2 mindful breathing cycles",
		"goal": 2,
		"reward": 100
	},
	{
		"id": "unlock_item",
		"title": "Cozy Space",
		"description": "Unlock a cozy decoration for your room",
		"goal": 1,
		"reward": 120
	}
]


func _ready() -> void:
	load_data()


func add_satisfaction_points(amount: int) -> void:
	if amount <= 0:
		return
	satisfaction_points += amount
	satisfaction_points_changed.emit(satisfaction_points)
	points_added.emit(amount)
	save_data()


func can_afford(cost: int) -> bool:
	return satisfaction_points >= cost


func spend_satisfaction_points(amount: int) -> bool:
	if amount <= 0:
		return false
	if satisfaction_points < amount:
		return false
	satisfaction_points -= amount
	satisfaction_points_changed.emit(satisfaction_points)
	save_data()
	return true


func unlock_diorama_item(item_id: String) -> bool:
	if item_id in unlocked_diorama_items:
		return false
	unlocked_diorama_items.append(item_id)
	diorama_item_unlocked.emit(item_id)
	increment_task_progress("unlock_item", 1)
	save_data()
	return true


func unlock_item_with_points(item_id: String) -> bool:
	if is_item_unlocked(item_id):
		return false
	var info := get_item_info(item_id)
	if info.is_empty():
		return false
	var cost: int = int(info.get("cost", 999999))
	if not spend_satisfaction_points(cost):
		return false
	return unlock_diorama_item(item_id)


func is_item_unlocked(item_id: String) -> bool:
	return item_id in unlocked_diorama_items


func get_item_info(item_id: String) -> Dictionary:
	for item in DIORAMA_CATALOG:
		if str(item.get("id", "")) == item_id:
			return item
	return {}


func get_all_items() -> Array[Dictionary]:
	return DIORAMA_CATALOG


func get_all_tasks() -> Array[Dictionary]:
	return DAILY_TASKS


func mark_daily_task_completed(task_id: String) -> void:
	daily_task_completion_counters[task_id] = int(daily_task_completion_counters.get(task_id, 0)) + 1
	save_data()


func increment_task_progress(task_id: String, amount: int = 1) -> void:
	var current: int = int(daily_task_completion_counters.get(task_id, 0))
	daily_task_completion_counters[task_id] = current + amount
	var task := _find_task(task_id)
	if not task.is_empty():
		var goal: int = int(task.get("goal", 1))
		if current < goal and (current + amount) >= goal:
			task_completed.emit(task_id)
	save_data()


func get_task_progress(task_id: String) -> int:
	return int(daily_task_completion_counters.get(task_id, 0))


func is_task_claimable(task_id: String) -> bool:
	if is_task_claimed(task_id):
		return false
	var task := _find_task(task_id)
	if task.is_empty():
		return false
	var goal: int = int(task.get("goal", 1))
	return get_task_progress(task_id) >= goal


func is_task_claimed(task_id: String) -> bool:
	return task_id in claimed_tasks


func claim_task_reward(task_id: String) -> bool:
	if not is_task_claimable(task_id):
		return false
	var task := _find_task(task_id)
	if task.is_empty():
		return false
	claimed_tasks.append(task_id)
	var reward: int = int(task.get("reward", 0))
	add_satisfaction_points(reward)
	save_data()
	return true


func _find_task(task_id: String) -> Dictionary:
	for t in DAILY_TASKS:
		if str(t.get("id", "")) == task_id:
			return t
	return {}


func record_bubble_pop() -> void:
	total_bubbles_popped += 1
	increment_task_progress("pop_25", 1)
	increment_task_progress("pop_100", 1)


func record_sheet_cleared() -> void:
	total_sheets_cleared += 1
	increment_task_progress("clear_sheet", 1)
	add_satisfaction_points(15) # Bonus for full clear


func record_surface_cleaned() -> void:
	total_surfaces_cleaned += 1
	increment_task_progress("wipe_surface", 1)
	add_satisfaction_points(20) # Bonus for 100% clean


func record_breath_cycle() -> void:
	total_breath_cycles += 1
	increment_task_progress("breathe_2", 1)
	add_satisfaction_points(10) # Bonus for mindful breath


func set_combo(combo: int) -> void:
	current_combo = combo
	combo_updated.emit(current_combo)


func reset_daily_task_completion_counters() -> void:
	daily_task_completion_counters.clear()
	claimed_tasks.clear()
	save_data()


func reset_all_progress() -> void:
	satisfaction_points = 0
	unlocked_diorama_items.clear()
	daily_task_completion_counters.clear()
	claimed_tasks.clear()
	total_bubbles_popped = 0
	total_sheets_cleared = 0
	total_surfaces_cleaned = 0
	total_breath_cycles = 0
	current_combo = 0
	satisfaction_points_changed.emit(0)
	save_data()


func set_settings(sfx: bool, ambience: bool, haptics: bool) -> void:
	sfx_enabled = sfx
	ambience_enabled = ambience
	haptics_enabled = haptics
	settings_changed.emit()
	save_data()


func save_data() -> void:
	var payload: Dictionary = {
		"satisfaction_points": satisfaction_points,
		"unlocked_diorama_items": unlocked_diorama_items,
		"daily_task_completion_counters": daily_task_completion_counters,
		"claimed_tasks": claimed_tasks,
		"total_bubbles_popped": total_bubbles_popped,
		"total_sheets_cleared": total_sheets_cleared,
		"total_surfaces_cleaned": total_surfaces_cleaned,
		"total_breath_cycles": total_breath_cycles,
		"sfx_enabled": sfx_enabled,
		"ambience_enabled": ambience_enabled,
		"haptics_enabled": haptics_enabled
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

	var dict: Dictionary = decoded
	satisfaction_points = int(dict.get("satisfaction_points", 0))

	unlocked_diorama_items.clear()
	for item in dict.get("unlocked_diorama_items", []):
		unlocked_diorama_items.append(str(item))

	var raw_counters = dict.get("daily_task_completion_counters", {})
	if typeof(raw_counters) == TYPE_DICTIONARY:
		daily_task_completion_counters = (raw_counters as Dictionary).duplicate(true)
	else:
		daily_task_completion_counters = {}

	claimed_tasks.clear()
	for t in dict.get("claimed_tasks", []):
		claimed_tasks.append(str(t))

	total_bubbles_popped = int(dict.get("total_bubbles_popped", 0))
	total_sheets_cleared = int(dict.get("total_sheets_cleared", 0))
	total_surfaces_cleaned = int(dict.get("total_surfaces_cleaned", 0))
	total_breath_cycles = int(dict.get("total_breath_cycles", 0))

	sfx_enabled = bool(dict.get("sfx_enabled", true))
	ambience_enabled = bool(dict.get("ambience_enabled", true))
	haptics_enabled = bool(dict.get("haptics_enabled", true))
