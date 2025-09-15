extends Node

var work_requests: Array[WorkRequest] = []

func _has_work(cell: Vector2i) -> bool:
	for request: WorkRequest in work_requests:
		if request.cell == cell:
			return true
	return false 

func _do_work(cell: Vector2i, effort: int) -> bool:
	for request: WorkRequest in work_requests:
		if request.cell == cell:
			request.effort -= effort
			if request.effort <= 0 and request.on_complete.is_valid():
				work_requests.erase(request)
				request.on_complete.call()
				return true
			return false		
	return true
	
func _destroy_work(pos: Vector2) -> void:
	for rq: WorkRequest in work_requests:
		if rq.position == pos:
			work_requests.erase(rq)
			rq.queue_free()
			return

func _add_work(request: WorkRequest) -> void:
	for rq: WorkRequest in work_requests:
		if rq.cell == request.cell:
			print("Work request rejected - duplicate at cell ", request.cell)
			return
	work_requests.push_back(request)
	print("Work request added: type=", request.type, " cell=", request.cell, " total_requests=", work_requests.size())

func _claim_work(position: Vector2) -> WorkRequest:
	var closest_request: WorkRequest = null
	var closest_dist: float = INF

	for request: WorkRequest in work_requests:
		if request.status != "pending":
			continue
		var dist: float = position.distance_squared_to(request.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_request = request

	if closest_request:
		closest_request.status = "assigned"
	return closest_request

# Serialize work queue data for saving
func serialize() -> Dictionary:
	var serialized_requests: Array = []
	for request: WorkRequest in work_requests:
		if request.has_method("serialize"):
			serialized_requests.append(request.serialize())
	
	return {
		"type": "work_queue",
		"work_requests": serialized_requests
	}

# Deserialize work queue data when loading
func deserialize(data: Dictionary) -> void:
	print("WorkQueue deserialize called with ", data.get("work_requests", []).size(), " requests")
	# Clear existing work requests
	work_requests.clear()
	
	# Restore work requests
	if data.has("work_requests"):
		for request_data: Dictionary in data.work_requests:
			var request: WorkRequest = WorkRequest.new()
			request.deserialize(request_data)
			work_requests.append(request)
	
	print("WorkQueue now has ", work_requests.size(), " requests")

# Helper method for save system to clear all work requests
func _clear_all_work() -> void:
	work_requests.clear()
