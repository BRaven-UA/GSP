tool
extends EditorScript

var test

func _run():
	var nodes = _get_all_nodes(get_scene())
	for node in nodes:
		print(node.path)

func _get_all_nodes(root: Node, ignored =[], list = []):
	for node in root.get_children():
		var path = node.get_path()
		if !path in ignored:
			list.append({"path": path})
			_get_all_nodes(node, ignored, list)
	return list
