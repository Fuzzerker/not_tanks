extends Node

# Scene Manager - Handles loading/unloading of game scenes

@onready var scene_container: Node = $SceneContainer
var current_scene: Node = null

const GAME_SCENE_PATH: String = "res://NotTanks.tscn"
const MENU_SCENE_PATH: String = "res://main_menu.tscn"

func _ready() -> void:
	# Main menu is already loaded as a child, set it as current
	current_scene = $SceneContainer/MainMenu
	

# Load a new scene, optionally with save data
func load_scene(scene_path: String, save_name: String = "") -> Node:
	# Remove current scene
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	# Load and add new scene
	var scene_resource: PackedScene = load(scene_path)
	var new_scene: Node = scene_resource.instantiate()
	scene_container.add_child(new_scene)
	current_scene = new_scene
	
	return new_scene

# Signal handlers from main menu
func _on_new_game() -> void:
	load_scene(GAME_SCENE_PATH)

func _on_load_game(save_name: String) -> void:
	# Load the game scene first
	var ne_scene: Node = load_scene(GAME_SCENE_PATH)
	
	if not ne_scene.is_node_ready():
		await ne_scene.ready
	
	# Get the terrain generator and load the save directly
	var terrain_gen: Node = current_scene.get_node("TileMapLayer")
	if terrain_gen and terrain_gen.has_method("load_game_save"):
		var success: bool = terrain_gen.load_game_save(save_name)
		if not success:
			push_error("Failed to load game save: " + save_name)
	else:
		push_error("Could not find terrain generator in NotTanks scene")

# Called from game to return to main menu
func return_to_menu() -> void:
	load_scene(MENU_SCENE_PATH)
