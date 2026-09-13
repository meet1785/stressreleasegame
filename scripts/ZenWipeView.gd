extends Control

## Zen Surface Tidy / Dust Wipe Mode
## Provides a tactile cleaning experience where wiping away dust reveals sparkling cozy surfaces.

@onready var surface_canvas: Control = $CenterContainer/SurfaceCanvas
@onready var progress_bar: ProgressBar = $Header/ProgressBar
@onready var percent_label: Label = $Header/PercentLabel
@onready var surface_name_label: Label = $Header/SurfaceNameLabel
@onready var celebration_label: Label = $Header/CelebrationLabel
@onready var next_button: Button = $BottomControls/NextButton
@onready var reset_button: Button = $BottomControls/ResetButton

var _audio_manager: Node = null
var _game_manager: Node = null

var _current_surface_idx: int = 0
const SURFACES: Array[Dictionary] = [
	{
		"name": "Cozy Oak Tea Table",
		"desc": "Wipe away dust from the warm afternoon tea table.",
		"color": Color("#BC8A5F"),
		"shape": "circle",
		"size": Vector2(460, 460)
	},
	{
		"name": "Vintage Brass Mirror",
		"desc": "Clear the cloudy fog from the antique brass mirror.",
		"color": Color("#D4AF37"),
		"shape": "oval",
		"size": Vector2(400, 520)
	},
	{
		"name": "Steamy Rainy Window",
		"desc": "Wipe the misty condensation from the window pane.",
		"color": Color("#8ECAE6"),
		"shape": "rect",
		"size": Vector2(480, 480)
	}
]

# Dust grid: 12x12 = 144 dust particles
const GRID_RES: int = 12
var _dust_matrix: Array[bool] = []
var _total_dust_cells: int = 0
var _cleaned_dust_cells: int = 0
var _is_completed: bool = false
var _is_dragging: bool = false
var _sparkles: Array[Dictionary] = []
var _whoosh_cooldown: float = 0.0


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")
		_game_manager = get_tree().root.get_node_or_null("GameManager")

	surface_canvas.draw.connect(_on_surface_canvas_draw)
	surface_canvas.gui_input.connect(_on_surface_gui_input)
	next_button.pressed.connect(_on_next_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)

	_load_surface(_current_surface_idx)


func _process(delta: float) -> void:
	if _whoosh_cooldown > 0.0:
		_whoosh_cooldown -= delta

	if not _sparkles.is_empty():
		var alive: Array[Dictionary] = []
		for s in _sparkles:
			s["life"] -= delta * 2.5
			s["pos"] += s["vel"] * delta
			s["vel"] *= 0.94
			if s["life"] > 0.0:
				alive.append(s)
		_sparkles = alive
		surface_canvas.queue_redraw()


func _load_surface(index: int) -> void:
	_current_surface_idx = index % SURFACES.size()
	var surface: Dictionary = SURFACES[_current_surface_idx]
	surface_name_label.text = str(surface.get("name", "Cozy Surface"))
	celebration_label.text = str(surface.get("desc", "Wipe away gently"))
	celebration_label.modulate = Color("#7D8597")

	_init_dust_grid()
	_update_ui()
	surface_canvas.queue_redraw()


func _init_dust_grid() -> void:
	_dust_matrix.clear()
	_total_dust_cells = 0
	_cleaned_dust_cells = 0
	_is_completed = false

	var surface: Dictionary = SURFACES[_current_surface_idx]
	var shape: String = str(surface.get("shape", "circle"))
	var size: Vector2 = surface.get("size", Vector2(400, 400))
	var center := size * 0.5

	for r in GRID_RES:
		for c in GRID_RES:
			var cell_pos := Vector2(
				(float(c) + 0.5) / float(GRID_RES) * size.x,
				(float(r) + 0.5) / float(GRID_RES) * size.y
			)
			var in_bounds: bool = _is_point_in_surface(cell_pos, center, shape, size)
			_dust_matrix.append(in_bounds)
			if in_bounds:
				_total_dust_cells += 1

	progress_bar.max_value = _total_dust_cells
	progress_bar.value = 0


func _is_point_in_surface(pos: Vector2, center: Vector2, shape: String, size: Vector2) -> bool:
	var diff := pos - center
	if shape == "circle":
		return diff.length() <= (size.x * 0.46)
	elif shape == "oval":
		var nx: float = diff.x / (size.x * 0.46)
		var ny: float = diff.y / (size.y * 0.46)
		return (nx * nx + ny * ny) <= 1.0
	else:
		return absf(diff.x) <= (size.x * 0.46) and absf(diff.y) <= (size.y * 0.46)


func _on_surface_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
			if _is_dragging:
				_wipe_at(event.position)
	elif event is InputEventScreenTouch:
		_is_dragging = event.pressed
		if _is_dragging:
			_wipe_at(event.position)
	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and _is_dragging:
		_wipe_at(event.position)


func _wipe_at(local_pos: Vector2) -> void:
	if _is_completed:
		return

	var surface: Dictionary = SURFACES[_current_surface_idx]
	var size: Vector2 = surface.get("size", Vector2(400, 400))
	var wipe_radius := 44.0
	var cell_w: float = size.x / float(GRID_RES)
	var cell_h: float = size.y / float(GRID_RES)

	var wiped_any := false

	for r in GRID_RES:
		for c in GRID_RES:
			var idx: int = r * GRID_RES + c
			if idx < _dust_matrix.size() and _dust_matrix[idx]:
				var cell_center := Vector2((float(c) + 0.5) * cell_w, (float(r) + 0.5) * cell_h)
				if cell_center.distance_to(local_pos) <= wipe_radius:
					_dust_matrix[idx] = false
					_cleaned_dust_cells += 1
					wiped_any = true

	if wiped_any:
		if _whoosh_cooldown <= 0.0:
			if _audio_manager:
				_audio_manager.play_whoosh()
			_whoosh_cooldown = 0.15

		_spawn_wipe_sparkles(local_pos)
		_update_ui()
		surface_canvas.queue_redraw()

		# Check completion (>94% clean counts as completely sparkling!)
		var ratio: float = float(_cleaned_dust_cells) / float(maxi(1, _total_dust_cells))
		if ratio >= 0.94 and not _is_completed:
			_on_surface_completed()


func _spawn_wipe_sparkles(pos: Vector2) -> void:
	for i in 4:
		var angle := randf_range(0.0, TAU)
		var speed := randf_range(60.0, 140.0)
		_sparkles.append({
			"pos": pos,
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"life": 1.0,
			"size": randf_range(3.0, 6.0)
		})


func _on_surface_completed() -> void:
	_is_completed = true

	# Clear remaining dust spots
	for i in _dust_matrix.size():
		_dust_matrix[i] = false
	_cleaned_dust_cells = _total_dust_cells

	if _audio_manager:
		_audio_manager.play_sparkle()
		_audio_manager.play_chime(4)

	if _game_manager:
		_game_manager.record_surface_cleaned()

	celebration_label.text = "✨ Sparkling Clean! +20 Satisfaction Points! ✨"
	celebration_label.modulate = Color("#F4A261")

	var tween := create_tween()
	tween.tween_property(celebration_label, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(celebration_label, "scale", Vector2.ONE, 0.2)

	_update_ui()
	surface_canvas.queue_redraw()


func _update_ui() -> void:
	progress_bar.value = _cleaned_dust_cells
	var pct: int = int((float(_cleaned_dust_cells) / float(maxi(1, _total_dust_cells))) * 100.0)
	percent_label.text = "%d%% Clean" % pct


func _on_next_button_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_click()
	_load_surface(_current_surface_idx + 1)


func _on_reset_button_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_click()
	_load_surface(_current_surface_idx)


func _on_surface_canvas_draw() -> void:
	var surface: Dictionary = SURFACES[_current_surface_idx]
	var shape: String = str(surface.get("shape", "circle"))
	var size: Vector2 = surface.get("size", Vector2(400, 400))
	var col: Color = surface.get("color", Color.WHITE)
	var center := size * 0.5

	# 1. Soft drop shadow
	if shape == "circle":
		surface_canvas.draw_circle(center + Vector2(0, 8), size.x * 0.48, Color(0, 0, 0, 0.15))
		surface_canvas.draw_circle(center, size.x * 0.46, col)
		# Inner gloss ring
		surface_canvas.draw_arc(center, size.x * 0.42, 0, TAU, 32, col.lightened(0.2), 3.0)
	elif shape == "oval":
		var shadow_points := _make_ellipse_points(center + Vector2(0, 8), size.x * 0.48, size.y * 0.48)
		surface_canvas.draw_colored_polygon(shadow_points, Color(0, 0, 0, 0.15))
		var base_points := _make_ellipse_points(center, size.x * 0.46, size.y * 0.46)
		surface_canvas.draw_colored_polygon(base_points, col)
		var inner_points := _make_ellipse_points(center, size.x * 0.40, size.y * 0.40)
		surface_canvas.draw_colored_polygon(inner_points, Color("#E0E1DD"))
	else:
		# Rect / Window
		var rect := Rect2(center - size * 0.46, size * 0.92)
		surface_canvas.draw_rect(rect.grow(4), Color(0, 0, 0, 0.15))
		surface_canvas.draw_rect(rect, col)
		# Window pane cross
		surface_canvas.draw_line(Vector2(center.x, rect.position.y), Vector2(center.x, rect.end.y), Color("#415A77"), 6.0)
		surface_canvas.draw_line(Vector2(rect.position.x, center.y), Vector2(rect.end.x, center.y), Color("#415A77"), 6.0)

	# 2. Draw Dust Layer
	var cell_w: float = size.x / float(GRID_RES)
	var cell_h: float = size.y / float(GRID_RES)
	for r in GRID_RES:
		for c in GRID_RES:
			var idx: int = r * GRID_RES + c
			if idx < _dust_matrix.size() and _dust_matrix[idx]:
				var cell_center := Vector2((float(c) + 0.5) * cell_w, (float(r) + 0.5) * cell_h)
				# Dust cloud puff
				surface_canvas.draw_circle(cell_center, cell_w * 0.65, Color("#E5E5E5", 0.68))
				surface_canvas.draw_circle(cell_center + Vector2(2, 2), cell_w * 0.35, Color("#BDBDBD", 0.5))

	# 3. Draw Sparkling particles
	for sp in _sparkles:
		var alpha: float = clampf(float(sp["life"]), 0.0, 1.0)
		var sp_pos: Vector2 = sp["pos"]
		var sz: float = float(sp["size"]) * alpha
		surface_canvas.draw_circle(sp_pos, sz, Color(1, 0.95, 0.7, alpha))
		surface_canvas.draw_line(sp_pos + Vector2(-sz * 1.5, 0), sp_pos + Vector2(sz * 1.5, 0), Color(1, 1, 1, alpha), 1.5)
		surface_canvas.draw_line(sp_pos + Vector2(0, -sz * 1.5), sp_pos + Vector2(0, sz * 1.5), Color(1, 1, 1, alpha), 1.5)


func _make_ellipse_points(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var segs := 32
	for i in segs:
		var a := (TAU / float(segs)) * float(i)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts
