class_name IdleState
extends WanderState

func _init(char: WorkingCharacter):
	super(char)

func get_state_name() -> String:
	return "Idle"
