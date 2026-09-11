extends Node2D

## Provides an isometric 2.5D canvas for unlocked decorative items.
@export var grid_columns: int = 4
@export var tile_width: float = 128.0
@export var tile_height: float = 64.0

## item_id -> texture path (for example: {"succulent_01": "res://assets/succulent_01.png"})
@export var item_texture_paths: Dictionary = {}

var _game_manager: Node = null


func _ready() -> void:
	_game_manager = get_node_or_null("/root/GameManager")
	if _game_manager == null:
		push_warning("GameManager autoload missing. Diorama cannot populate unlocked items.")
		return

	if _game_manager.has_signal("diorama_item_unlocked"):
		_game_manager.connect("diorama_item_unlocked", Callable(self, "_on_diorama_item_unlocked"))

	refresh_unlocked_items()


func refresh_unlocked_items() -> void:
	for child in get_children():
		child.queue_free()

	if _game_manager == null:
		return

	var unlocked_items = _game_manager.get("unlocked_diorama_items")
	if typeof(unlocked_items) != TYPE_ARRAY:
		return

	for index in unlocked_items.size():
		_spawn_item(str(unlocked_items[index]), index)


func _on_diorama_item_unlocked(item_id: String) -> void:
	var current_count := get_child_count()
	_spawn_item(item_id, current_count)


func _spawn_item(item_id: String, index: int) -> void:
	var sprite := Sprite2D.new()
	var texture_path := str(item_texture_paths.get(item_id, ""))
	if texture_path != "" and ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)

	var grid_position := Vector2i(index % max(1, grid_columns), index / max(1, grid_columns))
	sprite.position = _grid_to_isometric(grid_position)
	sprite.scale = Vector2.ZERO
	add_child(sprite)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.35).from(Vector2.ZERO)


func _grid_to_isometric(grid_position: Vector2i) -> Vector2:
	var iso_x := (grid_position.x - grid_position.y) * (tile_width * 0.5)
	var iso_y := (grid_position.x + grid_position.y) * (tile_height * 0.5)
	return Vector2(iso_x, iso_y)
