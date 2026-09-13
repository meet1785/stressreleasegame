extends Area2D

## Interactive Cozy Diorama Item
## Renders vector illustration, idle micro-animations, and reacts to touch/clicks.

const ItemDrawerScript = preload("res://scripts/ItemDrawer.gd")

@export var item_id: String = ""
@export var scale_factor: float = 1.0

var _anim_time: float = 0.0
var _audio_manager: Node = null
var _floating_emotes: Array[Dictionary] = []


func _ready() -> void:
	input_pickable = true
	if is_inside_tree() and get_tree().root:
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	# Small random time offset so items don't animate in lockstep
	_anim_time = randf_range(0.0, 5.0)


func _process(delta: float) -> void:
	_anim_time += delta

	# Process floating emote particles
	if not _floating_emotes.is_empty():
		var alive: Array[Dictionary] = []
		for e in _floating_emotes:
			e["life"] -= delta * 1.8
			e["pos"] += Vector2(0, -50.0 * delta)
			if e["life"] > 0.0:
				alive.append(e)
		_floating_emotes = alive

	queue_redraw()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	var pressed := false
	if event is InputEventScreenTouch and event.pressed:
		pressed = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true

	if pressed:
		_interact()


func _interact() -> void:
	# Satisfying hop tween
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * 1.25, 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)

	# Sound reaction
	if _audio_manager:
		_audio_manager.play_chime(randi_range(0, 5))

	# Spawn floating emote
	_spawn_emote()


func _spawn_emote() -> void:
	_floating_emotes.append({
		"pos": Vector2(randf_range(-12.0, 12.0), -40.0),
		"life": 1.0,
		"type": "heart" if item_id == "sleeping_cat" else ("sparkle" if item_id == "crystal_geode" else "note")
	})


func _draw() -> void:
	ItemDrawerScript.draw_item(self, item_id, Vector2.ZERO, scale_factor, _anim_time)

	# Draw floating emotes
	for e in _floating_emotes:
		var alpha: float = clampf(float(e["life"]), 0.0, 1.0)
		var e_pos: Vector2 = e["pos"]
		var type: String = str(e["type"])

		if type == "heart":
			# Cute little pink heart
			draw_circle(e_pos + Vector2(-3, 0), 4, Color(1, 0.45, 0.6, alpha))
			draw_circle(e_pos + Vector2(3, 0), 4, Color(1, 0.45, 0.6, alpha))
			var tri := PackedVector2Array([e_pos + Vector2(-7, 2), e_pos + Vector2(7, 2), e_pos + Vector2(0, 9)])
			draw_colored_polygon(tri, Color(1, 0.45, 0.6, alpha))
		elif type == "note":
			# Musical note
			draw_circle(e_pos, 4, Color(0.9, 0.7, 0.3, alpha))
			draw_line(e_pos, e_pos + Vector2(0, -10), Color(0.9, 0.7, 0.3, alpha), 2.0)
			draw_line(e_pos + Vector2(0, -10), e_pos + Vector2(5, -12), Color(0.9, 0.7, 0.3, alpha), 2.0)
		else:
			# Sparkle star
			draw_circle(e_pos, 3, Color(1, 0.9, 0.5, alpha))
			draw_line(e_pos + Vector2(-6, 0), e_pos + Vector2(6, 0), Color(1, 1, 1, alpha), 1.5)
			draw_line(e_pos + Vector2(0, -6), e_pos + Vector2(0, 6), Color(1, 1, 1, alpha), 1.5)
