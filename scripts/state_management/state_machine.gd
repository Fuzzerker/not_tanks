class_name StateMachine


var current_state: State = null
var previous_state: State = null
var state_transitions: Array[StateTransition] = [] # State -> Array[Transition]
var any_transitions: Array[Transition] = []
var state_history: Array[String] = []
var max_history: int = 10



# Add a transition from one state to another
func add_transition(from_state: State, to_state: State, condition: Callable, description: String):
	var transition = Transition.new(to_state, condition, description)
	var state_name = ""
	if from_state != null:
		state_name = from_state.get_state_name()
	
	var state_transition = _ensure_state_tranistion(state_name)
	state_transition.transitions.append(transition)
	for s_t in state_transitions:
		if s_t.state_name == transition.to_state.get_state_name():
			s_t = state_transition
	
func _ensure_state_tranistion(state_name: String) -> StateTransition:
	var t = _get_state_transition(state_name)
	if t == null:
		t = StateTransition.new(state_name, [])
		state_transitions.append(t)
	return t

func _get_state_transition(state_name: String) -> StateTransition:
	for t in state_transitions:
		if t.state_name == state_name:
			return t
	return null
			


# Add a transition that can happen from any state
func add_any_transition(to_state: State, condition: Callable, reason:String):
	var transition = Transition.new(to_state, condition, reason)
	any_transitions.append(transition)

# Set the initial state
func set_state(new_state: State, reason:String):
	if new_state == current_state:
		return
	if current_state != null:
		print("transitioning from ", current_state.get_state_name(), 
		" to ", new_state.get_state_name(), " because ", reason)
	# Exit current state
	if current_state != null:
		current_state.on_exit()
		previous_state = current_state
	
	# Enter new state
	current_state = new_state
	current_state.on_enter()

# Execute the state machine (call this every frame)
func execute():
	var current_state_name = ""
	if current_state != null:
		current_state_name = current_state.get_state_name()
	# Check for transitions
	#print("execute trasition check ", current_state_name)
	var transition = _get_transition()
	if transition != null:
		set_state(transition.to_state, transition.description)
		return
	#print("execute ", current_state.get_state_name())
	# Execute current state
	#print("state machine execute ", current_state.get_state_name()) 
	current_state.execute()

# Get the next transition to take
func _get_transition() -> Transition:

	# Check any transitions first (highest priority)
	for transition in any_transitions:
		if transition.can_transition():
			return transition
	
	var state_name = ""
	if current_state != null:
		state_name = current_state.get_state_name()
	# Check state-specific transitions
	
	var state_transition = _get_state_transition(state_name)
	if state_transition != null:
		for transition in state_transition.transitions:
			if transition.can_transition():
				return transition				 
	return null

func _add_to_history(event: String):
	state_history.append(event)
	if state_history.size() > max_history:
		state_history.pop_front()

func get_debug_info() -> Dictionary:
	return {
		"current_state": current_state.get_state_name() if current_state else "None",
		"previous_state": previous_state.get_state_name() if previous_state else "None",
		"history": state_history
	}
