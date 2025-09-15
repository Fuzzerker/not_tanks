extends Node


var current_action: String = ""

# Serialize player actions data for saving
func serialize() -> Dictionary:
	return {
		"type": "player_actions",
		"current_action": current_action
	}

# Deserialize player actions data when loading
func deserialize(data: Dictionary) -> void:
	if data.has("current_action"):
		current_action = data.current_action
