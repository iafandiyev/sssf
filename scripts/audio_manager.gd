extends Node
class_name AudioManager

## AudioManager - Generates and plays sound effects procedurally

var jump_sound: AudioStreamWAV
var score_sound: AudioStreamWAV
var game_over_sound: AudioStreamWAV
var click_sound: AudioStreamWAV

var jump_player: AudioStreamPlayer
var score_player: AudioStreamPlayer
var game_over_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

func _ready() -> void:
	_create_sounds()
	_create_players()

func _create_sounds() -> void:
	# Jump sound
	jump_sound = _create_tone_wav(0.15, 800.0, 1200.0, 0.3, true)
	
	# Score sound
	score_sound = _create_tone_wav(0.2, 1000.0, 1000.0, 0.25, false)
	
	# Game over sound
	game_over_sound = _create_tone_wav(0.5, 600.0, 200.0, 0.3, false)
	
	# Click sound
	click_sound = _create_noise_wav(0.05, 0.15)

func _create_tone_wav(duration: float, freq_start: float, freq_end: float, volume: float, chirp: bool) -> AudioStreamWAV:
	var sample_rate = 44100
	var samples = int(duration * sample_rate)
	var data = PackedFloat32Array()
	data.resize(samples * 2)  # stereo
	
	for i in range(samples):
		var t = i / samples
		var freq = lerp(freq_start, freq_end, t) if chirp else freq_start
		var envelope = exp(-t * 8.0) if not chirp else (1.0 - t)
		var sample = sin(freq * t * TAU) * envelope * volume
		data[i * 2] = sample      # left
		data[i * 2 + 1] = sample  # right
	
	var wav = AudioStreamWAV.new()
	wav.mix_rate = sample_rate
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	wav.data = _float_to_pcm16(data)
	return wav

func _create_noise_wav(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 44100
	var samples = int(duration * sample_rate)
	var data = PackedFloat32Array()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = i / samples
		var envelope = 1.0 - t
		var sample = (randf() * 2.0 - 1.0) * envelope * volume
		data[i * 2] = sample
		data[i * 2 + 1] = sample
	
	var wav = AudioStreamWAV.new()
	wav.mix_rate = sample_rate
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	wav.data = _float_to_pcm16(data)
	return wav

func _float_to_pcm16(float_data: PackedFloat32Array) -> PackedByteArray:
	var byte_data = PackedByteArray()
	byte_data.resize(float_data.size() * 2)
	
	for i in range(float_data.size()):
		var sample = float_data[i]
		sample = clamp(sample, -1.0, 1.0)
		var int_sample = int(sample * 32767.0)
		byte_data[i * 2] = int_sample & 0xFF
		byte_data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	return byte_data

func _create_players() -> void:
	jump_player = AudioStreamPlayer.new()
	jump_player.stream = jump_sound
	jump_player.bus = "Master"
	add_child(jump_player)
	
	score_player = AudioStreamPlayer.new()
	score_player.stream = score_sound
	score_player.bus = "Master"
	add_child(score_player)
	
	game_over_player = AudioStreamPlayer.new()
	game_over_player.stream = game_over_sound
	game_over_player.bus = "Master"
	add_child(game_over_player)
	
	click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	click_player.bus = "Master"
	add_child(click_player)

func play_jump() -> void:
	if jump_player:
		jump_player.play()

func play_score() -> void:
	if score_player:
		score_player.play()

func play_game_over() -> void:
	if game_over_player:
		game_over_player.play()

func play_click() -> void:
	if click_player:
		click_player.play()