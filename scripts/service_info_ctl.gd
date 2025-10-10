@tool
extends HBoxContainer

@onready var service_picker: VBoxContainer = %ServicePicker
@onready var result_container: VBoxContainer = $HSplitContainer/MarginContainer2/Panel/ResultContainer

const GITHUB_REPO_BASE_URL = "https://github.turbine.com/%s/%s"
const RICH_TEXT_LABEL_SCENE = preload("res://ui_components/rich_text_label.tscn")

var service_data: ServiceData


func _ready():
	var file = FileAccess.open("res://data/static_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if json_result is Dictionary:
			service_data = ServiceData.from_dictionary(json_result)
		elif json_result is Array:
			print(json_result) # Prints the array.
		else:
			printerr("Failed to parse static_data.json: Unexpected data format.")
		file.close()
	else:
		printerr("Failed to open static_data.json")

	_populate_service_selector()
	# service_selector.item_selected.connect(_on_ServiceSelector_item_selected)
	# _on_ServiceSelector_item_selected(1)



func _populate_service_selector() -> void:

	for child in service_picker.get_children():
		child.queue_free()

	for org in service_data.topology.keys():
		print("Organization: ", org)
		for repo in service_data.topology[org]:
			print("  - ", repo)
			var new_box = ServiceSelectorBox.create(org, repo)
			new_box.box_clicked.connect(_on_service_box_clicked)
			service_picker.add_child(new_box)



func _on_service_box_clicked(org_name: String, repo_name: String) -> void:
	for child in result_container.get_children():
		child.queue_free()

	var link_instance = RICH_TEXT_LABEL_SCENE.instantiate()
	var rich_text = link_instance.get_node("MarginContainer/RichTextLabel")
	rich_text.bbcode_enabled = true
	rich_text.text = org_name + "/" + repo_name
	rich_text.fit_content = true
	result_container.add_child(link_instance)

func _on_link_meta_clicked(meta):
	OS.shell_open(meta)
