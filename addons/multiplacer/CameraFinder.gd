extends Reference
class_name CameraFinder

var editor_viewport_2d = null
var editor_viewport_3d = null
var editor_camera_3d:Camera = null

func _init(_owner:Node) -> void:
	editor_viewport_2d = find_viewport_2d(_owner.get_node("/root/EditorNode"), 0)
	editor_viewport_3d = find_viewport_3d(_owner.get_node("/root/EditorNode"), 0)
#	print_tree(_owner.get_node("/root/EditorNode"))
	var path:String = "/root/EditorNode/@@596/@@597/@@605/@@607/@@611/@@615/@@616/@@617/@@633/@@634/@@643/@@644/@@6839/@@6645/@@6646/@@6647/@@6648/@@6720/@@6703/@@6704/@@6706"
	editor_camera_3d = _owner.get_node(path)


func print_tree(node:Node,level:int = 0) -> void:
	var spaces = ""
	for i in range(level):
		spaces += "  "
	for child in node.get_children():
		print("%sL %s" % [spaces, child.name])
		if child is Camera:
			print("found camera =====================: ", child.get_path())
			return
		for subchild in child.get_children():
			print_tree(subchild,level+1)
	pass

func find_viewport_2d(node: Node, recursive_level):
	if node.get_class() == "CanvasItemEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport_2d(child, recursive_level)
			if result != null:
				return result


func find_viewport_3d(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport_3d(child, recursive_level)
			if result != null:
				return result
