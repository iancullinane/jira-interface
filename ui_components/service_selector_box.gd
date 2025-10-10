extends PanelContainer
class_name ServiceSelectorBox

@onready var org: Label = %Org
@onready var repository: Label = %Repository

@export var item: String = ""

const HOVER_COLOR = Color.GREEN
var original_org_color: Color
var original_repo_color: Color

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if org:
		original_org_color = org.modulate
	if repository:
		original_repo_color = repository.modulate

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
	var scene = preload("res://ui_components/service_selector_box.tscn")
	var instance = scene.instantiate() as ServiceSelectorBox
	instance.set_values(org_name, repo_name)
	return instance

func set_values(org_name: String, repo_name: String) -> void:
	if org:
		org.text = org_name
	if repository:
		repository.text = repo_name

