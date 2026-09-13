extends Node2D

## Provides an isometric 2.5D cozy room canvas for unlocked decorative items.
## Features an isometric room floor, empty slot indicators, and interactive item spawning.

const DioramaItemScene = preload("res://scenes/DioramaItem.tscn")

@export var grid_columns: int = 4
@export var grid_rows: int = 3
@export var tile_width: float = 160.0
@export var tile_height: float = 80.0

## item_id -> texture path (optional fallback/override)
@export var item_texture_paths: Dictionary = {}

var _game_manager: Node = null
var _items_container: Node2D = null


func _ready() -> void:
	# Dedicated container for spawned items so redraw of floor doesn't affect children
	_items_container = Node2D.new()
	_items_container.name = "ItemsContainer"
	add_child(_items_container)

	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")

	if _game_manager == null:
		push_warning("GameManager autoload missing. Diorama cannot populate unlocked items.")
		return

	if _game_manager.has_signal("diorama_item_unlocked"):
		_game_manager.diorama_item_unlocked.connect(_on_diorama_item_unlocked)

	refresh_unlocked_items()


func refresh_unlocked_items() -> void:
	if _items_container:
		for child in _items_container.get_children():
			child.queue_free()

	if _game_manager == null:
		return

	var unlocked_items = _game_manager.get("unlocked_diorama_items")
	if typeof(unlocked_items) != TYPE_ARRAY:
		return

	for index in unlocked_items.size():
		_spawn_item(str(unlocked_items[index]), index)

	queue_redraw()


func _on_diorama_item_unlocked(item_id: String) -> void:
	var current_count: int = _items_container.get_child_count() if _items_container else 0
	_spawn_item(item_id, current_count)
	queue_redraw()


func _spawn_item(item_id: String, index: int) -> void:
	if _items_container == null:
		return

	var target_parent: Node2D = _items_container
	var texture_path: String = str(item_texture_paths.get(item_id, ""))

	var item_node: Node2D = null
	if texture_path != "" and ResourceLoader.exists(texture_path):
		var sprite := Sprite2D.new()
		sprite.texture = load(texture_path)
		item_node = sprite
	else:
		var ditem = DioramaItemScene.instantiate()
		ditem.item_id = item_id
		item_node = ditem

	var grid_pos := Vector2i(index % max(1, grid_columns), index / max(1, grid_columns))
	item_node.position = _grid_to_isometric(grid_pos)
	item_node.scale = Vector2.ZERO
	target_parent.add_child(item_node)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(item_node, "scale", Vector2.ONE, 0.4).from(Vector2.ZERO)


func _grid_to_isometric(grid_position: Vector2i) -> Vector2:
	var iso_x: float = (grid_position.x - grid_position.y) * (tile_width * 0.5)
	var iso_y: float = (grid_position.x + grid_position.y) * (tile_height * 0.5)
	return Vector2(iso_x, iso_y)


func _draw() -> void:
	# Draw Isometric Room Floor Planks
	var total_cells := grid_columns * grid_rows
	var unlocked_count: int = 0
	if _game_manager:
		var items = _game_manager.get("unlocked_diorama_items")
		if typeof(items) == TYPE_ARRAY:
			unlocked_count = (items as Array).size()

	# Draw each isometric tile base
	for r in grid_rows:
		for c in grid_columns:
			var grid_pos := Vector2i(c, r)
			var center := _grid_to_isometric(grid_pos)
			var index := r * grid_columns + c

			# Isometric diamond polygon
			var half_w: float = tile_width * 0.48
			var half_h: float = tile_height * 0.48
			var points := PackedVector2Array([
				center + Vector2(0, -half_h),
				center + Vector2(half_w, 0),
				center + Vector2(0, half_h),
				center + Vector2(-half_w, 0)
			])

			# Alternating warm cozy wood parquet colors
			var is_even := (c + r) % 2 == 0
			var tile_color := Color("#EBDCC9") if is_even else Color("#DFCEB9")
			var border_color := Color("#C4B19A")

			draw_colored_polygon(points, tile_color)
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), border_color, 2.0)

			# If slot is empty, draw a cute dotted indicator ring inviting placement
			if index >= unlocked_count and index < 12:
				draw_arc(center, 22.0, 0, TAU, 16, Color(0.7, 0.65, 0.6, 0.35), 2.0, true)
				draw_circle(center, 4.0, Color(0.7, 0.65, 0.6, 0.4))
