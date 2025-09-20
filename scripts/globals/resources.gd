extends Node


var agua: int = 0
var seeds: int = 5
var food: int = 0
var logs: int = 0
var sords: int = 0

# Serialize resources data for saving
func serialize() -> Dictionary:
	return {
		"type": "resources",
		"agua": agua,
		"seeds": seeds,
		"food": food,
		"logs": logs
	}

# Deserialize resources data when loading
func deserialize(data: Dictionary) -> void:
	if data.has("agua"):
		agua = data.agua
	if data.has("seeds"):
		seeds = data.seeds
	if data.has("food"):
		food = data.food
	if data.has("logs"):
		logs = data.logs
