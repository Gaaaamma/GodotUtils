extends Node

@onready var bgm: AudioStreamPlayer = AudioStreamPlayer.new()
var fade_in_volume: float = -40.0
var fade_out_volume: float = -40.0


## Prepare AudioManager and internal AudioStreamPlayer.
func _ready():
	_prepare_node()


## Fade in and start playing the given BGM.
## If the same BGM is already playing, this call will be ignored.
func fade_in_bgm(stream: AudioStream, fade_time := 1.0):
	if bgm.stream == stream and bgm.playing:
		return
	
	bgm.stop()
	bgm.stream = stream
	_fade_in(fade_time)


## Fade out the current BGM and stop it after fading.
func fade_out_bgm(fade_time := 1.0):
	if not bgm.playing:
		return

	var tween = create_tween()
	tween.tween_property(bgm, "volume_db", fade_out_volume, fade_time)
	tween.tween_callback(bgm.stop)


## Internal helper to fade in the current BGM.
## Used by `fade_in_bgm` and BGM looping.
func _fade_in(fade_time: float = 1.0):
	bgm.stop()
	bgm.volume_db = fade_in_volume
	bgm.play()

	var tween = create_tween()
	tween.tween_property(bgm, "volume_db", 0.0, fade_time)


## Configure process mode and prepare BGM player node.
func _prepare_node():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm.name = "BGM"
	bgm.bus = "BGM"
	bgm.finished.connect(_fade_in)
	add_child(bgm)
