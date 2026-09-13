extends Control

## Gentle Tidy - Main Game Controller
## Coordinates views (Pop, Clean, Breathe, Diorama, Shop, Tasks) and top-level navigation.

@onready var points_badge: Label = $TopBar/RightBox/PointsBadge
@onready var settings_btn: Button = $TopBar/RightBox/SettingsButton
@onready var views_container: Control = $ViewsContainer

# Navigation Buttons
@onready var tab_pop: Button = $BottomNav/NavHBox/TabPop
@onready var tab_clean: Button = $BottomNav/NavHBox/TabClean
@onready var tab_breathe: Button = $BottomNav/NavHBox/TabBreathe
@onready var tab_diorama: Button = $BottomNav/NavHBox/TabDiorama
@onready var tab_shop: Button = $BottomNav/NavHBox/TabShop
@onready var tab_tasks: Button = $BottomNav/NavHBox/TabTasks

# Views
@onready var bubble_view: Control = $ViewsContainer/BubbleSheetView
@onready var wipe_view: Control = $ViewsContainer/ZenWipeView
@onready var breathe_view: Control = $ViewsContainer/BreatheView
@onready var diorama_view: Control = $ViewsContainer/DioramaView
@onready var shop_view: Control = $ViewsContainer/ShopView
@onready var tasks_view: Control = $ViewsContainer/DailyTasksView

@onready var settings_modal: Control = $SettingsModal

var _game_manager: Node = null
var _audio_manager: Node = null
var _nav_buttons: Array[Button] = []
var _views: Array[Control] = []
var _current_tab_index: int = 0


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	_nav_buttons = [tab_pop, tab_clean, tab_breathe, tab_diorama, tab_shop, tab_tasks]
	_views = [bubble_view, wipe_view, breathe_view, diorama_view, shop_view, tasks_view]

	for i in _nav_buttons.size():
		var btn := _nav_buttons[i]
		btn.pressed.connect(_on_tab_pressed.bind(i))

	settings_btn.pressed.connect(_on_settings_pressed)

	if diorama_view.has_signal("open_shop_requested"):
		diorama_view.connect("open_shop_requested", Callable(self, "_on_open_shop_requested"))

	if _game_manager:
		if _game_manager.has_signal("satisfaction_points_changed"):
			_game_manager.satisfaction_points_changed.connect(_on_points_changed)
		_update_points_display(_game_manager.get("satisfaction_points"))

	settings_modal.hide()
	_switch_tab(0)


func _on_tab_pressed(index: int) -> void:
	if _audio_manager:
		_audio_manager.play_click()
	_switch_tab(index)


func _on_open_shop_requested() -> void:
	_switch_tab(4) # Shop tab index


func _switch_tab(index: int) -> void:
	_current_tab_index = index

	for i in _views.size():
		var v := _views[i]
		var is_active := (i == index)
		v.visible = is_active

	for i in _nav_buttons.size():
		var btn := _nav_buttons[i]
		if i == index:
			btn.modulate = Color("#F4A261")
		else:
			btn.modulate = Color("#7D8597")


func _on_points_changed(new_points: int) -> void:
	_update_points_display(new_points)

	# Pulse points badge
	var tween := create_tween()
	tween.tween_property(points_badge, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(points_badge, "scale", Vector2.ONE, 0.15)


func _update_points_display(points: Variant) -> void:
	var pts: int = int(points)
	points_badge.text = "✨ %d pts" % pts


func _on_settings_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_click()
	settings_modal.show()
