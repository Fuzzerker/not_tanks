extends Sprite2D

var active_work = null
var effort = 10
var speed = 100.0 # units per second, tweak as needed

func _process(delta: float):
	if active_work:
		var dist = position.distance_squared_to(active_work.position)
		if dist > 0.3:
			_move_to_work(delta)
		else:
			_do_work()
	else:
		_find_work()


func _move_to_work(delta: float):
	# Smooth movement toward active_work.position
	var dir = (active_work.position - position).normalized()
	
	# Flip the sprite based on horizontal direction
	if dir.x > 0:
		flip_h = true  # Facing right
	elif dir.x < 0:
		flip_h = false   # Facing left
	
	position += dir * speed * delta


func _do_work():
	if WorkQueue._do_work(active_work.cell, effort):
		active_work = null
	# Optional: clear active_work if done
	# if WorkQueue._is_done(active_work.cell):
	#     active_work = null


func _find_work():
	active_work = WorkQueue._claim_work(position)
