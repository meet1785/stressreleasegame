extends Control

## Mindful Breathing Companion
## Calming visual breath pacer following the 4-4-4-4 box breathing technique.

@onready var breath_circle: Control = $CenterContainer/BreathCircle
@onready var phase_label: Label = $Header/PhaseLabel
@onready var instruction_label: Label = $Header/InstructionLabel
@onready var counter_label: Label = $Header/CounterLabel
@onready var toggle_button: Button = $BottomControls/ToggleButton

var _audio_manager: Node = null
var _game_manager: Node = null

enum BreathPhase { INHALE, HOLD_IN, EXHALE, REST }
var _current_phase: BreathPhase = BreathPhase.INHALE
var _phase_timer: float = 0.0
const PHASE_DURATION: float = 4.0

var _is_running: bool = true
var _completed_cycles: int = 0
var _current_radius: float = 80.0
const MIN_RADIUS: float = 70.0
const MAX_RADIUS: float = 180.0

var _phase_colors: Dictionary = {
	BreathPhase.INHALE: Color("#A2D2FF"),  # Calming Sky Blue
	BreathPhase.HOLD_IN: Color("#BDE0FE"), # Serene Pastel Blue
	BreathPhase.EXHALE: Color("#CDB4DB"),  # Soothing Lavender
	BreathPhase.REST: Color("#FFC8DD")     # Gentle Rose
}


func _ready() -> void:
	if is_inside_tree() and get_tree().root:
		_audio_manager = get_tree().root.get_node_or_null("AudioManager")
		_game_manager = get_tree().root.get_node_or_null("GameManager")

	breath_circle.draw.connect(_on_breath_circle_draw)
	toggle_button.pressed.connect(_on_toggle_button_pressed)

	_start_phase(BreathPhase.INHALE)
	_update_ui()


func _process(delta: float) -> void:
	if not _is_running:
		return

	_phase_timer += delta
	var progress: float = clampf(_phase_timer / PHASE_DURATION, 0.0, 1.0)

	match _current_phase:
		BreathPhase.INHALE:
			# Smooth ease-in-out expansion
			var t: float = (1.0 - cos(progress * PI)) * 0.5
			_current_radius = lerpf(MIN_RADIUS, MAX_RADIUS, t)
		BreathPhase.HOLD_IN:
			# Subtle pulsing hold
			_current_radius = MAX_RADIUS + sin(progress * TAU * 2.0) * 4.0
		BreathPhase.EXHALE:
			# Smooth ease-in-out contraction
			var t: float = (1.0 - cos(progress * PI)) * 0.5
			_current_radius = lerpf(MAX_RADIUS, MIN_RADIUS, t)
		BreathPhase.REST:
			# Gentle resting pulse
			_current_radius = MIN_RADIUS + sin(progress * TAU * 2.0) * 3.0

	breath_circle.queue_redraw()

	if _phase_timer >= PHASE_DURATION:
		_advance_phase()


func _advance_phase() -> void:
	_phase_timer = 0.0
	match _current_phase:
		BreathPhase.INHALE:
			_start_phase(BreathPhase.HOLD_IN)
		BreathPhase.HOLD_IN:
			_start_phase(BreathPhase.EXHALE)
		BreathPhase.EXHALE:
			_start_phase(BreathPhase.REST)
		BreathPhase.REST:
			_on_cycle_completed()
			_start_phase(BreathPhase.INHALE)


func _start_phase(phase: BreathPhase) -> void:
	_current_phase = phase
	_phase_timer = 0.0

	match phase:
		BreathPhase.INHALE:
			phase_label.text = "Inhale"
			instruction_label.text = "Breathe in deeply... fill your chest with calm"
			if _audio_manager:
				_audio_manager.play_bowl()
		BreathPhase.HOLD_IN:
			phase_label.text = "Hold"
			instruction_label.text = "Pause gently... notice the stillness"
		BreathPhase.EXHALE:
			phase_label.text = "Exhale"
			instruction_label.text = "Breathe out softly... let all tension drift away"
			if _audio_manager:
				_audio_manager.play_whoosh()
		BreathPhase.REST:
			phase_label.text = "Rest"
			instruction_label.text = "Rest at ease... you are safe and grounded"


func _on_cycle_completed() -> void:
	_completed_cycles += 1
	if _audio_manager:
		_audio_manager.play_chime(2)
		_audio_manager.play_sparkle()

	if _game_manager:
		_game_manager.record_breath_cycle()

	_update_ui()


func _update_ui() -> void:
	counter_label.text = "Mindful Breaths: %d (+10 pts each)" % _completed_cycles


func _on_toggle_button_pressed() -> void:
	_is_running = not _is_running
	toggle_button.text = "Pause Breath" if _is_running else "Resume Breath"
	if _audio_manager:
		_audio_manager.play_click()


func _on_breath_circle_draw() -> void:
	var center := Vector2(250, 250)
	var col: Color = _phase_colors.get(_current_phase, Color("#A2D2FF"))

	# Outer ambient glowing ripples
	for i in 3:
		var ripple_r: float = _current_radius + float(i + 1) * 22.0
		var alpha: float = 0.15 / float(i + 1)
		breath_circle.draw_circle(center, ripple_r, Color(col.r, col.g, col.b, alpha))

	# Main soothing breath sphere
	breath_circle.draw_circle(center, _current_radius, col)

	# Inner glowing highlight
	breath_circle.draw_circle(center, _current_radius * 0.65, Color.WHITE.lerp(col, 0.4))
	breath_circle.draw_circle(center, _current_radius * 0.35, Color.WHITE.lerp(col, 0.15))
