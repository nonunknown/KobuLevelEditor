tool
extends Reference
class_name CameraPoint

signal clicked_pos(pos)

var from:Vector3
var to:Vector3
var cam:Camera = null

func _init(camera:Camera) -> void:
	cam = camera

const ps_point = preload("res://objects/obj_point.tscn")
var left_pressed:bool = false
func _unhandled_input(event: InputEvent) -> void:
	left_pressed = false
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			left_pressed = true
			from = cam.project_ray_origin(event.position)
			to = from + cam.project_ray_normal(event.position) * 10000
			
func _process(delta:float) -> void:
	
	if left_pressed:
		print("pressed left")
		var space_state:PhysicsDirectSpaceState = cam.get_world().direct_space_state
		var dict:Dictionary = space_state.intersect_ray(from,to)
		if dict.empty() == false:
			var point = ps_point.instance()
			cam.get_tree().root.add_child(point)
			point.global_transform.origin = dict.position
			emit_signal("clicked_pos", dict.position)
			print("clicked at: ", dict.position)
			return
