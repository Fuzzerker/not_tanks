class_name RestState
extends State

var character: WorkingCharacter
var rest_location: Vector2 = Vector2.ZERO
var rest_timer: float = 0.0
var rest_duration: float = 1.0  # How often to restore stamina


func _init(char: WorkingCharacter):
	character = char

func execute() -> void:

	if character._has_arrived(10):
		_restore_stamina()
	else:
		character._move_toward()



func on_enter() -> void:
	character.target_position = character.house.position

func on_exit() -> void:
	print("[%s] Exiting Rest State" % character.entity_type)
	rest_location = Vector2.ZERO

func get_state_name() -> String:
	return "Rest"

func _restore_stamina() -> void:
	var stamina_gain = 10
	character.stamina += stamina_gain
	if character.stamina > character.max_stamina:
		character.stamina = character.max_stamina
	
	print("[%s] Restored %d stamina (now %d/%d)" % [
		character.character_name, 
		stamina_gain, 
		character.stamina, 
		character.max_stamina
	])
