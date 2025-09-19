class_name State

# Interface for all states in the state machine
func execute() -> void:
	push_error("State.execute() must be implemented by subclass")

func on_enter() -> void:
	pass

func on_exit() -> void:
	pass

func get_state_name() -> String:
	push_error("IState.get_state_name() must be implemented by subclass")
	return ""
