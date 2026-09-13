extends Control

## Zen Catalog & Diorama Item Shop
## Allows players to preview and unlock cozy items with Satisfaction Points.

const ItemDrawerScript = preload("res://scripts/ItemDrawer.gd")

@onready var items_container: VBoxContainer = $ScrollContainer/ItemsContainer
@onready var points_label: Label = $Header/PointsLabel
@onready var status_banner: Label = $Header/StatusBanner

var _game_manager: Node = null
var _audio_manager: Node = null
var _card_drawers: Array[Control] = []


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	if _game_manager:
		if _game_manager.has_signal("satisfaction_points_changed"):
			_game_manager.satisfaction_points_changed.connect(func(_p: int) -> void: _refresh_shop())
		if _game_manager.has_signal("diorama_item_unlocked"):
			_game_manager.diorama_item_unlocked.connect(func(_id: String) -> void: _refresh_shop())

	_build_shop_cards()
	_refresh_shop()


func _build_shop_cards() -> void:
	for child in items_container.get_children():
		child.queue_free()
	_card_drawers.clear()

	if _game_manager == null:
		return

	var catalog: Array[Dictionary] = _game_manager.get_all_items()
	for item in catalog:
		var card := _create_item_card(item)
		items_container.add_child(card)


func _create_item_card(item: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 150)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	card.add_child(hbox)

	var item_id: String = str(item.get("id", ""))

	# Left: Vector Icon Preview Control
	var icon_box := Control.new()
	icon_box.custom_minimum_size = Vector2(120, 140)
	icon_box.draw.connect(func() -> void:
		ItemDrawerScript.draw_item(icon_box, item_id, Vector2(60, 75), 0.75, 0.0)
	)
	hbox.add_child(icon_box)
	_card_drawers.append(icon_box)

	# Middle: Info VBox
	var info_box := VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.alignment = BoxContainer.ALIGNMENT_CENTER
	info_box.add_theme_constant_override("separation", 6)
	hbox.add_child(info_box)

	var title_lbl := Label.new()
	title_lbl.text = "%s  •  %s" % [str(item.get("name", "")), str(item.get("category", ""))]
	title_lbl.add_theme_font_size_override("font_size", 24)
	info_box.add_child(title_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = str(item.get("description", ""))
	desc_lbl.add_theme_font_size_override("font_size", 17)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.modulate = Color("#7D8597")
	info_box.add_child(desc_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "Cost: %d Satisfaction Points" % int(item.get("cost", 0))
	cost_lbl.add_theme_font_size_override("font_size", 18)
	cost_lbl.modulate = Color("#F4A261")
	info_box.add_child(cost_lbl)

	# Right: Action Button
	var btn_box := CenterContainer.new()
	btn_box.custom_minimum_size = Vector2(180, 0)
	hbox.add_child(btn_box)

	var action_btn := Button.new()
	action_btn.name = "ActionButton"
	action_btn.custom_minimum_size = Vector2(160, 60)
	action_btn.add_theme_font_size_override("font_size", 20)
	action_btn.pressed.connect(_on_unlock_button_pressed.bind(item_id, item))
	btn_box.add_child(action_btn)

	card.set_meta("item_id", item_id)
	card.set_meta("cost", int(item.get("cost", 0)))
	card.set_meta("action_btn", action_btn)

	return card


func _refresh_shop() -> void:
	var current_points: int = _game_manager.satisfaction_points if _game_manager else 0
	points_label.text = "Your Satisfaction: %d Points" % current_points

	for card in items_container.get_children():
		if not card.has_meta("item_id"):
			continue
		var item_id: String = card.get_meta("item_id")
		var cost: int = card.get_meta("cost")
		var btn: Button = card.get_meta("action_btn")

		var is_unlocked: bool = _game_manager.is_item_unlocked(item_id) if _game_manager else false

		if is_unlocked:
			btn.text = "✓ In Room"
			btn.disabled = true
		elif current_points >= cost:
			btn.text = "Unlock (%d)" % cost
			btn.disabled = false
		else:
			btn.text = "Need %d pts" % (cost - current_points)
			btn.disabled = true


func _on_unlock_button_pressed(item_id: String, item: Dictionary) -> void:
	if _game_manager == null:
		return

	var success: bool = bool(_game_manager.call("unlock_item_with_points", item_id))
	if success:
		if _audio_manager:
			_audio_manager.play_sparkle()
			_audio_manager.play_chime(5)

		var item_name: String = str(item.get("name", "Item"))
		status_banner.text = "✨ Unlocked %s! Placed in your room ✨" % item_name
		status_banner.modulate = Color("#F4A261")

		var tween := create_tween()
		tween.tween_property(status_banner, "scale", Vector2(1.15, 1.15), 0.15)
		tween.tween_property(status_banner, "scale", Vector2.ONE, 0.2)

		_refresh_shop()
