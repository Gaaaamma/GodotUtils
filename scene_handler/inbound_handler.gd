class_name InboundHandler extends Node2D

var inbound_position: Dictionary[String, Vector2] = {}
var inbound_direction: Dictionary[String, Vector2] = {}

func _ready() -> void:
	collect_inbound_information()


## Collect all inbound information and expose by vars.
## User must use Inbound node name to search.
func collect_inbound_information():
	for child in get_children():
		if child is Inbound:
			inbound_position[child.name] = child.position
			inbound_direction[child.name] = child.direction.normalized()

## Use Inbound node name to search spawn position
func get_spawn_position(location: String) -> Vector2:
	return inbound_position.get(location)

## Use Inbound node name to search spawn direction
func get_spawn_direction(location: String) -> Vector2:
	return inbound_direction.get(location, Vector2.DOWN)
