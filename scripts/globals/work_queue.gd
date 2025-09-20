extends Node

# Import required classes
const EntityTypes = preload("res://scripts/globals/entity_types.gd")
const JobCapabilities = preload("res://scripts/globals/job_capabilities.gd")

var work_requests: Array[WorkRequest] = []

func flush():
	work_requests = []

func _has_work(cell: Vector2i) -> bool:
	for request: WorkRequest in work_requests:
		if request.cell == cell:
			return true
	return false



func _abandon_work(cell):
	for request: WorkRequest in work_requests:
		if request.cell == cell:
			request.status = "pending"
	
func _complete_work(request):
	print("completing request")
	work_requests.erase(request)
	request.queue_free()


	
func _destroy_work(pos: Vector2) -> void:
	for rq: WorkRequest in work_requests:
		if rq.position == pos:
			work_requests.erase(rq)
			rq.queue_free()
			return

# Remove all chop jobs for a specific arbol (when arbol is destroyed)
#func _destroy_chop_work_for_arbol(arbol_id: int) -> void:
	#var requests_to_remove: Array[WorkRequest] = []
	#for request: WorkRequest in work_requests:
		#if request.type == "chop" and request.command_data.has("arbol_id"):
			#if request.command_data.arbol_id == arbol_id:
				#requests_to_remove.append(request)
	#
	## Remove all matching requests and clean up their markers
	#for request in requests_to_remove:
		#work_requests.erase(request)
		## Clean up any markers (though they should already be cleaned up by the callback)
		#if request.command_data.has("marker_path"):
			#var terrain_gen = _get_terrain_gen()
			#if terrain_gen:
				#var marker = terrain_gen.get_node_or_null(request.command_data.marker_path)
				#if marker:
					#marker.queue_free()

# Helper to get terrain generator
func _get_terrain_gen():
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree.current_scene:
		return null
	return scene_tree.current_scene.find_child("TileMapLayer")

func _add_work(request: WorkRequest) -> void:
	for rq: WorkRequest in work_requests:
		if rq.cell == request.cell:
			#print("request rejected.  Request at cell already ", rq.type)
			return
	#print("adding request ", request.type)
	work_requests.push_back(request)
	
	
func _claim_work_not_of_types(position: Vector2, character_type: EntityTypes.EntityType, work_types: Array[String] ) -> WorkRequest:
	
	var closest_node = SpatialUtils.find_closest_entity(
		work_requests, 
		position, 
		func(request): 
			#print("status ", request.status, " can do ", JobCapabilities.can_do_work(character_type, request.type), " ch type ", character_type, " rq type ", request.type)
			return request.status == "pending" and not work_types.has(request.type) and JobCapabilities.can_do_work(character_type, request.type)
	)
	var closest_request = closest_node as WorkRequest
	
	if closest_request:
		closest_request.status = "assigned"
		#print("assigning work_type ", work_type, "work_requests ", work_requests.size())
	return closest_request	
	
	
func _claim_work_of_type(position: Vector2,  work_type: String ) -> WorkRequest:
	
	var closest_node = SpatialUtils.find_closest_entity(
		work_requests, 
		position, 
		func(request): 
			#print("status ", request.status, " can do ", JobCapabilities.can_do_work(character_type, request.type), " ch type ", character_type, " rq type ", request.type)
			return request.status == "pending" and request.type == work_type
	)
	var closest_request = closest_node as WorkRequest
	
	if closest_request:
		closest_request.status = "assigned"
		print("assigning work_type ", work_type, "work_requests ", work_requests.size())
	return closest_request	


func _claim_work(position: Vector2, character_type: EntityTypes.EntityType = EntityTypes.EntityType.WORKER) -> WorkRequest:
	#print("_claim_work ",character_type )
	var closest_node = SpatialUtils.find_closest_entity(
		work_requests, 
		position, 
		func(request): 
			#print("status ", request.status, " can do ", JobCapabilities.can_do_work(character_type, request.type), " ch type ", character_type, " rq type ", request.type)
			return request.status == "pending" and JobCapabilities.can_do_work(character_type, request.type)
	)
	var closest_request = closest_node as WorkRequest
	
	if closest_request:
		closest_request.status = "assigned"
		print("assigning work to character_type ", character_type, "work_requests ", work_requests.size(), " closest_request ", closest_request.type)
	return closest_request

# Claim work of a specific type
func _claim_specific_work(position: Vector2, work_type: String, character_type: EntityTypes.EntityType = EntityTypes.EntityType.WORKER) -> WorkRequest:
	var closest_node = SpatialUtils.find_closest_entity(
		work_requests, 
		position, 
		func(request): 
			return request.status == "pending" and request.type == work_type and JobCapabilities.can_do_work(character_type, request.type)
	)
	var closest_request = closest_node as WorkRequest
	
	if closest_request:
		closest_request.status = "assigned"
	return closest_request
