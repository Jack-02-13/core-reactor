extends Node

const SAMPLE_RATE := 22050
const HUM_DURATION := 4.0

var _hum_player: AudioStreamPlayer
var _stream_cache: Dictionary = {}

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_hum_player = AudioStreamPlayer.new()
	_hum_player.name = "ReactorAmbientHum"
	_hum_player.stream = _make_hum_stream()
	_hum_player.volume_db = -20.0
	add_child(_hum_player)
	_hum_player.play()

func _exit_tree() -> void:
	if is_instance_valid(_hum_player):
		_hum_player.stop()
		_hum_player.stream = null
	_stream_cache.clear()

func bind_ui_tree(root_node: Node) -> void:
	_bind_ui_node(root_node)

func play_ui_click() -> void:
	_play_one_shot("click", -20.0)

func play_upgrade_purchase() -> void:
	_play_one_shot("upgrade", -8.0)

func play_milestone() -> void:
	_play_one_shot("milestone", -4.0)

func play_prestige_charge() -> void:
	_play_one_shot("charge", -7.0)

func play_prestige_pulse(is_automatic: bool = false) -> void:
	_play_one_shot("pulse", -7.0 if not is_automatic else -14.0)

func _bind_ui_node(node: Node) -> void:
	if node is BaseButton and not node.has_meta("audio_click_bound"):
		node.set_meta("audio_click_bound", true)
		(node as BaseButton).pressed.connect(play_ui_click)
	for child in node.get_children():
		_bind_ui_node(child)

func _play_one_shot(sound_id: String, volume_db: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
	player.stream = _get_sfx_stream(sound_id)
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _get_sfx_stream(sound_id: String) -> AudioStreamWAV:
	if _stream_cache.has(sound_id):
		return _stream_cache[sound_id]
	var duration := 0.04
	match sound_id:
		"upgrade":
			duration = 0.12
		"milestone":
			duration = 0.28
		"charge":
			duration = 0.48
		"pulse":
			duration = 0.20
	var stream := _make_tone_stream(sound_id, duration)
	_stream_cache[sound_id] = stream
	return stream

func _make_tone_stream(sound_id: String, duration: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	var frame_count := int(round(duration * SAMPLE_RATE))
	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = false
	for frame in range(frame_count):
		var time := float(frame) / float(SAMPLE_RATE)
		var progress := clampf(time / duration, 0.0, 1.0)
		var frequency := 480.0
		var envelope := 0.0
		var sample := 0.0
		match sound_id:
			"click":
				frequency = lerpf(620.0, 360.0, progress)
				envelope = exp(-65.0 * time)
				sample = sin(TAU * frequency * time) * 0.18 * envelope
			"upgrade":
				frequency = lerpf(430.0, 720.0, progress)
				envelope = exp(-19.0 * time)
				sample = (sin(TAU * frequency * time) + sin(TAU * frequency * 2.0 * time) * 0.22) * 0.16 * envelope
			"milestone":
				frequency = lerpf(360.0, 690.0, progress)
				envelope = sin(PI * progress) * (1.0 - progress * 0.35)
				sample = (sin(TAU * frequency * time) + sin(TAU * frequency * 0.5 * time) * 0.28) * 0.20 * envelope
			"charge":
				frequency = lerpf(48.0, 82.0, progress)
				envelope = sin(PI * progress * 0.5)
				sample = (sin(TAU * frequency * time) + sin(TAU * frequency * 2.0 * time) * 0.30) * 0.23 * envelope
			"pulse":
				frequency = lerpf(118.0, 62.0, progress)
				envelope = exp(-13.0 * time)
				sample = (sin(TAU * frequency * time) + sin(TAU * frequency * 1.5 * time) * 0.20) * 0.25 * envelope
		buffer.put_16(int(round(clampf(sample, -0.95, 0.95) * 32767.0)))
	stream.data = buffer.data_array
	return stream

func _make_hum_stream() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	var frame_count := int(HUM_DURATION * SAMPLE_RATE)
	stream.loop_begin = 0
	stream.loop_end = frame_count
	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = false
	for frame in range(frame_count):
		var time := float(frame) / float(SAMPLE_RATE)
		var breathe := 0.72 + 0.28 * sin(TAU * time / HUM_DURATION)
		var hum := (sin(TAU * 55.0 * time) * 0.055 + sin(TAU * 110.0 * time) * 0.018) * breathe
		buffer.put_16(int(round(hum * 32767.0)))
	stream.data = buffer.data_array
	return stream
