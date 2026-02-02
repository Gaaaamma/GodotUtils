extends Node

@export var canvas_layer: int = 10
@export var init_talk_key: String = "default"

@onready var dialogue_canvas: CanvasLayer = CanvasLayer.new()

var _ui_scene_map: Dictionary[StringName, PackedScene] = {
	&"avatar_dialogue": preload("res://scenes/UI/avatar_dialogue_ui.tscn"),
	&"choice_dialogue": preload("res://scenes/UI/choice_dialogue_ui.tscn"),
}

var _current_conversation: Conversation
var _talk_current_index: Dictionary[String, int] = {}
var _talk_finished_index: Dictionary[String, int] = {}
var _current_talk_key: String
var _current_talk: Talk
var _current_talk_dialogue_size: int = 0
var _current_talk_index: int = 0

var _current_dialogue_ui_type: StringName
var _current_dialogue_ui: DialogueUI


## Prepare DialogueManager and its child CanvasLayer.
func _ready():
	set_process(false)
	_prepare_node()


func launch_conversation(conversation: Conversation):
	# Validation Check
	if conversation == null:
		push_warning("Invalid conversation is used: null")
		return
	if conversation.talks_map.get(init_talk_key) == null:
		push_warning("Invalid conversation is used: default talk is empty")
		return
	
	# Pause the game and controled by DialogueManager
	get_tree().paused = true
	
	# Update current conversaion & talk information
	_init_conversation_and_talk(conversation, init_talk_key)
	
	# Find current ui and add to canvas
	_set_dialogue_ui_to_canvas(_current_talk, _current_talk_index)
	
	# Open Dialogue & Render the first dialogue content
	dialogue_canvas.show()
	await _current_dialogue_ui.operate_dialogue_with_effect("open_dialogue")
	
	print("launch: render with %s[%d]" % [_current_talk_key, _current_talk_index])
	_current_dialogue_ui.render_dialogue(
		_current_talk.dialogues[_current_talk_index],
		_current_talk_key,
		_current_talk_index,
	)


func _set_dialogue_ui_to_canvas(talk: Talk, dialogue_index: int):
	# Validation
	if dialogue_index >= talk.dialogues.size():
		push_warning("Index out of bound: %d" % dialogue_index)
		return
	
	# Get UI PackedScene & Create node & Connect signals
	_current_dialogue_ui_type = talk.dialogues[dialogue_index].get_ui_type()
	var dialogue_ui_pkscn: PackedScene = _ui_scene_map.get(_current_dialogue_ui_type)
	if dialogue_ui_pkscn == null:
		push_warning("UI Type: %s lacks packed scene in ui_scene_map")
		return
	
	# Add new CustomizedDialogueUI to scene & connect signal & hide it
	_current_dialogue_ui = dialogue_ui_pkscn.instantiate()
	_current_dialogue_ui.render_dialogue_finished.connect(_on_render_dialogue_finished)
	_current_dialogue_ui.render_dialogue_request.connect(_on_render_dialogue_request)
	dialogue_canvas.add_child(_current_dialogue_ui)
	_current_dialogue_ui.hide()


func _is_dialogue_different_type(next_dialogue_index: int) -> bool:
	# Validation check
	if next_dialogue_index >= _current_talk.dialogues.size():
		push_warning("Invalid next_dialogue_index: %d - index out of bound" % next_dialogue_index)
		return false
	
	# Comparison
	var next_dialogue_ui_type: StringName = _current_talk.dialogues[next_dialogue_index].get_ui_type()
	return next_dialogue_ui_type != _current_dialogue_ui_type


func _on_render_dialogue_finished(index: int):
	print("dialogue rending is finished: %s[%d]" % [_current_talk_key, index])
	_talk_finished_index[_current_talk_key] = index


func _on_render_dialogue_request(on_demand_talk_key: String):
	# Get next talk key
	var current_dialogue: Dialogue = _current_talk.dialogues[_current_talk_index]
	var next_talk_key: String = current_dialogue.next_talk_key
	if on_demand_talk_key:
		print("next_talk_key: %s is replaced by on_demand_talk_key: %s" % [next_talk_key, on_demand_talk_key])
		next_talk_key = on_demand_talk_key
	
	if next_talk_key not in _current_conversation.talks_map.keys():
		print("Talk finished since next_talk_key=%s not exists" % next_talk_key)
		await _current_dialogue_ui.operate_dialogue_with_effect("close_dialogue")
		_current_dialogue_ui.queue_free()
		dialogue_canvas.hide()
		get_tree().paused = false
		return
	
	# Update current talk & current talk key
	_current_talk_key = next_talk_key
	_current_talk = _current_conversation.talks_map.get(_current_talk_key)
	var next_dialogue_index: int = _talk_current_index.get(_current_talk_key, -1) + 1
	if next_dialogue_index >= _current_talk.dialogues.size():
		print("Talk finished since next_dialogue_index oversize.")
		await _current_dialogue_ui.operate_dialogue_with_effect("close_dialogue")
		_current_dialogue_ui.queue_free()
		dialogue_canvas.hide()
		get_tree().paused = false
		return
	
	# Check if next dialogue is different ui type
	if _is_dialogue_different_type(next_dialogue_index):
		# Close current ui
		print("to close dialogue")
		await _current_dialogue_ui.operate_dialogue_with_effect("close_dialogue")
		_current_dialogue_ui.queue_free()
		print("success close dialogue")
		
		# Update new current ui and add to canvas
		_set_dialogue_ui_to_canvas(_current_talk, next_dialogue_index)
		
		# Open Dialogue
		await _current_dialogue_ui.operate_dialogue_with_effect("open_dialogue")
	
	# Render the content
	print("process: next_dialogue_index = %s[%d]" % [next_talk_key, next_dialogue_index])
	_current_dialogue_ui.render_dialogue(
		_current_talk.dialogues[next_dialogue_index],
		next_talk_key,
		next_dialogue_index,
	)
		
	# Update current_dialogue_index to next_dialogue_index
	_talk_current_index[_current_talk_key] = next_dialogue_index
	_current_talk_index = next_dialogue_index


func _init_conversation_and_talk(conversation: Conversation, talk_key: String):
	_current_conversation = conversation
	_current_talk_key = talk_key
	_current_talk = conversation.talks_map[talk_key]
	_current_talk_dialogue_size = _current_talk.dialogues.size()
	for key in conversation.talks_map.keys():
		_talk_current_index[key] = -1
		_talk_finished_index[key] = -1

	_current_talk_index = 0
	_talk_current_index[talk_key] = 0


## Configure process mode and prepare CanvasLayer node.
func _prepare_node():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	dialogue_canvas.name = "DialogueCanvas"
	dialogue_canvas.layer = canvas_layer
	dialogue_canvas.hide()
	add_child(dialogue_canvas)
