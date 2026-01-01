class_name State extends Node

@warning_ignore("unused_signal")
signal transition_request(from_state_name: String, to_state_name: String)

var character: CharacterBody2D
var animation_tree: AnimationTree
var fsm_playback: AnimationNodeStateMachinePlayback
var blend_spaces: Array[String]

func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func enter():
	pass


func exit():
	pass


func process(_delta: float):
	pass


func physics_process(_delta: float):
	pass


func state_transition():
	pass


func update_blend_position(direction: Vector2):
	for blend_space in blend_spaces:
		animation_tree.set(blend_space, direction)
