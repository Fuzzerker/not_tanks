extends "res://scripts/entities/base/mover.gd"

# Base class for all living entities with health and hunger systems

const EntityTypes = preload("res://scripts/globals/entity_types.gd")


var max_health: int = 100
var health: int = 100
var hunger: int = 100
var hungry_interval: float = 1.0
var hunger_threshold: int = 50  
var entity_type: EntityTypes.EntityType
# Internal timer for hunger decay
var _time_accumulator: float = 0.0
var _entity_scene = null
