extends Node

var work_requests: Array[WorkRequest] = []

func _has_work(cell: Vector2i) -> bool:
	for request in work_requests:
		if request.cell == cell:
			return true
	return false 

func _do_work(cell: Vector2i, effort: int) -> bool:
	for request in work_requests:
		if request.cell == cell:
			request.effort -= effort
			if request.effort <= 0 and request.on_complete.is_valid():
				work_requests.erase(request)
				request.on_complete.call()
				return true
			return false		
	return true
	
func _destroy_work(pos: Vector2):
	for rq in work_requests:
		if rq.position == pos:
			work_requests.erase(rq)
			rq.queue_free()
			return

func _add_work(request: WorkRequest) -> void:
	for rq in work_requests:
		if rq.cell == request.cell:
			return
	work_requests.push_back(request)

func _claim_work(position: Vector2) -> WorkRequest:
	var closest_request: WorkRequest = null
	var closest_dist := INF

	for request in work_requests:
		if request.status != "pending":
			continue
		var dist = position.distance_squared_to(request.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_request = request

	if closest_request:
		closest_request.status = "assigned"
	return closest_request
