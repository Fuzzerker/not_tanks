extends State

# Inactive state for undead creatures - they remain stationary until activated
class_name InactiveState

var character: Character

func _init(character_node: Character):
	character = character_node

func enter():
	# Undead creatures are inactive by default - no movement, no actions
	character.is_moving = false
	character.speed = 0.0

func execute():
	# Do nothing - undead creatures remain inactive
	pass

func exit():
	# When leaving inactive state, restore normal speed
	character.speed = character.base_speed
