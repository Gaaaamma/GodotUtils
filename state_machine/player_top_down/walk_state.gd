class_name WalkState extends State

var direction: Vector2 = Vector2.ZERO
var speed: int = 60
var push_speed_ratio: float = 0.35


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
		CharacterManager.update_blend_positions(character_name, direction, animation_tree)
		
		for i in range(character.get_slide_collision_count()):
			var col = character.get_slide_collision(i)
			var body = col.get_collider()
			
			if body.is_in_group("pushable"):
				var push_dot = character.velocity.normalized().dot(-col.get_normal())
				if push_dot >= 1:
					body.velocity = character.velocity * push_speed_ratio
					body.move_and_slide()
					
	state_transition()


func state_transition():
	if direction.length() == 0:
		transition_request.emit(self.name, "IdleState")
		return
