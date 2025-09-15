extends Control

signal resume_game
signal quit_game

func _ready():
	# Connect button signals
	$Panel/VBoxContainer/MarginContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/VBoxContainer/MarginContainer2/QuitButton.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	resume_game.emit()

func _on_quit_pressed():
	quit_game.emit()

func show_menu():
	visible = true

func hide_menu():
	visible = false
