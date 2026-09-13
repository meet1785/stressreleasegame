extends Control

## Tactile ASMR Bubble Wrap Sheet
## Hosts a responsive grid of glossy bubbles, combo tracking, and soothing ripple reset effects.

const BubbleTileScene = preload("res://scenes/BubbleTile.tscn")

@export var columns: int = 5
@export var rows: int = 7
@export var bubble_spacing: float = 110.0

@onready var grid_container: Node2D = $Board/GridContainer
@onready var progress_bar: ProgressBar = $Header/ProgressBar
@onready var count_label: Label = $Header/CountLabel
@onready var combo_label: Label = $Header/ComboLabel
@onready var flip_button: Button = $BottomControls/FlipButton
@onready var mode_toggle_btn: Button = $BottomControls/ModeToggleButton

var _bubbles: Array[Node2D] = []
var _audio_manager: Node = null
var _game_manager: Node = null

var _combo: int = 0
var _combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 1.0

var _endless_mode: bool = false

const PASTEL_PALETTES: Array[Color] = [
	Color("#99C1DE"), # Soft sky blue
	Color("#BCE784"), # Mint pistachio
	Color("#F4A261"), # Peach coral
	Color("#E0AAFF"), # Soft lilac
	Color("#FFCAD4"), # Rose blush
	Color("#F3D27C"), # Warm buttercup
	Color("#80CED7")  # Gentle aqua
]


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")
		_game_manager = get_tree().root.get_node_or_null("GameManager")

	flip_button.pressed.connect(_on_flip_button_pressed)
	mode_toggle_btn.pressed.connect(_on_mode_toggle_pressed)

	_spawn_bubble_grid()
	_update_ui()


func _process(delta: float) -> void:
	if _combo > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo = 0
			if _game_manager:
				_game_manager.set_combo(0)
			_update_combo_ui()


func _spawn_bubble_grid() -> void:
	for b in _bubbles:
		b.queue_free()
	_bubbles.clear()

	var total_width := (columns - 1) * bubble_spacing
	var total_height := (rows - 1) * bubble_spacing
	var start_x := -total_width * 0.5
	var start_y := -total_height * 0.5

	for r in rows:
		var row_color: Color = PASTEL_PALETTES[r % PASTEL_PALETTES.size()]
		for c in columns:
			var bubble = BubbleTileScene.instantiate()
			bubble.position = Vector2(start_x + c * bubble_spacing, start_y + r * bubble_spacing)
			bubble.bubble_color = row_color
			bubble.auto_reinflate = _endless_mode
			bubble.popped.connect(_on_bubble_popped.bind(bubble))
			grid_container.add_child(bubble)
			_bubbles.append(bubble)

	progress_bar.max_value = _bubbles.size()
	progress_bar.value = 0


func _on_bubble_popped(_points: int, _bubble: Node2D) -> void:
	_combo += 1
	_combo_timer = COMBO_TIMEOUT

	if _game_manager:
		_game_manager.set_combo(_combo)

	# Harmonic pitch progression based on combo
	var chime_step := (_combo - 1) % 6
	if _combo > 1 and _audio_manager:
		_audio_manager.play_chime(chime_step)

	_update_combo_ui()
	_update_ui()

	# Check for full sheet completion
	var popped_count := get_popped_count()
	if popped_count >= _bubbles.size():
		_on_sheet_cleared()


func _on_sheet_cleared() -> void:
	if _audio_manager:
		_audio_manager.play_sparkle()
	if _game_manager:
		_game_manager.record_sheet_cleared()

	# Pulse celebration on combo label
	combo_label.text = "✨ Sheet Cleared! +15 Bonus! ✨"
	combo_label.modulate = Color("#F3D27C")
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.25, 1.25), 0.15)
	tween.tween_property(combo_label, "scale", Vector2.ONE, 0.2)


func _on_flip_button_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_whoosh()

	# Flip / Ripple animation
	var tween := create_tween().set_parallel(true)
	for i in _bubbles.size():
		var b: Node2D = _bubbles[i]
		var delay := float(i) * 0.012
		tween.tween_callback(func() -> void:
			if b.has_method("reset_bubble"):
				b.call("reset_bubble")
				if _audio_manager and i % 5 == 0:
					_audio_manager.play_pop(1.2 + float(i % 5) * 0.1)
		).set_delay(delay)

	_combo = 0
	_update_combo_ui()
	_update_ui()


func _on_mode_toggle_pressed() -> void:
	_endless_mode = not _endless_mode
	mode_toggle_btn.text = "Mode: Endless Pop" if _endless_mode else "Mode: Tidy Sheet"
	for b in _bubbles:
		b.set("auto_reinflate", _endless_mode)


func get_popped_count() -> int:
	var count := 0
	for b in _bubbles:
		if b.get("is_popped") == true:
			count += 1
	return count


func _update_ui() -> void:
	var popped := get_popped_count()
	var total := _bubbles.size()
	progress_bar.value = popped
	count_label.text = "Tidy Progress: %d / %d" % [popped, total]


func _update_combo_ui() -> void:
	if _combo <= 1:
		combo_label.text = "Swipe or tap bubbles gently"
		combo_label.modulate = Color("#7D8597")
	else:
		var multiplier: int = mini(5, _combo)
		var quote: String = "Soothing!" if _combo < 5 else ("Serene!" if _combo < 10 else "Deep Zen!")
		combo_label.text = "🔥 %dx Combo! %s" % [multiplier, quote]
		combo_label.modulate = Color("#F4A261")
