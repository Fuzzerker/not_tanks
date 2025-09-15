extends Control

signal new_game
signal load_game(save_name: String)

@onready var load_dialog: AcceptDialog = $LoadGameDialog
@onready var saves_list: ItemList = $LoadGameDialog/VBoxContainer/SavesList

func _ready() -> void:
	# Connect the existing ItemList signals directly
	saves_list.item_activated.connect(_on_saves_list_item_activated)

# Called when the Play button is pressed
func _on_play_button_pressed() -> void:
	new_game.emit()

# Called when the Load Game button is pressed
func _on_load_button_pressed() -> void:
	_refresh_saves_list()
	load_dialog.popup_centered()

# Called when the Quit button is pressed
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Called when Load Selected button is pressed
func _on_load_selected_pressed() -> void:
	var selected_items: PackedInt32Array = saves_list.get_selected_items()
	if selected_items.is_empty():
		return
	
	var save_name: String = saves_list.get_item_text(selected_items[0])
	_load_game(save_name)

# Called when Cancel button is pressed
func _on_cancel_load_pressed() -> void:
	load_dialog.hide()

# Called when an item in the saves list is double-clicked
func _on_saves_list_item_activated(index: int) -> void:
	var save_name: String = saves_list.get_item_text(index)
	_load_game(save_name)

# Load a specific save game
func _load_game(save_name: String) -> void:
	load_dialog.hide()
	load_game.emit(save_name)

# Refresh the list of available saves
func _refresh_saves_list() -> void:
	saves_list.clear()
	var saves: Array = SaveSystem.get_save_list()
	if saves.is_empty():
		saves_list.add_item("No saves found")
		saves_list.set_item_disabled(0, true)
	else:
		for save_name: String in saves:
			saves_list.add_item(save_name)
