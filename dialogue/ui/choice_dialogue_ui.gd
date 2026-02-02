class_name ChoiceDialogueUI extends DialogueUI

@export var choice_options_container: VBoxContainer
@export var question_label: Label

var choice_option_pkscn: PackedScene = preload("res://scenes/UI/choice_option_ui.tscn")
var choice_size: int = 0
var choice_options: Array[ChoiceOptionUI] = []
var chosen_index: int = 0


func _ready() -> void:
	choice_size = 0
	choice_options = []
	chosen_index = 0


func _input(event: InputEvent) -> void:
	if not is_dialogue_opened:
		return
	
	if event.is_action_pressed("confirm"):
		render_dialogue_request.emit(choice_options[chosen_index].next_talk_key)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("move_up"):
		var new_chosen_index = chosen_index - 1
		if new_chosen_index >= 0:
			render_chosen_option(new_chosen_index)
		
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("move_down"):
		var new_chosen_index = chosen_index + 1
		if new_chosen_index < choice_size:
			render_chosen_option(new_chosen_index)
		
		get_viewport().set_input_as_handled()


func render_dialogue(dialogue: Dialogue, talk_key: String, index: int) -> void:
	print("choice get index: %s[%d]" % [talk_key, index])
	# Set rendering basic informations
	dialogue = dialogue as ChoiceDialogue
	question_label.text = dialogue.content
	choice_size = dialogue.choices.size()
	
	# Validation
	if choice_size == 0:
		push_warning("Invalid dialogue.choices: choices is empty")
		return
	
	# render choice options
	var choice_counter: int = 0
	for next_talk_key in dialogue.choices.keys():
		var choice_option: ChoiceOptionUI = choice_option_pkscn.instantiate()
		choice_option.name = "ChoiceOptionUI%s" % str(choice_counter)
		choice_option.next_talk_key = next_talk_key
		choice_options.append(choice_option)
		choice_options_container.add_child(choice_option)
		choice_option.set_option_content(dialogue.choices[next_talk_key])
		
		var is_chosen: bool = true if choice_counter == chosen_index else false
		choice_option.set_chosen_status(is_chosen)
		choice_counter += 1
	
	# Emit to notify render finshed
	render_dialogue_finished.emit(index)


func render_chosen_option(new_chosen_index: int):
	# Validation check
	if new_chosen_index >= choice_size:
		push_warning("Invalid new_chosen_index: %d - choice_size=%d" % [new_chosen_index, choice_size])
		return
	if new_chosen_index == chosen_index:
		return
		
	# Render option
	choice_options[chosen_index].set_chosen_status(false)
	choice_options[new_chosen_index].set_chosen_status(true)
	chosen_index = new_chosen_index
