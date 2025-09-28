extends Control

const WorkItem = preload("res://scripts/work_item.gd")

@onready var margin_container: MarginContainer = $Margin

const CARD_MARGIN := 8
const TITLE_FONT_SIZE := 24
const CARD_MIN_HEIGHT := 80

func setup_work_items(work_items: Array[WorkItem]) -> void:
	_clear_existing_cards()
	_create_cards_display(work_items)

func _clear_existing_cards() -> void:
	for child in margin_container.get_children():
		child.queue_free()

func _create_cards_display(work_items: Array[WorkItem]) -> void:
	var vbox := VBoxContainer.new()
	vbox.set_custom_minimum_size(Vector2(0, CARD_MIN_HEIGHT * work_items.size()))
	margin_container.add_child(vbox)
	
	for work_item in work_items:
		if work_item.is_valid():
			var card := _create_single_card(work_item)
			vbox.add_child(card)

func _create_single_card(work_item: WorkItem) -> PanelContainer:
	var card := PanelContainer.new()
	card.set_custom_minimum_size(Vector2(0, CARD_MIN_HEIGHT))
	
	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", CARD_MARGIN)
	card_margin.add_theme_constant_override("margin_right", CARD_MARGIN)
	card_margin.add_theme_constant_override("margin_top", CARD_MARGIN)
	card_margin.add_theme_constant_override("margin_bottom", CARD_MARGIN)
	card.add_child(card_margin)
	
	var content := VBoxContainer.new()
	card_margin.add_child(content)
	
	var title := Label.new()
	title.text = work_item.get_display_title()
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(title)
	
	return card

