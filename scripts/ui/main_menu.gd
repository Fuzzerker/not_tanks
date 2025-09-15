extends Control

# Called when the Play button is pressed
func _on_play_button_pressed():
	# Load the main game scene
	get_tree().change_scene_to_file("res://NotTanks.tscn")

# Called when the Quit button is pressed
func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
