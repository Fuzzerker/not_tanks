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

#func _ready() -> void:
	#super()
	#InformationRegistry._register(self)
	#TimeManager._register(_process_tick)
	#
#
#func _get_info() -> Dictionary:
	#var info: Dictionary = super()
	#info["max_health"] = max_health
	#info["health"] = health
	#info["hunger"] = hunger
	#info["hungry_interval"] = hungry_interval
	#info["hunger_threshold"] = hunger_threshold
	#return info
#
#func _process_tick(delta: float) -> bool:
	#pos_label.text = str(Vector2i(global_position))
	#_update_hunger_and_health(delta)
	#
	#if health <= 0:
		#_die()	
		#return true
	#else: if hunger < hunger_threshold:
		#_handle_hunger(delta)
		#return true
		#
	#return false
		#
#
		#
#
## Virtual method to be overridden by subclasses
#func _handle_hunger(_delta: float) -> void:
	#pass
#
## Virtual method to be overridden by subclasses  
#func _eat(_food) -> void:
	#pass
#
#func _update_hunger_and_health(delta: float) -> void:
	#_time_accumulator += delta
	#
	#if _time_accumulator >= hungry_interval:
		#_time_accumulator -= hungry_interval
		#hunger -= 1
		#
		## Prevent hunger from going below 0
		#if hunger <= 0:
			#hunger = 0
			#health -= 1
		#
		## Regenerate health when well-fed
		#if hunger > 3:
			#health += 1
			#if health > max_health:
				#health = max_health
#
#func _die() -> void:
	#queue_free()
#
## Serialization methods
#func serialize() -> Dictionary:
	#var data: Dictionary = super.serialize()
	#data["max_health"] = max_health
	#data["health"] = health
	#data["hunger"] = hunger
	#data["hungry_interval"] = hungry_interval
	#data["hunger_threshold"] = hunger_threshold
	#data["entity_type"] = EntityTypes.type_to_string(entity_type)
	#data["_time_accumulator"] = _time_accumulator
	#return data
#
#func deserialize(data: Dictionary) -> void:
	#super.deserialize(data)
	#if data.has("max_health"):
		#max_health = data.max_health
	#if data.has("health"):
		#health = data.health
	#if data.has("hunger"):
		#hunger = data.hunger
	#if data.has("hungry_interval"):
		#hungry_interval = data.hungry_interval
	#if data.has("hunger_threshold"):
		#hunger_threshold = data.hunger_threshold
	#if data.has("entity_type"):
		#entity_type = EntityTypes.string_to_type(data.entity_type)
	#elif data.has("type"):  # Legacy compatibility
		#entity_type = EntityTypes.string_to_type(data.type)
	#if data.has("_time_accumulator"):
		#_time_accumulator = data._time_accumulator
