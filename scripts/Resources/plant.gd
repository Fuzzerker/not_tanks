extends Node

class_name Plant

@export var marker: Sprite2D
@export var cell: Vector2i
@export var position: Vector2

var current_phase: int = 0
var final_phase: int = 4
var current_gro: int = 0
var gro_required: int = 10
var aqua: int = 0
var type = "plant"

func _get_info():
	
	return {
		"gro": str(current_gro) +"/"+str(gro_required),
		"phase": str(current_phase) +"/"+str(final_phase),
		"aqua": aqua,
		"cell":cell,
		"position":position,
	}
