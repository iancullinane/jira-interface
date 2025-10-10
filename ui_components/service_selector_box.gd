extends PanelContainer
class_name ServiceSelectorBox

signal box_clicked(org_name: String, repo_name: String)

const selector_scene: PackedScene = preload("res://ui_components/service_selector_box.tscn")

@onready var org: Label = %Org
@onready var repository: Label = %Repository

@export var item: String = ""

const HOVER_COLOR = Color.GREEN
var original_org_color: Color
var original_repo_color: Color
var _org_name: String = ""
var _repo_name: String = ""

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if org:
		original_org_color = org.modulate
		if not _org_name.is_empty():
			org.text = _org_name
	if repository:
		original_repo_color = repository.modulate
		if not _repo_name.is_empty():
			repository.text = _repo_name

func _on_mouse_entered():
	print("mouse entered")
	if org:
		org.modulate = HOVER_COLOR
	if repository:
		repository.modulate = HOVER_COLOR

func _on_mouse_exited():
	print("mouse exited")
	if org:
		org.modulate = original_org_color
	if repository:
		repository.modulate = original_repo_color

static func create(org_name: String, repo_name: String) -> ServiceSelectorBox:
	var new_box: ServiceSelectorBox = selector_scene.instantiate()
	new_box._org_name = org_name
	new_box._repo_name = repo_name
	return new_box

func set_values(org_name: String, repo_name: String) -> void:
	if org:
		org.text = org_name
	if repository:
		repository.text = repo_name

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		box_clicked.emit(_org_name, _repo_name)
