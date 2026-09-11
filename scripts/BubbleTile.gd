extends Area2D

## Emitted after a successful tactile pop interaction.
signal popped(points: int)

@export_range(1, 999, 1) var points_per_pop: int = 1

@onready var pop_audio: AudioStreamPlayer2D = $PopAudio

var _is_popping: bool = false


func _ready() -> void:
	input_pickable = true


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if _is_popping:
		return
	if event is InputEventScreenTouch and event.pressed:
		_pop()


func _pop() -> void:
	_is_popping = true
	emit_signal("popped", points_per_pop)
	Input.vibrate_handheld(25)
	_play_pop_sound()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * 0.85, 0.06)
	tween.tween_property(self, "scale", Vector2.ONE * 1.05, 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
	tween.finished.connect(func() -> void:
		_is_popping = false
	)


func _play_pop_sound() -> void:
	if pop_audio.stream == null:
		return
	pop_audio.pitch_scale = randf_range(0.95, 1.15)
	pop_audio.play()
