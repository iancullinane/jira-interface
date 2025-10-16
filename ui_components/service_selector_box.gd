extends PanelContainer
class_name ServiceSelectorBox

signal box_clicked(box: ServiceSelectorBox)

const selector_scene: PackedScene = preload("res://ui_components/service_selector_box.tscn")

@onready var orgLabel: Label = %Org
@onready var repositoryLabel: Label = %Repository

# @export var item: String = ""

const HOVER_COLOR = Color.GREEN
var original_org_color: Color
var original_repo_color: Color
var _org_name: String = ""
var _repo_name: String = ""


var _org_name_switch: Dictionary = {
	"MGP-Server": "mgp",
	"Jupiter": "jup",
}

static func create(org_name: String, repo_name: String) -> ServiceSelectorBox:
	var new_box: ServiceSelectorBox = selector_scene.instantiate() as ServiceSelectorBox
	new_box._org_name = org_name
	new_box._repo_name = repo_name
	return new_box


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if orgLabel:
		original_org_color = orgLabel.modulate
		if not _org_name.is_empty():
			orgLabel.text = _get_display_org_name()
	if repositoryLabel:
		original_repo_color = repositoryLabel.modulate
		if not _repo_name.is_empty():
			repositoryLabel.text = _repo_name

func _on_mouse_entered():
	if orgLabel:
		orgLabel.modulate = HOVER_COLOR
	if repositoryLabel:
		repositoryLabel.modulate = HOVER_COLOR

func _on_mouse_exited():
	if orgLabel:
		orgLabel.modulate = original_org_color
	if repositoryLabel:
		repositoryLabel.modulate = original_repo_color

func _get_display_org_name() -> String:
	return _org_name_switch.get(_org_name, _org_name)

func set_values(org_name: String, repo_name: String) -> void:
	if orgLabel:
		orgLabel.text = org_name
	if repositoryLabel:
		repositoryLabel.text = repo_name

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		box_clicked.emit(self)

func get_full_name() -> String:
	return _org_name + "/" + _repo_name
