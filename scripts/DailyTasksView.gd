extends Control

## Daily Mindful Tasks & Calming Goals
## Tracks stress-relief milestones and rewards players with Satisfaction Points.

@onready var tasks_container: VBoxContainer = $ScrollContainer/TasksContainer
@onready var points_label: Label = $Header/PointsLabel
@onready var status_label: Label = $Header/StatusLabel

var _game_manager: Node = null
var _audio_manager: Node = null


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	if _game_manager:
		if _game_manager.has_signal("task_completed"):
			_game_manager.task_completed.connect(func(_id: String) -> void: _refresh_tasks())
		if _game_manager.has_signal("satisfaction_points_changed"):
			_game_manager.satisfaction_points_changed.connect(func(_p: int) -> void: _refresh_tasks())

	_build_task_cards()
	_refresh_tasks()


func _build_task_cards() -> void:
	for child in tasks_container.get_children():
		child.queue_free()

	if _game_manager == null:
		return

	var tasks: Array[Dictionary] = _game_manager.get_all_tasks()
	for task in tasks:
		var card := _create_task_card(task)
		tasks_container.add_child(card)


func _create_task_card(task: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 130)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	card.add_child(hbox)

	var task_id: String = str(task.get("id", ""))
	var goal: int = int(task.get("goal", 1))
	var reward: int = int(task.get("reward", 0))

	# Left icon / goal badge
	var badge_box := CenterContainer.new()
	badge_box.custom_minimum_size = Vector2(100, 120)
	var badge_lbl := Label.new()
	badge_lbl.text = "🎯"
	badge_lbl.add_theme_font_size_override("font_size", 36)
	badge_box.add_child(badge_lbl)
	hbox.add_child(badge_box)

	# Middle: Info + Progress VBox
	var info_box := VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.alignment = BoxContainer.ALIGNMENT_CENTER
	info_box.add_theme_constant_override("separation", 6)
	hbox.add_child(info_box)

	var title_lbl := Label.new()
	title_lbl.text = str(task.get("title", ""))
	title_lbl.add_theme_font_size_override("font_size", 24)
	info_box.add_child(title_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = str(task.get("description", ""))
	desc_lbl.add_theme_font_size_override("font_size", 16)
	desc_lbl.modulate = Color("#7D8597")
	info_box.add_child(desc_lbl)

	var bar_hbox := HBoxContainer.new()
	bar_hbox.add_theme_constant_override("separation", 10)
	info_box.add_child(bar_hbox)

	var pbar := ProgressBar.new()
	pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pbar.custom_minimum_size = Vector2(0, 18)
	pbar.max_value = goal
	pbar.show_percentage = false
	bar_hbox.add_child(pbar)

	var prog_lbl := Label.new()
	prog_lbl.add_theme_font_size_override("font_size", 16)
	prog_lbl.text = "0 / %d" % goal
	bar_hbox.add_child(prog_lbl)

	# Right: Claim Button
	var btn_box := CenterContainer.new()
	btn_box.custom_minimum_size = Vector2(170, 0)
	hbox.add_child(btn_box)

	var claim_btn := Button.new()
	claim_btn.name = "ClaimButton"
	claim_btn.custom_minimum_size = Vector2(150, 56)
	claim_btn.add_theme_font_size_override("font_size", 18)
	claim_btn.pressed.connect(_on_claim_button_pressed.bind(task_id, reward))
	btn_box.add_child(claim_btn)

	card.set_meta("task_id", task_id)
	card.set_meta("goal", goal)
	card.set_meta("reward", reward)
	card.set_meta("pbar", pbar)
	card.set_meta("prog_lbl", prog_lbl)
	card.set_meta("claim_btn", claim_btn)

	return card


func _refresh_tasks() -> void:
	var current_points: int = _game_manager.satisfaction_points if _game_manager else 0
	points_label.text = "Your Satisfaction: %d Points" % current_points

	for card in tasks_container.get_children():
		if not card.has_meta("task_id"):
			continue
		var task_id: String = card.get_meta("task_id")
		var goal: int = card.get_meta("goal")
		var reward: int = card.get_meta("reward")
		var pbar: ProgressBar = card.get_meta("pbar")
		var prog_lbl: Label = card.get_meta("prog_lbl")
		var btn: Button = card.get_meta("claim_btn")

		var progress: int = _game_manager.get_task_progress(task_id) if _game_manager else 0
		var is_claimed: bool = _game_manager.is_task_claimed(task_id) if _game_manager else false
		var is_claimable: bool = _game_manager.is_task_claimable(task_id) if _game_manager else false

		pbar.value = mini(progress, goal)
		prog_lbl.text = "%d / %d" % [mini(progress, goal), goal]

		if is_claimed:
			btn.text = "✓ Claimed"
			btn.disabled = true
		elif is_claimable:
			btn.text = "Claim (+%d)" % reward
			btn.disabled = false
		else:
			btn.text = "In Progress"
			btn.disabled = true


func _on_claim_button_pressed(task_id: String, reward: int) -> void:
	if _game_manager == null:
		return

	var claimed: bool = bool(_game_manager.call("claim_task_reward", task_id))
	if claimed:
		if _audio_manager:
			_audio_manager.play_sparkle()
			_audio_manager.play_chime(4)

		status_label.text = "✨ Claimed +%d Points! Keep up the mindful rhythm ✨" % reward
		status_label.modulate = Color("#F4A261")

		var tween := create_tween()
		tween.tween_property(status_label, "scale", Vector2(1.15, 1.15), 0.15)
		tween.tween_property(status_label, "scale", Vector2.ONE, 0.2)

		_refresh_tasks()
