class_name State extends Node

@warning_ignore("unused_signal")
signal transition_request(from_state_name: String, to_state_name: String)

var character: CharacterBody2D
var character_name: String
var animation_tree: AnimationTree
var fsm_playback: AnimationNodeStateMachinePlayback


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
