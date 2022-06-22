tool
extends EditorPlugin

var eds:EditorSelection = null
var bt_edit:Button = null
var camera:Camera = null
var cursor:Spatial = null
var undo_redo:UndoRedo

const ps_edit = preload("res://addons/multiplacer/bt_edit.tscn")
const ps_cursor = preload("res://addons/multiplacer/models/mp_cursor.tscn")

func _enter_tree() -> void:
	undo_redo = get_undo_redo()
#	set_process(false)
#	set_process_unhandled_input(false)
	bt_edit = ps_edit.instance()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU,bt_edit)
	bt_edit.visible = false
	bt_edit.connect("toggled",self,"_on_toggled_edit")
	eds = get_editor_interface().get_selection()
	eds.connect("selection_changed",self,"_on_selection_changed")
	pass


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, bt_edit)
	pass

func _on_selection_changed() -> void:
	if eds.get_selected_nodes().size() != 1: return
	var selected_node:Node = eds.get_selected_nodes()[0]
	if selected_node is MultiMeshInstance:
		selected_multimesh()
	else:
		unselected_multimesh()
	
	
	pass

func selected_multimesh() -> void:
	bt_edit.visible = true
	pass

func unselected_multimesh() -> void:
	bt_edit.visible = false
	bt_edit.pressed = false
	pass

func _on_toggled_edit(toggled:bool) -> void:
	if toggled:
		var result = validate_multimesh()
		if result == false:
			bt_edit.pressed = false
			return
		if (cursor == null): 
			cursor = ps_cursor.instance()
			get_editor_interface().get_edited_scene_root().add_child(cursor)
		cursor.visible = true
		
	elif (cursor != null):
		cursor.visible = false
	pass

var m_instance:MultiMeshInstance
var mm:MultiMesh
var max_instances:int = -1
var index:int = -1

func validate_multimesh() -> bool:
	m_instance = eds.get_selected_nodes()[0]
	
	if m_instance.multimesh == null: 
		printerr("You didnt configured multimesh property in the inspector!")
		return false
		
	mm = m_instance.multimesh
	max_instances = mm.instance_count
	# the 2 lines below makes sures when the user resets the engine
	# the index continue from where it stopped
	if (index == -1):
		if ( mm.visible_instance_count > 0 ):
			index = mm.visible_instance_count
		else:
			index = 0
	
	if ( mm.transform_format != mm.TRANSFORM_3D ):
		printerr("Transform format must be 3D")
		return false
	
	if (mm.mesh == null):
		printerr("Mesh not set!")
		return false
	
	if (mm.instance_count < 1):
		printerr("instance count is less than 1!")
		push_warning("changing the instance count value after you've placed some meshes, will reset all meshes you've placed, be warned! (It will be improved in future)")
		return false
	
	return true

func handles(object: Object) -> bool:
	var result:bool = true if object is MultiMeshInstance else false
	return result

var from
var to
var dict := {}

func forward_spatial_gui_input(camera: Camera, event: InputEvent) -> bool:
	if !bt_edit.pressed: return false
	var captured_event = false
	

	if event is InputEventMouseMotion:
		
		from = camera.project_ray_origin(event.position)
		to = from + camera.project_ray_normal(event.position) * 10000
		var space_state:PhysicsDirectSpaceState = camera.get_world().direct_space_state
		dict = space_state.intersect_ray(from,to)
		if (dict.empty() == false):
			cursor.global_transform.origin = dict.position
			cursor.visible = true
		else:
			cursor.visible = false
		
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			add_instance()
			captured_event = true

	return captured_event
	pass


func add_instance() -> void:
	if (index >= max_instances):
		push_warning("max instances was reached, you must change the instance count, but be warned, you'll have to place all of them again")
		return
	
	undo_redo.create_action("add multimesh instance")
	undo_redo.add_do_method(self,"do_add_instance")
	undo_redo.add_undo_method(self, "undo_add_instance")
	undo_redo.commit_action()
	pass

func do_add_instance() -> void:
	mm.set_instance_transform(index, cursor.global_transform)
	print("added instance: ", index)
	index += 1
	mm.visible_instance_count = index
	pass

func undo_add_instance() -> void:
	if (index <= 0): return
	index -= 1
	mm.visible_instance_count = index
	print("removed instance: ", index)
	pass
