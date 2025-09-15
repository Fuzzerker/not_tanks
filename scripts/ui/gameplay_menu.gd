extends Control

signal resume_game
signal quit_game
signal load_game(save_name: String)

@onready var save_name_input: LineEdit = $Panel/VBoxContainer/SaveLoadContainer/SaveNameContainer/SaveNameInput
@onready var saves_list: ItemList = $Panel/VBoxContainer/SaveLoadContainer/SavesList

func _ready() -> void:
	# Connect button signals
	$Panel/VBoxContainer/MarginContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/VBoxContainer/MarginContainer2/QuitButton.pressed.connect(_on_quit_pressed)
	$Panel/VBoxContainer/SaveLoadContainer/ButtonContainer/SaveButton.pressed.connect(_on_save_pressed)
	$Panel/VBoxContainer/SaveLoadContainer/ButtonContainer/LoadButton.pressed.connect(_on_load_pressed)
	
	# Connect saves list selection
	saves_list.item_selected.connect(_on_save_selected)

func _on_resume_pressed() -> void:
	resume_game.emit()

func _on_quit_pressed() -> void:
	quit_game.emit()

func _on_save_pressed() -> void:
	var save_name: String = save_name_input.text.strip_edges()
	if save_name.is_empty():
		return
	
	if SaveSystem.save_game(save_name):
		_refresh_saves_list()
		save_name_input.clear()

func _on_load_pressed() -> void:
	var selected_items: PackedInt32Array = saves_list.get_selected_items()
	if selected_items.is_empty():
		return
	
	var save_name: String = saves_list.get_item_text(selected_items[0])
	hide_menu()
	load_game.emit(save_name)  # Signal the main scene manager to handle the load

func _on_save_selected(index: int) -> void:
	var save_name: String = saves_list.get_item_text(index)
	save_name_input.text = save_name

func _refresh_saves_list() -> void:
	saves_list.clear()
	var saves: Array = SaveSystem.get_save_list()
	for save_name: String in saves:
		saves_list.add_item(save_name)


func show_menu() -> void:
	visible = true
	_refresh_saves_list()

func hide_menu() -> void:
	visible = false
