class_name AvatarDialogueUI extends DialogueUI

@export var character_name_label: Label
@export var avatar_texture_rect: TextureRect
@export var dialogue_hint: TextureRect

var consuming_dialogue: AvatarDialogue
var consuming_talk_key: String = ""
var consumed_talk_key: String = ""
var consuming_dialogue_index: int = -1
var consumed_dialogue_index: int = -1
var consumed_dialogue_counts: int = 0


func _ready() -> void:
	dialogue_hint.hide()
	is_dialogue_opened = false
	consuming_talk_key = ""
	consumed_talk_key = ""
	consuming_dialogue_index = -1
	consumed_dialogue_index = -1
	consumed_dialogue_counts = 0
	

func render_dialogue(dialogue: Dialogue, talk_key: String, index: int):
	print("Avatar get index: %s[%d]" % [talk_key, index])
	
	# Before rendering
	consuming_talk_key = talk_key
	consuming_dialogue_index = index
	_execute_before_rendering()
	
	# Parse Dialogue & set basic information
	dialogue = dialogue as AvatarDialogue
	consuming_dialogue = dialogue
	var character_name: String = dialogue.character_name
	var avatar_texture: Texture2D = dialogue.avatar
	var content: String = dialogue.content
	character_name_label.text = character_name
	avatar_texture_rect.texture = avatar_texture
	content_label.text = ""
	
	if consumed_dialogue_counts > 0:
		operate_dialogue_with_effect("next_dialogue")
	
	# Printer effect tween
	_execute_printer_tween(content, [_execute_after_rendering])


func _input(event: InputEvent) -> void:
	if not is_dialogue_opened:
		return
	
	if event.is_action_pressed("confirm"):
		if typing_tween and typing_tween.is_running():
			_execute_printer_tween(consuming_dialogue.content, [_execute_after_rendering])
		elif (
			consumed_talk_key == consuming_talk_key
			and consumed_dialogue_index == consuming_dialogue_index
		):
			render_dialogue_request.emit(consuming_dialogue.next_talk_key)
		get_viewport().set_input_as_handled()
			


func _execute_before_rendering():
	dialogue_hint.hide()


func _execute_after_rendering():
	dialogue_hint.show()
	operate_dialogue_with_effect("next_dialogue")
	
	# Raise signal to notice Manager
	consumed_talk_key = consuming_talk_key
	consumed_dialogue_counts += 1
	consumed_dialogue_index = consuming_dialogue_index
	render_dialogue_finished.emit(consumed_dialogue_index)
