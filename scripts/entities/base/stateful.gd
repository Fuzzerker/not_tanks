extends "res://scripts/entities/base/mover.gd"


enum StateAction {
	IDLE,
	WORK,
	REST,
	EAT
	
}

enum State {
	MOVING,
	DOING,
}

var current_state: State = State.DOING
var current_state_action: StateAction = StateAction.IDLE
	

	
	
