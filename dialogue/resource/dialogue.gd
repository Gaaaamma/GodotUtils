@abstract
class_name Dialogue extends Resource

@export_multiline var content: String
@export var next_talk_key: String

@abstract
func get_ui_type() -> StringName
