extends Node

## Map character instance name to character name.
## key: character instance name, value: character name.
## Used to normalize multiple instances sharing the same animation setup.
var instance_name_to_character: Dictionary[String, String] = {
	# "FrogA": "Frog",
	# "FrogB": "Frog",
	# "FrogC": "Frog",
}


## Please assign character name & blend positions first before using.
## key: character name, value: Array[String] blend position names.
## Make sure blend_position path is correct since no error is raised.
var character_blend_positions: Dictionary[String, Array] = {
	# "Player": [
	# 	"parameters/StateMachine/IdleState/blend_position",
	# 	"parameters/StateMachine/WalkState/blend_position",
	# ],
	# "Frog": [
	# 	"parameters/StateMachine/FrogIdleState/blend_position",
	# 	"parameters/StateMachine/FrogWalkState/blend_position",
	# ],
}


## Create character at `spawn_position` under current scene.
## It will also return the created Node for further usage.
func spawn_character(character_pkscn: PackedScene, spawn_position: Vector2) -> Node:
	# Create character and add it under current scene
	var character = character_pkscn.instantiate()
	var current_scene = get_tree().current_scene
	current_scene.add_child(character)
	
	# Update character basic data (Ex: global_position)
	character.global_position = spawn_position
	
	# Return instance for further usage
	return character


## Use `instance_name` to find character name & blend_positions. Then update by `direction`.
## Remember to register blend_position into `character_blend_positions` before using and double check the correctness.
func update_blend_positions(instance_name: String, direction: Vector2, animation_tree: AnimationTree):
	
	var character_name: String = instance_name_to_character.get(instance_name, instance_name)
	if character_name not in character_blend_positions:
		push_warning("Create '%s' at character_blend_positions before using" % character_name)
		return
		
	var blend_positions = character_blend_positions[character_name] as Array[String]
	if blend_positions.is_empty():
		push_warning("%s has no blend position to update" % character_name)
		return
	
	# Update blend position
	direction = direction.normalized()
	for blend_position in blend_positions:
		animation_tree.set(blend_position, direction)
