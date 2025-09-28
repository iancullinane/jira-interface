extends Resource
class_name WorkItem

@export var id: String = ""
@export var key: String = ""
@export var summary: String = ""

func _init(data: Dictionary = {}) -> void:
	if not data.is_empty():
		id = data.get("id", "")
		key = data.get("key", "")
		summary = data.get("summary", "")


func get_display_title() -> String:
	return "%s: %s" % [key, summary]

func is_valid() -> bool:
	return not key.is_empty() and not summary.is_empty()
