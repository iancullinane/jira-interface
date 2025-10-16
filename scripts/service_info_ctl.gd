extends HBoxContainer

@onready var service_picker: VBoxContainer = %ServicePicker
# @onready var result_container: VBoxContainer = $HSplitContainer/MarginContainer2/ResultPanel/ResultContainer
@onready var svc_panel: SvcPanel = %ServiceResult

const GITHUB_REPO_BASE_URL = "https://github.turbine.com/%s/%s"
const RICH_TEXT_LABEL_SCENE = preload("res://ui_components/rich_text_label.tscn")
const MGP_SERVER_PATH = "/Users/iancullinane/dev/github.turbine.com/MGP-Server"
const SERVICE_SEPARATOR_SCENE = preload("res://ui_components/service_group_separator.tscn")

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

	# _populate_service_selector()
	_populate_service_selector_from_filesystem()
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

func _populate_service_selector_from_filesystem() -> void:
	for child in service_picker.get_children():
		child.queue_free()
	
	var dir = DirAccess.open(MGP_SERVER_PATH)
	if not dir:
		printerr("Failed to open directory: ", MGP_SERVER_PATH)
		return
		
	# Get all directories in MGP-Server
	var all_services = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			all_services.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Track which services have been added
	var added_services = []
	
	# Add services by group
	for group_name in service_data.service_groups.keys():
		# Add a separator for this group
		var separator = ServiceGroupSeparator.create(group_name.capitalize())
		service_picker.add_child(separator)
		
		# Add services that belong to this group
		var group_services = service_data.service_groups[group_name]
		for service_name in group_services:
			if service_name in all_services:
				var new_box = ServiceSelectorBox.create("MGP-Server", service_name)
				new_box.box_clicked.connect(_on_service_box_clicked)
				service_picker.add_child(new_box)
				added_services.append(service_name)
	
	# Add remaining services under "Other Services"
	var remaining_services = []
	for service_name in all_services:
		if not service_name in added_services:
			remaining_services.append(service_name)
	
	if remaining_services.size() > 0:
		# Add separator for "Other Services"
		var other_separator = ServiceGroupSeparator.create("Other Services")
		service_picker.add_child(other_separator)
		
		# Add the remaining services
		for service_name in remaining_services:
			var new_box = ServiceSelectorBox.create("MGP-Server", service_name)
			new_box.box_clicked.connect(_on_service_box_clicked)
			service_picker.add_child(new_box)



func _on_service_box_clicked(box: ServiceSelectorBox) -> void:
	svc_panel.update_panel(box)

func _on_link_meta_clicked(meta):
	OS.shell_open(meta)
