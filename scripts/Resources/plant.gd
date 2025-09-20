extends "res://scripts/entities/base/savable.gd"

class_name Plant

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

var marker: Sprite2D
var cell: Vector2i

var health: int = 1
var max_health: int = 1000
var agua: int = 0
var agua_request_generated = false
var entity_type: EntityTypes.EntityType = EntityTypes.EntityType.CROP
var max_total_gro: int = 1000
var total_gro: int = 1
