extends Label


func _process(delta: float) -> void:
	text = str(Engine.time_scale)
