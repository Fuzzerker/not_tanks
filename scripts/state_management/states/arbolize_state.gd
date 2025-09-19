class_name ArbolizeState
extends WanderState

 # Time between planting attempts
var planting_chance: float = 0.9

func _init(char: WorkingCharacter):
	super(char)
	wander_start = char.position

var returned_home = true

func execute() -> void:
	
	if not returned_home:
		if character.target_position != wander_start:
			character._set_target_position(wander_start)
		if _is_at_start_position():
			returned_home = true
	
	if returned_home:
		_arbolize_behavior()
	# First check if we need to return to starting position after resting
	#if character.stamina == character.max_stamina and not _is_at_start_position():
		#character._set_target_position(wander_start)
		#return
	#
	## If we're at start position and have stamina, begin arbolizing
	#if _is_at_start_position() and character.stamina > 0:
		#_arbolize_behavior()
	#else:
		## Fall back to normal wandering behavior
		#super.execute()

func on_enter() -> void:
	print("[%s] Entering Arbolize State" % character.character_name)
	if wander_start == character.position:
		returned_home = true
	else:
		returned_home = false

func on_exit() -> void:
	print("[%s] Exiting Arbolize State" % character.character_name)

func get_state_name() -> String:
	return "Arbolize"

func _is_at_start_position() -> bool:
	return character.position.distance_to(wander_start) < 10

func _arbolize_behavior() -> void:
	
	_try_plant_tree()
	
	# Continue wandering behavior
	super.execute()

func _try_plant_tree() -> void:
	# Random chance to plant a tree
	if randf() < planting_chance:
		print("_try_plant_tree")
		_plant_tree()

func _plant_tree() -> void:
	
	# Check if we have enough stamina
	if character.stamina <= 0:
		return
	
	# Drain stamina (similar to work state)
	character.stamina -= 10
	
	print("[%s] Planting a tree! Stamina: %d" % [character.character_name, character.stamina])
	
	# Get terrain gen reference
	var terrain_gen = character.terrain_gen
	if terrain_gen == null:
		push_warning("Cleric has no terrain_gen reference")
		return
	
	# Create tree marker at current position
	var marker = terrain_gen._make_icon(terrain_gen.tree_icon, terrain_gen.local_to_map(character.position))
	
	# Create and register the arbol
	var arbol = Arbol.new()
	arbol.marker = marker
	arbol.cell = terrain_gen.local_to_map(character.position)
	arbol.position = marker.position
	
	# Add to scene and register with plant manager
	terrain_gen.add_child(arbol)
	arbol.update_scale()
	PlantManager._register(arbol)
	
	print("[%s] Successfully planted tree at %s" % [character.character_name, character.position])
