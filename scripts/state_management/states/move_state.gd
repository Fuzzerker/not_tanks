class_name MoveState
extends State

var character: WorkingCharacter
var target_position: Vector2 = Vector2.ZERO
var arrival_distance: float = 5.0

func _init(char: WorkingCharacter):
	character = char
	

func execute() -> void:
	if target_position == Vector2.ZERO:
		return
	
	# Move toward target
	var distance_to_target = character.global_position.distance_to(target_position)
	if distance_to_target > arrival_distance:
		character._set_target_position(target_position)
	else:
		# We've arrived
		target_position = Vector2.ZERO

func on_enter() -> void:
	print("[%s] Entering Move State" % character.character_name)

func on_exit() -> void:
	print("[%s] Exiting Move State" % character.character_name)
	target_position = Vector2.ZERO

func get_state_name() -> String:
	return "Move"

func set_target(pos: Vector2):
	target_position = pos
