class_name InboundHandler extends Node2D

var inbound_global_position: Dictionary[String, Vector2] = {}
var inbound_direction: Dictionary[String, Vector2] = {}

func _ready() -> void:
	collect_inbound_information()


## Collect all inbound information and expose by vars.
## User must use Inbound node name to search.
func collect_inbound_information():
	for child in get_children():
		if child is Inbound:
			inbound_global_position[child.name] = child.global_position
			inbound_direction[child.name] = child.direction.normalized()


## Use Inbound node name to search spawn position (global_position)
func get_spawn_position(location: String) -> Vector2:
	return inbound_global_position.get(location)


## Use Inbound node name to search spawn direction
func get_spawn_direction(location: String) -> Vector2:
	return inbound_direction.get(location, Vector2.DOWN)
