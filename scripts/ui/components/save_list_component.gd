class_name SaveListComponent
extends Control

signal save_selected(save_name: String)
signal save_double_clicked(save_name: String)

@onready var saves_list: ItemList

func _ready() -> void:
	# Try to find the ItemList child node
	saves_list = find_child("SavesList", true, false) as ItemList
	if not saves_list:
		# If not found, create one
		saves_list = ItemList.new()
		saves_list.name = "SavesList"
		add_child(saves_list)
	
	# Connect signals
	saves_list.item_selected.connect(_on_item_selected)
	saves_list.item_activated.connect(_on_item_activated)

func refresh_saves() -> void:
	saves_list.clear()
	var saves: Array = SaveSystem.get_save_list()
	
	if saves.is_empty():
		saves_list.add_item("No saves found")
		saves_list.set_item_disabled(0, true)
	else:
		for save_name: String in saves:
			saves_list.add_item(save_name)

func get_selected_save() -> String:
	var selected = saves_list.get_selected_items()
	return saves_list.get_item_text(selected[0]) if not selected.is_empty() else ""

func has_selected_save() -> bool:
	return not saves_list.get_selected_items().is_empty()

func clear_selection() -> void:
	saves_list.deselect_all()

func set_save_name_in_input(_save_name: String) -> void:
	# This is for components that have a save name input field
	# Will be called from parent components
	pass

func _on_item_selected(index: int) -> void:
	var save_name: String = saves_list.get_item_text(index)
	save_selected.emit(save_name)

func _on_item_activated(index: int) -> void:
	var save_name: String = saves_list.get_item_text(index)
	save_double_clicked.emit(save_name)
