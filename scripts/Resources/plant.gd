extends Node

class_name Plant

@export var marker: Sprite2D
@export var cell: Vector2i
@export var position: Vector2

var health = 1
var max_health = 100
var agua: int = 0
var type = "plant"
var max_total_gro = 100
var total_gro = 1
func _get_info():
	
	return {
		"health": health,
		"agua": agua,
		"cell":cell,
		"position":position,
	}

# Serialize plant data for saving
func serialize() -> Dictionary:
	return {
		"type": type,
		"health": health,
		"max_health": max_health,
		"agua": agua,
		"max_total_gro": max_total_gro,
		"total_gro": total_gro,
		"cell": {"x": cell.x, "y": cell.y},
		"position": {"x": position.x, "y": position.y}
	}

# Deserialize plant data when loading
func deserialize(data: Dictionary) -> void:
	if data.has("health"):
		health = data.health
	if data.has("max_health"):
		max_health = data.max_health
	if data.has("agua"):
		agua = data.agua
	if data.has("max_total_gro"):
		max_total_gro = data.max_total_gro
	if data.has("total_gro"):
		total_gro = data.total_gro
	if data.has("cell"):
		cell = Vector2i(data.cell.x, data.cell.y)
	if data.has("position"):
		position = Vector2(data.position.x, data.position.y)
