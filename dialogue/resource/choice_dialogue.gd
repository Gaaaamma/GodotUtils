class_name ChoiceDialogue extends Dialogue

@export var choices: Dictionary[String, String]


func get_ui_type() -> StringName:
	return &"choice_dialogue"
