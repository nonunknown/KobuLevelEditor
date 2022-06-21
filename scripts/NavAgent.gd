extends Reference
class_name NavAgent

var path_index:int = 0
var target:Spatial
var velocity:Vector3 = Vector3.ZERO
var speed:float = 0
var path = []
var _walking:bool = false setget set_walking

func set_walking(value:bool) -> void:
	_walking = value
#	on_walking_changed(_walking)
	target.call_deferred("_on_walking_changed",_walking)
	

func _init(_target:Spatial) -> void:
	target = _target
	path.append(Vector3.ZERO)
	path.remove(0)

func set_path(path:PoolVector3Array) -> void:
	self.path = path
	pass

func update(delta:float) -> void:
	
	var dist_to_walk:float = speed * delta
	while dist_to_walk > 0 and path.size() > 0:
		
		var dist_to_next_point = target.global_transform.origin.distance_to(path[0])
		if dist_to_walk <= dist_to_next_point:
			
			target.global_transform.origin += target.global_transform.origin.direction_to(path[0]) * dist_to_walk
			target.look_at(path[0],Vector3.UP)
			self._walking = true
#			doom_sprite.set_current_animation(doom_sprite.ANIMS.walk)
		else:
			target.global_transform.origin = path[0]
			path.remove(0)
			self._walking = false
#			doom_sprite.set_current_animation(doom_sprite.ANIMS.idle)
		dist_to_walk -= dist_to_next_point
