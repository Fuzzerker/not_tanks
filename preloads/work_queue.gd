extends Node

var work_requests: Array = []

func _has_work(cell) -> bool:
	for request in work_requests:
		if request.cell == cell:
			return true
	return false 

func _do_work(cell, effort) -> bool:
	for request in work_requests:
		if request.cell == cell:
			request.effort -= effort
			if request.effort <= 0 and request["on_complete"] != null:				
				work_requests.erase(request)
				request["on_complete"].call()
				
				return true
	return false

func _add_work(request):
	
		
	for rq in work_requests:
		if rq.cell == request.cell:
			return
	work_requests.push_back(request)


func _claim_work(position: Vector2):
	if work_requests.is_empty():
		return null

	var closest_request = null
	var closest_dist = INF

	for request in work_requests:
		if request.status != "pending":
			continue
		var dist = position.distance_squared_to(request.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_request = request

	if closest_request:
		closest_request.status = "Assigned"
		return closest_request

	return null
	
