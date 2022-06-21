

extends AnimatedSprite3D
class_name DoomSprite

enum ANIMS {idle, walk}

export var cam_speed:float = .4
export var head_id:int = 0

onready var target_camera:Camera = get_viewport().get_camera()

var row:int = 0 setget set_row
var target_animation:int = ANIMS.idle

func _ready() -> void:
	set_current_animation(ANIMS.idle)

func set_row(value:int) -> void:
	var current_frame := frame
	var anim : String = "%s_%d" % [ANIMS.keys()[target_animation], value]
#	frames.set_animation_speed(anim, 15)
	play(anim)
	frame = current_frame
	pass

func change_animation(p_anim:int) -> void:
	target_animation = p_anim
	self.row = row
	pass

func set_target_cam(new_cam:Camera) -> void:
	target_camera = new_cam

func _process(delta: float) -> void:
	var p_fwd = (target_camera.global_transform.basis.z * Vector3(1,0,1)).normalized()
	var fwd = (global_transform.basis.z * Vector3(1,0,1)).normalized()
	var left = (global_transform.basis.x * Vector3(1,0,1)).normalized()
	
	var l_dot = left.dot(p_fwd)
	var f_dot = fwd.dot(p_fwd)
	
	flip_h = false
	if f_dot < -0.85:
		self.row = 0 # front sprite
	elif f_dot > 0.85:
		self.row = 4 # back sprite
	else:
		flip_h = l_dot > 0
		if abs(f_dot) < 0.3:
			self.row = 2 # left sprite
		elif f_dot < 0:
			self.row = 1 # forward left sprite
		else:
			self.row = 3 # back left sprite
	pass

func set_current_animation(anim:int) -> void:
	target_animation = anim
	pass

