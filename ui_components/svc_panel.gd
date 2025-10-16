extends Panel
class_name SvcPanel

@onready var svcNameLabel: Label = %SvcName
@onready var SvcButtons: HBoxContainer = %SvcButtons


const svc_panel_scene: PackedScene = preload("res://ui_components/svc_panel.tscn")

static func create(input_box: ServiceSelectorBox) -> SvcPanel:
	var new_panel: SvcPanel = svc_panel_scene.instantiate() as SvcPanel
	new_panel.svcNameLabel.text = input_box.get_full_name()
	return new_panel

func update_panel(input_box: ServiceSelectorBox) -> void:
	svcNameLabel.text = input_box.get_full_name()
