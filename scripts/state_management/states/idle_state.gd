class_name IdleState
extends WanderState

func _init(char: Character):
	super(char)

func get_state_name() -> String:
	return "Idle"
