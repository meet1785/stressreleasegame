extends Area2D

## Tactile ASMR Bubble Tile
## Features custom glossy 2D rendering, squish tweening, particle burst, haptics, and drag-to-pop.

signal popped(points: int)
signal reset_state()

@export_range(1, 999, 1) var points_per_pop: int = 1
@export var radius: float = 46.0
@export var bubble_color: Color = Color(0.55, 0.78, 0.95, 0.85)
@export var auto_reinflate: bool = false
@export var reinflate_delay: float = 3.0

@onready var pop_audio: AudioStreamPlayer2D = $PopAudio
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_popped: bool = false
var _is_popping: bool = false
var _audio_manager: Node = null
var _game_manager: Node = null
var _reinflate_timer: float = 0.0

# Dynamic visual properties
var _current_scale: float = 1.0
var _burst_particles: Array[Dictionary] = []


func _ready() -> void:
	input_pickable = true
	if is_inside_tree() and get_tree().root:
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")
		_game_manager = get_tree().root.get_node_or_null("GameManager")

	# Update collision shape to match radius if CircleShape2D exists
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = radius

	# Ensure PopAudio has fallback stream if empty
	if pop_audio and pop_audio.stream == null and _audio_manager != null:
		pop_audio.stream = _audio_manager.get_pop_stream()

	queue_redraw()


func _process(delta: float) -> void:
	if auto_reinflate and is_popped:
		_reinflate_timer += delta
		if _reinflate_timer >= reinflate_delay:
			reset_bubble()

	if not _burst_particles.is_empty():
		var alive: Array[Dictionary] = []
		for p in _burst_particles:
			p["life"] -= delta * 3.5
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.92
			if p["life"] > 0.0:
				alive.append(p)
		_burst_particles = alive
		queue_redraw()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if is_popped or _is_popping:
		return

	# Handle mobile touch
	if event is InputEventScreenTouch and event.pressed:
		pop()
		return

	# Handle desktop mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pop()
		return

	# Handle drag-to-pop across multiple bubbles
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pop()


func _mouse_enter() -> void:
	if is_popped or _is_popping:
		return
	# Allow swiping across bubbles with mouse button held
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pop()


func pop() -> void:
	if is_popped or _is_popping:
		return

	_is_popping = true
	is_popped = true
	_reinflate_timer = 0.0

	popped.emit(points_per_pop)

	if _game_manager:
		_game_manager.record_bubble_pop()
		_game_manager.add_satisfaction_points(points_per_pop)

	_trigger_haptics()
	_play_pop_sound()
	_spawn_particles()

	# Squish squash bounce animation
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.22, 0.8), 0.05)
	tween.tween_property(self, "scale", Vector2(0.92, 1.1), 0.07)
	tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.08)
	tween.finished.connect(func() -> void:
		_is_popping = false
		queue_redraw()
	)

	queue_redraw()


func reset_bubble() -> void:
	if not is_popped and not _is_popping:
		return

	is_popped = false
	_is_popping = false
	_reinflate_timer = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	scale = Vector2.ZERO
	tween.tween_property(self, "scale", Vector2.ONE, 0.25).from(Vector2.ZERO)
	tween.finished.connect(func() -> void:
		reset_state.emit()
	)

	queue_redraw()


func _trigger_haptics() -> void:
	if _game_manager and not _game_manager.haptics_enabled:
		return
	Input.vibrate_handheld(25)


func _play_pop_sound() -> void:
	var pitch := randf_range(0.9, 1.25)
	if _audio_manager:
		_audio_manager.play_pop(pitch)
	elif pop_audio and pop_audio.stream != null:
		pop_audio.pitch_scale = pitch
		pop_audio.play()


func _spawn_particles() -> void:
	_burst_particles.clear()
	var particle_count := 8
	for i in particle_count:
		var angle := (TAU / float(particle_count)) * float(i) + randf_range(-0.3, 0.3)
		var speed := randf_range(160.0, 320.0)
		var vel := Vector2(cos(angle), sin(angle)) * speed
		_burst_particles.append({
			"pos": Vector2.ZERO,
			"vel": vel,
			"life": 1.0,
			"size": randf_range(3.5, 7.0),
			"color": bubble_color.lightened(0.2)
		})


func _draw() -> void:
	var center := Vector2.ZERO

	if not is_popped:
		# 1. Subtle drop shadow
		draw_circle(center + Vector2(0, 4), radius + 2.0, Color(0, 0, 0, 0.12))

		# 2. Silicone tray rim socket
		draw_circle(center, radius + 1.0, bubble_color.darkened(0.2))

		# 3. Main translucent glossy dome
		draw_circle(center, radius - 1.0, bubble_color)

		# 4. Inner glow ring
		draw_arc(center, radius - 4.0, 0, TAU, 32, bubble_color.lightened(0.35), 3.0, true)

		# 5. Glossy highlight crescent on top-left
		var highlight_pos := center + Vector2(-radius * 0.35, -radius * 0.35)
		draw_circle(highlight_pos, radius * 0.28, Color(1, 1, 1, 0.65))

		# 6. Secondary soft rim highlight
		var sub_highlight_pos := center + Vector2(radius * 0.32, radius * 0.32)
		draw_circle(sub_highlight_pos, radius * 0.12, Color(1, 1, 1, 0.35))
	else:
		# Popped / indented silicone dimple
		# Recessed socket shadow
		draw_circle(center, radius, bubble_color.darkened(0.35))
		draw_circle(center, radius - 3.0, bubble_color.darkened(0.2).lerp(Color.WHITE, 0.1))
		# Inner indent crease
		draw_arc(center, radius * 0.55, 0, TAU, 24, bubble_color.darkened(0.4), 2.5, true)
		# Faint inverted bottom shine
		var indent_shine := center + Vector2(0, radius * 0.25)
		draw_circle(indent_shine, radius * 0.2, Color(1, 1, 1, 0.18))

	# Draw active bursting particles
	for p in _burst_particles:
		var alpha: float = clampf(float(p["life"]), 0.0, 1.0)
		var p_color: Color = p["color"]
		p_color.a = alpha * 0.85
		draw_circle(p["pos"], float(p["size"]) * alpha, p_color)
