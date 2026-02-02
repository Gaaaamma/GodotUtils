class_name AvatarDialogue extends Dialogue

@export var character_name: String
@export var avatar: Texture2D


func get_ui_type() -> StringName:
	return &"avatar_dialogue"
