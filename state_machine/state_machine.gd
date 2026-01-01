class_name StateMachine extends Node

@export var init_state_name: String = "IdleState"
@onready var character: CharacterBody2D
@onready var animation_tree: AnimationTree
@onready var fsm_playback: AnimationNodeStateMachinePlayback

var current_state: State
var prev_state: State
var available_state: Dictionary[String, State]
var blend_spaces: Array[String]


func _ready() -> void:
	# Assign basic vars
	character = get_parent()
	animation_tree = get_parent().get_node("AnimationTree")
	fsm_playback = animation_tree.get("parameters/StateMachine/playback")
	
	# Prepare blend spaces according to state
	for state in get_children():
		if state is State:
			blend_spaces.append("parameters/StateMachine/%s/blend_position" % state.name)
	
	# Assign vars & signals for state
	for state in get_children():
		if state is State:
			state.character = character
			state.animation_tree = animation_tree
			state.fsm_playback = fsm_playback
			state.blend_spaces = blend_spaces
			state.transition_request.connect(_on_transition_request)
			available_state[state.name] = state
	
	# initialize
	current_state = available_state[init_state_name]
	current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


func _on_transition_request(from_state_name: String, to_state_name: String):
	if not to_state_name in available_state:
		push_error("Unavailable to_state_name: %s (from %s)" % [to_state_name, from_state_name])
		return
	if from_state_name == to_state_name:
		return

	current_state.exit()
	prev_state = current_state
	current_state = available_state[to_state_name]
	current_state.enter()
