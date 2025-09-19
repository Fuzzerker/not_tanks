extends "res://scripts/entities/characters/working_character.gd"

# Worker - Human character specialized in digging and planting
# Inherits all common working character functionality from WorkingCharacter

func _ready() -> void:
	super()
	TimeManager._register(_process_tick)
	

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.CLERIC
	
func _process_tick():
	super()
	var r = randi_range(1,3)
	if r == 2:
		var tg = WorkCallbackFactory._get_terrain_gen() as TerrainGen
		var marker = tg._make_icon(tg.tree_icon, tg.local_to_map(position))
		var arbol = Arbol.new()
		arbol.position = position
		arbol.marker = marker
		#place arbol
		return
