@tool
extends HBoxContainer

@onready var service_selector: OptionButton = $ServiceSelector
@onready var result_container: VBoxContainer = $ResultContainer

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
			# Populate the service_selector with source repositories
			print(service_data)
		elif json_result is Array:
			print(json_result) # Prints the array.
		else:
			printerr("Failed to parse static_data.json: Unexpected data format.")
		file.close()
	else:
		printerr("Failed to open static_data.json")


	service_selector.item_selected.connect(_on_ServiceSelector_item_selected)
	_on_ServiceSelector_item_selected(1)

func _on_ServiceSelector_item_selected(index):
	var selected_source_repo = service_selector.get_item_text(index)
	
	var log_string = "Selected source repository: " + selected_source_repo
	print(log_string)

	# Clear previous results
	for child in result_container.get_children():
		child.queue_free()

	if selected_source_repo.is_empty():
		return

	# Add link for the selected source repository
	var repo_url = service_data.get_github_repo_url(selected_source_repo)
	var link_instance = RICH_TEXT_LABEL_SCENE.instantiate()
	var rich_text = link_instance.get_node("MarginContainer/RichTextLabel")
	rich_text.bbcode_enabled = true
	rich_text.text = "[url=" + repo_url + "]" + selected_source_repo + " on GitHub[/url]"
	rich_text.fit_content = true
	rich_text.meta_clicked.connect(_on_link_meta_clicked)
	result_container.add_child(link_instance)
	
	# Add links for all config repositories
	for config_repo in service_data.config_repos:
		var config_repo_url = service_data.get_github_repo_url(config_repo)
		var config_link_instance = RICH_TEXT_LABEL_SCENE.instantiate()
		var config_rich_text = config_link_instance.get_node("MarginContainer/RichTextLabel")
		config_rich_text.bbcode_enabled = true
		config_rich_text.text = "[url=" + config_repo_url + "]" + config_repo + " Config[/url]"
		config_rich_text.fit_content = true
		config_rich_text.meta_clicked.connect(_on_link_meta_clicked)
		result_container.add_child(config_link_instance)

	print("added links")

func _on_link_meta_clicked(meta):
	OS.shell_open(meta)
