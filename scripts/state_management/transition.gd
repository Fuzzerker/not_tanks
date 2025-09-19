class_name Transition

var to_state: State
var condition: Callable
var description: String

func _init(target_state: State, condition_func: Callable, desc):
	to_state = target_state
	condition = condition_func 
	description = desc


func can_transition() -> bool:
	return condition.call()
