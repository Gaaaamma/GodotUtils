extends Node

var is_scene_changing: bool = false
var target_location: String:
	set(value):
		target_location = value
	get: 
		return target_location if target_location else "Default"


func change_scene(scene: String, location: String):
	# Prevent from continuously triggering scene changed
	if is_scene_changing:
		return
	
	# Lock & Change scene
	is_scene_changing = true
	target_location = location
	get_tree().change_scene_to_file.call_deferred(scene)
	
	# Wait for scene_changed signal & unlock
	await get_tree().scene_changed
	is_scene_changing = false
