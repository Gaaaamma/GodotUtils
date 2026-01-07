class_name StateMachine extends Node

@export var init_state_name: String = "IdleState"
@export var animation_tree_path: String = "AnimationTree"
@export var fsm_playback_path: String = "parameters/StateMachine/playback"

@onready var character: CharacterBody2D
@onready var character_name: String
@onready var animation_tree: AnimationTree
@onready var fsm_playback: AnimationNodeStateMachinePlayback

var current_state: State
var prev_state: State
var available_state: Dictionary[String, State]


func _ready() -> void:
	# Assign node vars
	character = get_parent()
	character_name = character.name
	animation_tree = get_parent().get_node(animation_tree_path)
	fsm_playback = animation_tree.get(fsm_playback_path)
	
	# Assign state vars & signals
	for state in get_children():
		if state is State:
			state.character_name = character_name
			state.character = character
			state.animation_tree = animation_tree
			state.fsm_playback = fsm_playback
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
		push_warning("Unavailable to_state_name: %s (from %s)" % [to_state_name, from_state_name])
		return
	if from_state_name == to_state_name:
		return

	current_state.exit()
	prev_state = current_state
	current_state = available_state[to_state_name]
	current_state.enter()
