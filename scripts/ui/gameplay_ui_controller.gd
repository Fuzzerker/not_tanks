extends Control

# UI state management for Work/Place toggle system
enum UIMode {
	NONE,
	WORK,
	PLACE
}

var current_mode: UIMode = UIMode.NONE

# References to UI groups
@onready var main_buttons: HBoxContainer = $VBoxContainer/MainButtons
@onready var work_group: VBoxContainer = $VBoxContainer/HBoxContainer/WorkGroup
@onready var place_group: VBoxContainer = $VBoxContainer/HBoxContainer/PlaceGroup

# Main toggle buttons
@onready var work_button: Button = $VBoxContainer/MainButtons/WorkButton
@onready var place_button: Button = $VBoxContainer/MainButtons/PlaceButton

func _ready() -> void:
	# Connect main toggle buttons
	work_button.pressed.connect(_on_work_button_pressed)
	place_button.pressed.connect(_on_place_button_pressed)
	
	# Initially hide both groups
	_set_mode(UIMode.NONE)

func _on_work_button_pressed() -> void:
	if current_mode == UIMode.WORK:
		_set_mode(UIMode.NONE)  # Toggle off if already active
	else:
		_set_mode(UIMode.WORK)

func _on_place_button_pressed() -> void:
	if current_mode == UIMode.PLACE:
		_set_mode(UIMode.NONE)  # Toggle off if already active
	else:
		_set_mode(UIMode.PLACE)

func _set_mode(mode: UIMode) -> void:
	current_mode = mode
	
	# Update button states
	work_button.button_pressed = (mode == UIMode.WORK)
	place_button.button_pressed = (mode == UIMode.PLACE)
	
	# Show/hide appropriate groups
	work_group.visible = (mode == UIMode.WORK)
	place_group.visible = (mode == UIMode.PLACE)
	
	# Cancel any current action when switching modes
	if mode != UIMode.NONE:
		_cancel_current_action()

func _cancel_current_action() -> void:
	# Get terrain generator and cancel current action
	var terrain_gen = get_node("../../TileMapLayer")
	if terrain_gen and terrain_gen.has_method("_cancel_action"):
		terrain_gen._cancel_action()
