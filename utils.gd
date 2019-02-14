extends Node

var scene setget , get_scene

func array_add(a, b):
	for i in b:
		a.append(i)
	return a

func obj_has_groups(obj, groups):
	var has = false
	for grp in groups:
		if obj.get_groups().has(grp):
			has = true
			break
	return has

func get_nodes(root, recurent=false):
	var nodes = []
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj.filename:
			if recurent:
				array_add(objects, obj.get_children())
		else:
			array_add(objects, obj.get_children())
		nodes.append(root.get_path_to(obj))
	return nodes

func get_nodes_type(root, type, recurent=false):
	var nodes = get_nodes(root, recurent)
	var result = []
	for path in nodes:
		if root.get_node(path).get_class() == type :
			result.append(path)
	return result


func get_scene():
	return get_tree().current_scene

######################################
#based on CernansDev.gd
#	get collision shapes created by plugin
#

var cs_options = {
	cs_skip_branch = ["cs_none" ],
	cs_skip = [ "cs_manual" ],
	cs_groups = [ "cs", "cs_convex", "floor", "wall"],
	cs_convex = ["cs_convex"],
	cs_trimesh = ["cs", "floor", "wall"],
	bakedlight = {path = "lightmaps", ext = "_bldata.res" },
	material_dir = "res://materials",
	mesh_dir = "meshes",
	cs_dir = "cshapes"
}

func get_cs_list(root):
	var meshes = {
			convex = [],
			trimesh = []
		}
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj_has_groups(obj, cs_options.cs_skip_branch):
			continue
		if obj.get_child_count():
			array_add(objects, obj.get_children())
		if obj_has_groups(obj, cs_options.cs_skip):
			continue
		if obj_has_groups(obj, cs_options.cs_convex):
			meshes.convex.append(root.get_path_to(obj))
		elif obj_has_groups(obj, cs_options.cs_trimesh):
			meshes.trimesh.append(root.get_path_to(obj))
	return meshes

func get_cs_list_cs(root):
	# get collision nodes of meshes marked by us for collision, exclude areas and all that stuff
	# important for saving of those meshes
	
	var meshes = get_cs_list(root)
	var paths = []
	array_add(paths, meshes.convex)
	array_add(paths, meshes.trimesh)
	var nodes = []
	for path in paths:
		var obj = root.get_node(path)
		var css = get_nodes_type(obj, 'CollisionShape')
		for cspath in css:
			var o = obj.get_node(cspath)
			nodes.append(root.get_path_to(o))
	return nodes