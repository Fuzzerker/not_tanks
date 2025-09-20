extends "res://scripts/entities/base/mover.gd"

# Base class for all living entities with health and hunger systems

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

# Speed scaling based on stamina
var base_speed: float = 100.0
var min_speed: float = 10.0
var stamina: int = 1000
var max_stamina: int = 1000
var max_health: int = 100
var health: int = 100
var hunger: int = 100
var hungry_interval: float = 1.0
var hunger_threshold: int = 50  
var entity_type: EntityTypes.EntityType
# Internal timer for hunger decay
var _time_accumulator: float = 0.0
var _entity_scene = null
# Eating system
var eating_distance: float = 5.0

var custom_wander_start = null
