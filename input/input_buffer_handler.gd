class_name InputBufferHandler extends Node

const buffer_time: Dictionary[String, float] = {
	"roll": 0.25,
	"attack": 0.25,
}
var _input_buffer: Dictionary[String, bool] = {}
var _buffer_timer: Dictionary[String, float] = {}


func _ready() -> void:
	for input in buffer_time.keys():
		_input_buffer[input] = false
		_buffer_timer[input] = 0.0


func _process(delta: float) -> void:
	_update_buffer_timer(delta)


func consume(action: String) -> bool:
	if not _input_buffer.get(action, false):
		return false

	_input_buffer[action] = false
	_buffer_timer[action] = 0.0
	return true


func _update_buffer_timer(delta: float):
	for input in _buffer_timer.keys():
		if _input_buffer[input]:
			_buffer_timer[input] -= delta
			if _buffer_timer[input] <= 0:
				_input_buffer[input] = false
				_buffer_timer[input] = 0.0


func _input(event: InputEvent) -> void:
	for input in buffer_time.keys():
		if event.is_action_pressed(input) and not event.is_echo():
			_input_buffer[input] = true
			_buffer_timer[input] = buffer_time[input]
