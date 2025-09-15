extends Control

signal resume_game
signal quit_game

@onready var save_name_input: LineEdit = $Panel/VBoxContainer/SaveLoadContainer/SaveNameContainer/SaveNameInput
@onready var saves_list: ItemList = $Panel/VBoxContainer/SaveLoadContainer/SavesList

func _ready():
	# Connect button signals
	$Panel/VBoxContainer/MarginContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/VBoxContainer/MarginContainer2/QuitButton.pressed.connect(_on_quit_pressed)
	$Panel/VBoxContainer/SaveLoadContainer/ButtonContainer/SaveButton.pressed.connect(_on_save_pressed)
	$Panel/VBoxContainer/SaveLoadContainer/ButtonContainer/LoadButton.pressed.connect(_on_load_pressed)
	
	# Connect saves list selection
	saves_list.item_selected.connect(_on_save_selected)

func _on_resume_pressed():
	resume_game.emit()

func _on_quit_pressed():
	quit_game.emit()

func _on_save_pressed():
	var save_name = save_name_input.text.strip_edges()
	if save_name.is_empty():
		_show_message("Please enter a save name!")
		return
	
	if SaveSystem.save_game(save_name):
		_show_message("Game saved successfully!")
		_refresh_saves_list()
		save_name_input.clear()
	else:
		_show_message("Failed to save game!")

func _on_load_pressed():
	var selected_items = saves_list.get_selected_items()
	if selected_items.is_empty():
		_show_message("Please select a save to load!")
		return
	
	var save_name = saves_list.get_item_text(selected_items[0])
	if SaveSystem.load_game(save_name):
		_show_message("Game loaded successfully!")
		resume_game.emit()  # Resume after loading
	else:
		_show_message("Failed to load game!")

func _on_save_selected(index: int):
	var save_name = saves_list.get_item_text(index)
	save_name_input.text = save_name

func _refresh_saves_list():
	saves_list.clear()
	var saves = SaveSystem.get_save_list()
	for save_name in saves:
		saves_list.add_item(save_name)

func _show_message(message: String):
	# For now, just print to console. In a real game, you might show a popup
	print("Save/Load Message: ", message)

func show_menu():
	visible = true
	_refresh_saves_list()

func hide_menu():
	visible = false
