class_name MyGLTFDocumentExtension
extends GLTFDocumentExtension

const PREFAB_HINT: String = "-is[";

func _discover_all_prefabs(state: GLTFState, path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path.path_join(file_name);
			if dir.current_is_dir():
				_discover_all_prefabs(state, full_path);
			elif file_name.get_extension() == "tscn":
				var fab_name = file_name.substr(0, file_name.length()-".tscn".length());
				if state.get_additional_data("-is-path://"+fab_name) == null:
					state.set_additional_data("-is-path://"+fab_name, full_path);
				#print(fab_name + " at " + full_path);
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: "+path+".")

func _lookup_prefab_path(state: GLTFState, fab: String) -> String:
	if state.get_additional_data("-is-path-ran") == null:
		state.set_additional_data("-is-path-ran", true);
		_discover_all_prefabs(state, "res://prefabs/");
	
	# Get the path for this prefab (if it exists)
	var path = state.get_additional_data("-is-path://"+fab);
	if path == null:
		return "";
	else:
		return path;

# CAN'T USE _generate_scene_node itself since it crashes
# Reason is probably 
func _generate_scene_node_IMPLEMENTATION(state: GLTFState, node_name: String) -> Node3D:
	var name = node_name;#gltf_node.original_name;
	if name.contains(PREFAB_HINT):
		var idx_begin = name.find(PREFAB_HINT);
		var idx_end = name.find("]", idx_begin);
		var idx = idx_begin+PREFAB_HINT.length();
		var fab_name = name.substr(idx, idx_end-idx);
		
		# Get the path of this fab
		var path_of_fab = _lookup_prefab_path(state, fab_name);
		if path_of_fab != "":
			var generated = load(path_of_fab).instantiate();
			#generated.name = name.substr(0, idx_begin)+name.substr(idx_end);
			return generated;
		else:
			printerr("Unknown "+PREFAB_HINT+fab_name+"]. Skipping.");
	return null;

func _replace_nodes_post_process(state: GLTFState, node: Node) -> void:
	# Look through the children to decide if we need to swap the parent!
	var new_node = null;
	for n in node.get_children():
		new_node = _generate_scene_node_IMPLEMENTATION(state, n.name);
		if new_node != null:
			break;
		
	if new_node:
		print("Swapping "+node.name);
		# Copy the meta
		var meta_list = node.get_meta_list()
		for metakey in meta_list:
			new_node.set_meta(metakey, node.get_meta(metakey));
		
		# Information about the original node
		var orig_node_name = node.name;
		var orig_owner = node.owner;
		var parent = node.get_parent();
		var pos_in_parent = node.get_index();
		var position = (node as Node3D).position;
		var rotation = (node as Node3D).rotation;
		var scale = (node as Node3D).scale;
		
		# Replace the node
		parent.remove_child(node);
		parent.add_child(new_node)
		parent.move_child(new_node, pos_in_parent)
		
		# Copy settings
		new_node.name = orig_node_name;
		(new_node as Node3D).position = Vector3(position);
		(new_node as Node3D).rotation = Vector3(rotation);
		(new_node as Node3D).scale = Vector3(scale);
		
		# Cleanup and ownership
		var old_node = node;
		node = new_node;
		new_node.owner = orig_owner;
		old_node.free();
		return;
	
	for n in node.get_children():
		_replace_nodes_post_process(state, n);

func _import_post(state: GLTFState, root: Node) -> Error:
	_replace_nodes_post_process(state, root);
	
	return OK;
