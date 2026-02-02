class_name ChoiceOptionUI extends Control

@export var background_panel: Panel
@export var option_label: Label

@export var style_box_mapping: Dictionary[String, StyleBox] = {
	"chosen": null,
	"unchosen": null,
}
@export var text_color_mapping: Dictionary[String, Color] = {
	"chosen": Color(0.0, 0.0, 0.0, 1.0),
	"unchosen": Color(0.0, 0.0, 0.0, 0.2),
}

var next_talk_key: String = ""


func set_chosen_status(chosen_status: bool):
	# Validation check
	var chosen_key: String = "chosen" if chosen_status else "unchosen"
	if style_box_mapping.get(chosen_key) == null:
		push_warning("Invalid chosen_key: %s - No StyleBox exist" % chosen_status)
		return
	if text_color_mapping.get(chosen_key) == null:
		push_warning("Invalid chosen_key: %s - No text color exist" % chosen_status)
		return
	
	# Set panel & text override
	background_panel.add_theme_stylebox_override("panel", style_box_mapping.get(chosen_key))
	option_label.add_theme_color_override("font_color", text_color_mapping.get(chosen_key))


func set_option_content(content: String):
	option_label.text = content
