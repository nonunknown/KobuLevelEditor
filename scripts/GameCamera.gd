extends Camera
class_name GameCamera

signal clicked_pos(pos)

onready var gimball:Spatial = get_node("%Gimball")
onready var player:Player = get_node("%Player")
var from:Vector3
var to:Vector3
const ps_point = preload("res://objects/obj_point.tscn")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			from = project_ray_origin(event.position)
			to = from + project_ray_normal(event.position) * 10000

func _physics_process(delta:float):
	
	#update gimball position
	gimball.global_transform.origin = lerp(gimball.global_transform.origin, player.global_transform.origin, delta * 10)
	
	#click system
	
	if Input.is_action_just_pressed("lc"):
		var space_state:PhysicsDirectSpaceState = get_world().direct_space_state
		var dict:Dictionary = space_state.intersect_ray(from,to)
		if dict.empty() == false:
			var point = ps_point.instance()
			get_tree().root.add_child(point)
			point.global_transform.origin = dict.position
			emit_signal("clicked_pos", dict.position)
			return
