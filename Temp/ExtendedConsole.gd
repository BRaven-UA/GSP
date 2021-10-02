tool
extends RichTextLabel

var teeeest := "is it works?" 

func parse_bbcode(text) -> int:
	text += "hfhfhfhfhf"
	return .parse_bbcode(text)

func clear() -> void:
	teeeest = "cleared"

func add_image(image: Texture, width:int = 0, height:int = 0) -> void:
	teeeest = "aded_image"
	.add_image(image, width, height)

func set_bbcode(value: String) -> void:
	teeeest = "set_bbcode"
	.set_bbcode(value)

func set_text(value: String) -> void:
	teeeest = "set_text"
	.set_text(value)

func add_text(value: String) -> void:
	teeeest = "add_text"
	.add_text(value)

func append_bbcode(value: String) -> int:
	teeeest = "append_bbcode"
	return .append_bbcode(value)

func push_normal() -> void:
	teeeest = "push_normal"
	.push_normal()

func _override_changed():
	teeeest = "_override_changed"
	._override_changed()
