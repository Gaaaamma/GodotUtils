@abstract
class_name DialogueUI extends Control

@warning_ignore("unused_signal")
signal render_dialogue_finished(index: int)

@warning_ignore("unused_signal")
signal render_dialogue_request(on_demand_talk_key: String)

## Used to determine if dialogue_ui is truly opened.
@export var is_dialogue_opened: bool = false
@export var sfx_mapping: Dictionary[String, AudioStream] = {
	"open_dialogue": null,
	"close_dialogue": null,
}
@export var typing_delay: float = 0.1
@export var content_label: Label
@export var animation_player: AnimationPlayer
@export var audio_stream_player: AudioStreamPlayer

var typing_tween: Tween


## Coroutine: Operate dialogue with sfx & animation playing by `effect_name`.
## It will await animation_player.animation_finished emit
func operate_dialogue_with_effect(effect_name: String):
	# validation check
	if effect_name not in sfx_mapping:
		push_warning("Invalid sfx effect: %s - not exists" % effect_name)
		return
	if effect_name not in animation_player.get_animation_list():
		push_warning("Invalid animation effect: %s - not exists" % effect_name)
		return
	
	# play dialogue sfx
	var sfx_stream = sfx_mapping.get(effect_name) as AudioStream
	if sfx_stream:
		audio_stream_player.stream = sfx_stream
		audio_stream_player.play()
	
	# play dialogue animation
	animation_player.play(effect_name)
	await animation_player.animation_finished


# Execute printer tween and set tween callbacks.
# Render immediately if call this method again while tween is still running.
func _execute_printer_tween(content: String, callbacks: Array[Callable]):
	# Typing tween running check if is still running
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		content_label.text = content
		# callback after rendering
		for callback in callbacks:
			callback.call()
		return
	
	# Create new typing tween
	typing_tween = get_tree().create_tween()
	typing_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var typing_progress: String = ""
	for character in content:
		typing_progress += character
		typing_tween.tween_property(
			content_label, "text", typing_progress, typing_delay
		)
	
	# After rendering callback
	for cb in callbacks:
		typing_tween.tween_callback(cb)


## Called by DialogueManager to render DialogueUI by resource `dialogue`.
## Remember to emit `render_dialogue_finished` after rendering to inform DialogManager.
@abstract
func render_dialogue(dialogue: Dialogue, talk_key: String, index: int) -> void
