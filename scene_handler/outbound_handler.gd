class_name OutboundHandler extends Node2D


func _ready() -> void:
	connect_outbound_signals()

## Set scene_change_request handler for each outbound area2D
func connect_outbound_signals():
	for child in get_children():
		if child is Outbound:
			child.scene_change_request.connect(SceneManager.change_scene)
