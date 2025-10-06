@tool
extends Control

@onready var bg = $Bg
@onready var fg = $Fg
@onready var main_area = $Fg/MainArea
@onready var h_sorter = $Fg/MainArea/HSorter
@onready var text_edit = $Fg/MainArea/HSorter/TabContainer/InputTab
@onready var get_panel = $Fg/MainArea/HSorter/TabContainer/GetPanel
@onready var selectors = $Fg/MainArea/HSorter/SidePanel/Selectors
@onready var submit_btn = $Fg/MainArea/HSorter/SidePanel/SubmitBtn
@onready var jql_input = $Fg/MainArea/HSorter/TabContainer/GetPanel/VBoxContainer/LineEdit
@onready var issue_list_container = $Fg/MainArea/HSorter/TabContainer/GetPanel/VBoxContainer/ScrollContainer/IssueList

@onready var pillar_selector = $Fg/MainArea/HSorter/SidePanel/Selectors/Pillar
@onready var source_selector = $Fg/MainArea/HSorter/SidePanel/Selectors/Source

var selected_pillar_index: int = -1
var selected_source_index: int = -1


func _ready() -> void:

	submit_btn.pressed.connect(_on_submit_btn_pressed)
	
	# Connect to JiraService signals
	JiraService.issues_fetched.connect(_on_issues_fetched)
	JiraService.request_failed.connect(_on_request_failed)
	JiraService.request_started.connect(_on_request_started)
	
	var pillar_option := _get_option_button(pillar_selector)
	if pillar_option:
		pillar_option.item_selected.connect(_on_pillar_item_selected)
		selected_pillar_index = pillar_option.selected
	var source_option := _get_option_button(source_selector)
	if source_option:
		source_option.item_selected.connect(_on_source_item_selected)
		selected_source_index = source_option.selected


func _on_submit_btn_pressed() -> void:
	JiraService.fetch_issues(jql_input.text, 10, ["key", "summary"])


func _on_request_started() -> void:
	submit_btn.disabled = true
	submit_btn.text = "Loading..."


func _on_issues_fetched(work_items: Array[WorkItem]) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Submit"
	print("Received %d work items from JiraService" % work_items.size())
	_display_issues(work_items)


func _on_request_failed(error: String) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Submit"
	push_error("Jira request failed: %s" % error)


func _display_issues(work_items: Array[WorkItem]) -> void:
	# Clear existing work items
	for child in issue_list_container.get_children():
		child.queue_free()
	
	# Add work item cards
	for work_item in work_items:
		var card := _create_issue_card(work_item)
		issue_list_container.add_child(card)


func _create_issue_card(work_item: WorkItem) -> PanelContainer:
	var card := PanelContainer.new()
	var vbox := VBoxContainer.new()
	card.add_child(vbox)

	var title := Label.new()
	print("Creating card for work item: key='%s', summary='%s'" % [work_item.key, work_item.summary])
	title.text = work_item.get_display_title()
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	return card


func _on_pillar_item_selected(index: int) -> void:
	selected_pillar_index = index


func _on_source_item_selected(index: int) -> void:
	selected_source_index = index
	

func _get_option_button(parent: Node) -> OptionButton:
	for child in parent.get_children():
		if child is OptionButton:
			return child
	return null
