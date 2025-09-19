extends "res://scripts/entities/base/living_entity.gd"
class_name WorkingCharacter
# Basic character properties
var character_name: String = ""

# Stamina system
var effort: int = 100
var stamina: int = 10000
var max_stamina: int = 1000

# Speed scaling based on stamina
var base_speed: float = 100.0
var min_speed: float = 10.0

# Eating system
var eating_distance: float = 5.0

# State machine
var state_machine: StateMachine

# Work system (simplified - just holds current work)
var active_work: WorkRequest = null
var last_work: WorkRequest = null
var house: Building = null
var terrain_gen: TerrainGen = null

func _ready() -> void:
	character_name = NameGenerator._generate_name()
	base_speed = 1000.0
	var root = get_tree().root
	#print("root ", root, " child ", root.get_child(0), " grandchild ", root.get_child(0).get_child(0))
	terrain_gen = root.get_node("/root/Main/SceneContainer/Node2D/TileMapLayer") as TerrainGen
	#_update_speed()
	_setup_character_type()
	CharacterRegistry._add_character(self)
	TimeManager._register(_process_tick)
	
	# Initialize state machine based on character type
	_setup_state_machine()
	super()

	
func _process_tick():
	if state_machine != null:
		state_machine.execute()

func _setup_character_type() -> void:
	# Override in subclasses to set entity_type
	pass

func _setup_state_machine() -> void:
	# Override in subclasses to set up character-specific state machine
	var tml = Engine.get_main_loop().current_scene.find_child("TileMapLayer")
	
	state_machine = WorkerStateMachine.new(self, tml)
	

#func _update_speed() -> void:
	#if max_stamina <= 0:
		#speed = base_speed
		#return
	#
	#var stamina_percentage: float = (float(stamina) / float(max_stamina)) * 100.0
	#
	#if stamina_percentage <= 0.0:
		#speed = min_speed
	#elif stamina_percentage <= 50.0:
		#speed = base_speed * 0.5
	#else:
		#speed = base_speed

func _get_info() -> Dictionary:
	return {}
	#var info: Dictionary = super()
	#info["character_name"] = character_name
	#info["entity_type"] = EntityTypes.type_to_string(entity_type)
	#info["effort"] = effort
	#info["stamina"] = stamina
	#info["max_stamina"] = max_stamina
	#info["speed"] = speed
	#info["base_speed"] = base_speed
	#info["speed_ratio"] = "%.1f%%" % ((speed / base_speed) * 100.0)
	#
	## Add state machine debug info
	#if state_machine != null:
		#info["state_machine"] = state_machine.get_debug_info()
	#
	#return info

# Serialization methods
func serialize() -> Dictionary:
	return {}
	#var data: Dictionary = super.serialize()
	#data["character_name"] = character_name
	#data["entity_type"] = EntityTypes.type_to_string(entity_type)
	#data["effort"] = effort
	#data["stamina"] = stamina
	#data["max_stamina"] = max_stamina
	#data["base_speed"] = base_speed
	#data["min_speed"] = min_speed
	#data["eating_distance"] = eating_distance
	#
	## Note: active_work and state_machine are not serialized as they're runtime references
	#return data

#func deserialize(data: Dictionary) -> void:
	#super.deserialize(data)
	#if data.has("character_name"):
		#character_name = data.character_name
	#if data.has("entity_type"):
		#entity_type = EntityTypes.string_to_type(data.entity_type)
	#if data.has("effort"):
		#effort = data.effort
	#if data.has("stamina"):
		#stamina = data.stamina
	#if data.has("max_stamina"):
		#max_stamina = data.max_stamina
	#if data.has("base_speed"):
		#base_speed = data.base_speed
	#if data.has("min_speed"):
		#min_speed = data.min_speed
	#if data.has("eating_distance"):
		#eating_distance = data.eating_distance
	#
	## Update speed based on loaded stamina
	#_update_speed()
	#
	## Re-register with managers after deserialization
	#CharacterRegistry._add_character(self)
	#InformationRegistry._register(self)
	#
	## Reinitialize state machine
	#_setup_state_machine()
