extends Node

## Procedural ASMR & Zen Audio Manager
## Synthesizes tactile pops, soothing chimes, and ambient tones at runtime with zero external dependencies.

var sfx_enabled: bool = true
var ambience_enabled: bool = true

var _pop_stream: AudioStreamWAV = null
var _whoosh_stream: AudioStreamWAV = null
var _sparkle_stream: AudioStreamWAV = null
var _bowl_stream: AudioStreamWAV = null
var _click_stream: AudioStreamWAV = null
var _chime_streams: Array[AudioStreamWAV] = []

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_index: int = 0
const SFX_PLAYER_POOL_SIZE: int = 8

var _ambience_player: AudioStreamPlayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_audio_players()
	_generate_sound_streams()


func _init_audio_players() -> void:
	for i in SFX_PLAYER_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)

	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.bus = "Master"
	add_child(_ambience_player)


func _generate_sound_streams() -> void:
	_pop_stream = _create_pop_stream()
	_whoosh_stream = _create_whoosh_stream()
	_sparkle_stream = _create_sparkle_stream()
	_bowl_stream = _create_bowl_stream()
	_click_stream = _create_click_stream()

	# Pentatonic chime frequencies (C5, D5, E5, G5, A5, C6)
	var frequencies: Array[float] = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50]
	for freq in frequencies:
		_chime_streams.append(_create_chime_stream(freq))


func _create_pop_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 0.12) # 120ms
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	for i in sample_count:
		var t: float = float(i) / 22050.0
		var freq: float = 720.0 * exp(-t * 35.0) + 90.0
		var envelope: float = exp(-t * 26.0)
		var click: float = (0.4 if i < 15 else 0.0)
		var sample_f: float = (sin(t * freq * TAU) + click) * envelope
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 28000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _create_chime_stream(frequency: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 0.6) # 600ms soft chime
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	for i in sample_count:
		var t: float = float(i) / 22050.0
		var envelope: float = exp(-t * 6.5)
		var s1: float = sin(t * frequency * TAU)
		var s2: float = sin(t * frequency * 2.0 * TAU) * 0.35
		var sample_f: float = (s1 + s2) * 0.7 * envelope
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 26000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _create_whoosh_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 0.22) # 220ms
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	var last_noise: float = 0.0
	for i in sample_count:
		var t: float = float(i) / 22050.0
		var envelope: float = sin(t / 0.22 * PI)
		var white: float = randf_range(-1.0, 1.0)
		last_noise = lerpf(last_noise, white, 0.12)
		var sample_f: float = last_noise * envelope * 0.6
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 24000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _create_sparkle_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 0.45) # 450ms
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	for i in sample_count:
		var t: float = float(i) / 22050.0
		var envelope: float = exp(-t * 9.0)
		var freq: float = 1400.0 + sin(t * 40.0) * 300.0
		var sample_f: float = sin(t * freq * TAU) * envelope * 0.5
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 22000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _create_bowl_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 1.8) # 1.8s deep singing bowl
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	for i in sample_count:
		var t: float = float(i) / 22050.0
		var attack: float = minf(1.0, t * 10.0)
		var decay: float = exp(-t * 1.8)
		var envelope: float = attack * decay
		var f1: float = sin(t * 220.0 * TAU)
		var f2: float = sin(t * 440.0 * TAU) * 0.4
		var f3: float = sin(t * 660.0 * TAU) * 0.15
		var sample_f: float = (f1 + f2 + f3) * 0.6 * envelope
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 26000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _create_click_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var sample_count: int = int(22050 * 0.05) # 50ms
	var buffer := PackedByteArray()
	buffer.resize(sample_count * 2)

	for i in sample_count:
		var t: float = float(i) / 22050.0
		var envelope: float = exp(-t * 70.0)
		var sample_f: float = sin(t * 880.0 * TAU) * envelope * 0.7
		var sample_val: int = int(clampf(sample_f, -1.0, 1.0) * 24000.0)
		buffer.encode_s16(i * 2, sample_val)

	wav.data = buffer
	return wav


func _get_next_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = _sfx_players[_sfx_player_index]
	_sfx_player_index = (_sfx_player_index + 1) % SFX_PLAYER_POOL_SIZE
	return player


func play_pop(pitch: float = 1.0) -> void:
	if not sfx_enabled or _pop_stream == null:
		return
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _pop_stream
	player.pitch_scale = clampf(pitch, 0.6, 2.0)
	player.volume_db = -3.0
	player.play()


func play_chime(note_index: int = 0) -> void:
	if not sfx_enabled or _chime_streams.is_empty():
		return
	var idx: int = wrapi(note_index, 0, _chime_streams.size())
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _chime_streams[idx]
	player.pitch_scale = 1.0
	player.volume_db = -4.0
	player.play()


func play_whoosh() -> void:
	if not sfx_enabled or _whoosh_stream == null:
		return
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _whoosh_stream
	player.pitch_scale = randf_range(0.9, 1.15)
	player.volume_db = -6.0
	player.play()


func play_sparkle() -> void:
	if not sfx_enabled or _sparkle_stream == null:
		return
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _sparkle_stream
	player.pitch_scale = randf_range(0.95, 1.1)
	player.volume_db = -5.0
	player.play()


func play_bowl() -> void:
	if not sfx_enabled or _bowl_stream == null:
		return
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _bowl_stream
	player.pitch_scale = 1.0
	player.volume_db = -2.0
	player.play()


func play_click() -> void:
	if not sfx_enabled or _click_stream == null:
		return
	var player: AudioStreamPlayer = _get_next_player()
	player.stream = _click_stream
	player.pitch_scale = randf_range(0.95, 1.05)
	player.volume_db = -8.0
	player.play()


func get_pop_stream() -> AudioStreamWAV:
	if _pop_stream == null:
		_pop_stream = _create_pop_stream()
	return _pop_stream
