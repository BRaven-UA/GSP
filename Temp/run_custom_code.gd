tool
extends EditorScript

func _run():
	var plugin = get_editor_interface().get_tree().get_root().get_node("EditorNode/EditorPlugin")
	print(plugin.current_script.resource_path)
#	print(plugin.current_textedit.text)
#	print(plugin.data.folded_lines)
