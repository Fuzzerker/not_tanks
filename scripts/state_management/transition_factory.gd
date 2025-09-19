class_name ConditionFactory

# Create condition functions for common scenarios
static func stamina_low(character: WorkingCharacter, threshold: int = 0) -> Callable:
	return func() -> bool:
		return character.stamina <= threshold

static func stamina_full(character: WorkingCharacter) -> Callable:
	return func() -> bool:
		return character.stamina >= character.max_stamina

static func work_available(character: WorkingCharacter) -> Callable:
	return func() -> bool:
		return WorkQueue._claim_work(character.position, character.entity_type) != null

static func has_work_assigned(character: WorkingCharacter) -> Callable:
	return func() -> bool:
		return character.active_work != null

static func hunger_critical(character: WorkingCharacter, threshold: int = 20) -> Callable:
	return func() -> bool:
		return character.hunger <= threshold

static func at_work_location(character: WorkingCharacter, distance: float = 5.0) -> Callable:
	return func() -> bool:
		if character.active_work == null:
			return false
		return character.global_position.distance_to(character.active_work.position) <= distance

# Composite conditions
static func and_condition(conditions: Array[Callable]) -> Callable:
	return func() -> bool:
		#print("and_conditioning ", conditions.size())
		for condition in conditions:
			if not condition.call():
				#print("and condition failed, returning false")
				return false
		#print("all conditions true, returning true")
		return true

static func or_condition(conditions: Array[Callable]) -> Callable:
	return func() -> bool:
		for condition in conditions:
			if condition.call():
				return true
		return false
