class_name IdleState extends State


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func enter():
	character.velocity = Vector2.ZERO
	fsm_playback.travel(self.name)


func exit():
	pass


func physics_process(_delta: float):
	state_transition()


func state_transition():
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		update_blend_position(direction)
		transition_request.emit(self.name, "WalkState")
		return
