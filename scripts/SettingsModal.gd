extends Control

## Settings & Preferences Modal
## Manages audio toggles, haptics, and save data management.

signal closed()

@onready var sfx_check: CheckButton = $PanelContainer/VBox/SfxRow/SfxCheck
@onready var ambience_check: CheckButton = $PanelContainer/VBox/AmbienceRow/AmbienceCheck
@onready var haptics_check: CheckButton = $PanelContainer/VBox/HapticsRow/HapticsCheck
@onready var reset_button: Button = $PanelContainer/VBox/ResetButton
@onready var close_button: Button = $PanelContainer/VBox/CloseButton

var _game_manager: Node = null
var _audio_manager: Node = null


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_game_manager = get_tree().root.get_node_or_null("GameManager")
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")

	sfx_check.toggled.connect(_on_sfx_toggled)
	ambience_check.toggled.connect(_on_ambience_toggled)
	haptics_check.toggled.connect(_on_haptics_toggled)
	reset_button.pressed.connect(_on_reset_pressed)
	close_button.pressed.connect(_on_close_pressed)

	_sync_ui()


func _sync_ui() -> void:
	if _game_manager:
		sfx_check.button_pressed = bool(_game_manager.get("sfx_enabled"))
		ambience_check.button_pressed = bool(_game_manager.get("ambience_enabled"))
		haptics_check.button_pressed = bool(_game_manager.get("haptics_enabled"))


func _on_sfx_toggled(pressed: bool) -> void:
	if _game_manager:
		_game_manager.set("sfx_enabled", pressed)
	if _audio_manager:
		_audio_manager.set("sfx_enabled", pressed)
		if pressed:
			_audio_manager.play_pop(1.0)
	_save_settings()


func _on_ambience_toggled(pressed: bool) -> void:
	if _game_manager:
		_game_manager.set("ambience_enabled", pressed)
	if _audio_manager:
		_audio_manager.set("ambience_enabled", pressed)
		if pressed:
			_audio_manager.play_bowl()
	_save_settings()


func _on_haptics_toggled(pressed: bool) -> void:
	if _game_manager:
		_game_manager.set("haptics_enabled", pressed)
	if pressed:
		Input.vibrate_handheld(30)
	_save_settings()


func _save_settings() -> void:
	if _game_manager and _game_manager.has_method("save_data"):
		_game_manager.call("save_data")


func _on_reset_pressed() -> void:
	if _game_manager and _game_manager.has_method("reset_all_progress"):
		_game_manager.call("reset_all_progress")
	if _audio_manager:
		_audio_manager.play_sparkle()
	reset_button.text = "✓ Progress Reset"
	reset_button.disabled = true


func _on_close_pressed() -> void:
	if _audio_manager:
		_audio_manager.play_click()
	closed.emit()
	hide()
