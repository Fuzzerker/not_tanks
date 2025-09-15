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
