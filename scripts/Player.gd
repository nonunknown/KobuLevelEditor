extends KinematicBody
class_name Player

export var move_speed:float = 5

onready var gimball:Spatial = get_node("%Gimball")
onready var navigation:Navigation = get_node("%Navigation")
onready var doom_spr:DoomSprite = get_node("DoomSprite")

var holding:bool = false
var relative_x:float = 0


var nav_agent := NavAgent.new(self)

func _ready() -> void:
	nav_agent.speed = move_speed
	get_viewport().get_camera().connect("clicked_pos",self,"_on_clicked")

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if ( event.pressed && event.button_index == BUTTON_MIDDLE ):
			holding = true
		else:
			holding = false
		pass
	if (event is InputEventMouseMotion && holding):
		relative_x = event.relative.x
	else:
		relative_x = 0
	pass

func _physics_process(delta: float) -> void:
	gimball.rotate_y(delta * -relative_x)
	nav_agent.update(delta)

func _on_clicked(pos:Vector3) -> void:
	nav_agent.set_path( navigation.get_simple_path(global_transform.origin,pos) )
	pass

func _on_walking_changed(walking:bool) -> void:
	var anim_id:int = doom_spr.ANIMS.idle
	
	if (walking): anim_id = doom_spr.ANIMS.walk
	
	doom_spr.target_animation = anim_id
	
	pass
