extends Control

## Cozy Room & Isometric Diorama View
## Displays the player's cozy space, unlocks, and ambient dust particles.

signal open_shop_requested()

@onready var diorama_canvas: Node2D = $CenterContainer/DioramaCanvas
@onready var count_label: Label = $Header/CountLabel
@onready var hint_label: Label = $Header/HintLabel
@onready var shop_shortcut_btn: Button = $BottomControls/ShopShortcutButton

var _game_manager: Node = null
var _audio_manager: Node = null
var _ambient_motes: Array[Dictionary] = []


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	shop_shortcut_btn.pressed.connect(_on_shop_shortcut_pressed)

	if _game_manager:
		if _game_manager.has_signal("diorama_item_unlocked"):
			_game_manager.diorama_item_unlocked.connect(func(_id: String) -> void: _update_stats())
		_update_stats()

	_init_ambient_motes()


func _process(delta: float) -> void:
	for m in _ambient_motes:
		m["pos"] += m["vel"] * delta
		m["anim"] += delta * 2.0
		# Wrap around screen
		if m["pos"].y < 0:
			m["pos"].y = size.y
		elif m["pos"].y > size.y:
			m["pos"].y = 0
		if m["pos"].x < 0:
			m["pos"].x = size.x
		elif m["pos"].x > size.x:
			m["pos"].x = 0

	queue_redraw()


func _init_ambient_motes() -> void:
	_ambient_motes.clear()
	for i in 18:
		_ambient_motes.append({
			"pos": Vector2(randf_range(0, 1080), randf_range(0, 1920)),
			"vel": Vector2(randf_range(-10, 10), randf_range(-15, -35)),
			"size": randf_range(2.0, 4.5),
			"anim": randf_range(0, 10)
		})


func _update_stats() -> void:
	var unlocked_count: int = 0
	if _game_manager:
		var items = _game_manager.get("unlocked_diorama_items")
		if typeof(items) == TYPE_ARRAY:
			unlocked_count = (items as Array).size()
	count_label.text = "Decorations: %d / 12 Unlocked" % unlocked_count
	if unlocked_count == 0:
		hint_label.text = "Visit the Zen Shop to unlock cozy decorations!"
	else:
		hint_label.text = "Tap placed items to interact with them ✨"


func _on_shop_shortcut_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_click()
	open_shop_requested.emit()


func _draw() -> void:
	# Draw gentle floating dust motes / glowing fireflies
	for m in _ambient_motes:
		var alpha: float = 0.25 + sin(float(m["anim"])) * 0.15
		var m_pos: Vector2 = m["pos"]
		draw_circle(m_pos, float(m["size"]), Color(1.0, 0.95, 0.8, alpha))
