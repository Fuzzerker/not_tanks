
class_name StateTransition

var state_name: String = ""
var transitions: Array[Transition] = []

func _init(state_name: String, transitions: Array[Transition]):
	self.state_name = state_name
	self.transitions = transitions
