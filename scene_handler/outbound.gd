class_name Outbound
extends Area2D

signal scene_change_request(
	target_scene: String,
	target_location: String
)

## Path to the scene that will be loaded when this outbound is triggered.
@export_file("*.tscn") var target_scene: String

## Spawn / location ID in the target scene.
## The player will be placed at the matching spawn point after the scene changes.
@export var target_location: String

## Name of the group that is allowed to trigger this outbound.
## If left empty, any body can trigger it.
@export var trigger_group: String


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node):
	if not target_scene:
		push_warning("No target scene assigned at %s" % self.name)
		return
	
	if trigger_group == "" or body.is_in_group(trigger_group):
		scene_change_request.emit(target_scene, target_location)
