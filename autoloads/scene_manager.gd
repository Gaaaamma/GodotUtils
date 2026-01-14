extends Node

@onready var fade_canvas: CanvasLayer = CanvasLayer.new()
@onready var fade_canvas_rect: ColorRect = ColorRect.new()

var is_scene_changing: bool = false

## Target spawn location for next scene.
## Used by InboundHandler after scene change.
var target_location: String:
	set(value):
		target_location = value
	get:
		return target_location if target_location else "Default"


## Prepare SceneManager and fade canvas.
func _ready() -> void:
	_prepare_node()


## Change scene to `scene` and set target spawn location.
## Scene transition includes pause, BGM fade out and screen fade.
func change_scene(scene: String, location: String):
	# Prevent from continuously triggering scene changed
	if is_scene_changing:
		return
	
	# Pause & lock scene change
	get_tree().paused = true
	is_scene_changing = true
	target_location = location
	
	# Fade out audio and screen
	AudioManager.fade_out_bgm(1)
	await _fade_out_scene(1)
	get_tree().change_scene_to_file.call_deferred(scene)
	
	# Wait for scene loaded, then unlock and fade in
	await get_tree().scene_changed
	is_scene_changing = false
	get_tree().paused = false
	await _fade_in_scene(0.75)


## Configure camera limits based on TileMapLayer and enable it.
func enable_camera(camera_2d: Camera2D, world: TileMapLayer, enabled: bool):
	# Calculate camera limits from used tile area
	var world_rect: Rect2i = world.get_used_rect()
	var top_left: Vector2 = world.map_to_local(world_rect.position)
	var bottom_right: Vector2 = world.map_to_local(world_rect.position + world_rect.size)
	
	var margin_padding: Vector2 = world.tile_set.tile_size / 2
	top_left -= margin_padding
	bottom_right -= margin_padding
	
	camera_2d.limit_left = int(top_left.x)
	camera_2d.limit_top = int(top_left.y)
	camera_2d.limit_right = int(bottom_right.x)
	camera_2d.limit_bottom = int(bottom_right.y)
	
	# Enable camera and smoothing
	camera_2d.enabled = enabled
	camera_2d.position_smoothing_enabled = enabled


## Fade in screen from black.
func _fade_in_scene(time := 0.5):
	var tween := create_tween()
	tween.tween_property(fade_canvas_rect, "modulate:a", 0.0, time)
	tween.tween_callback(fade_canvas.hide)
	await tween.finished


## Fade out screen to black.
func _fade_out_scene(time: float = 0.5):
	fade_canvas.show()
	fade_canvas_rect.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(fade_canvas_rect, "modulate:a", 1.0, time)
	await tween.finished


## Configure process mode and prepare fade canvas nodes.
func _prepare_node():
	# SceneManager is always processing
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Fade canvas layer
	fade_canvas.name = "FadeCanvas"
	fade_canvas.hide()
	fade_canvas.layer = RenderingServer.CANVAS_LAYER_MAX
	add_child(fade_canvas)
	
	# Fullscreen fade rect
	fade_canvas_rect.name = "FadeCanvasRect"
	fade_canvas_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_canvas_rect.color = Color()
	fade_canvas.add_child(fade_canvas_rect)
