@tool
extends PanelContainer
class_name ServiceGroupSeparator

const separator_scene: PackedScene = preload("res://ui_components/service_group_separator.tscn")

@onready var label: Label = %GroupName

@export var group_name: String = "":
	set(value):
		group_name = value
		if label:
			label.text = value

func _ready():
	if label and not group_name.is_empty():
		label.text = group_name

static func create(seperator_name: String) -> ServiceGroupSeparator:
	var new_separator: ServiceGroupSeparator = separator_scene.instantiate()
	new_separator.group_name = seperator_name
	return new_separator
