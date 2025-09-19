extends Node


var _time_accumulator: float = 0.0
var _tick_time: float = .5

var _on_ticks:Array = []

func _register(on_tick):
	print("registering tick")
	_on_ticks.push_back(on_tick)


func _process(delta) -> void:
	# delta is already scaled by Engine.time_scale
	_time_accumulator += delta
	
	if _time_accumulator >= _tick_time:
		#print("ticking")
		_time_accumulator -= _tick_time
		for on_tick in _on_ticks:
			on_tick.call()
