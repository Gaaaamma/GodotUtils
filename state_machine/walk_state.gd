class_name WalkState extends State

var direction: Vector2 = Vector2.ZERO
var speed: int = 80


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func enter():
	fsm_playback.travel(self.name)


func exit():
	pass


func physics_process(_delta: float):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		character.velocity = direction * speed
		character.move_and_slide()
		update_blend_position(direction)
	
	state_transition()


func state_transition():
	if direction.length() == 0:
		transition_request.emit(self.name, "IdleState")
		return
