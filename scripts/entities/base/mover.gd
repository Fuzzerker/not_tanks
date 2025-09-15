extends Sprite2D

var speed: float = 100.0
var target_position: Vector2
var log: bool = false
var pos_label: Label
func _get_info() -> Dictionary:
	return {
		"speed":speed,
		"target_position":target_position
	}

func _ready() -> void:
	_generate_label()
	

func _generate_label() -> void:
	# Create the label
	pos_label = Label.new()
	pos_label.name = "PosLabel"
	pos_label.modulate = Color.WHITE
	pos_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	
	# Optional: make the label easier to read
	pos_label.add_theme_color_override("font_color", Color.BLACK)
	
	# Attach to this sprite
	add_child(pos_label)
	
	# Move the label slightly above the sprite
	pos_label.position = Vector2(0, -texture.get_height() / 2 - 10)

func _move_toward(delta: float) -> void:
	var direction: Vector2 = target_position - position
	var distance: float = direction.length()
	
	if distance > 0.01:
		# Flip sprite based on horizontal direction
		flip_h = direction.x > 0

		# Smooth movement
		position += direction.normalized() * speed * delta

func _has_arrived(threshold: float) -> bool:
	threshold *= Engine.time_scale
	var has_arrived: bool = position.distance_squared_to(target_position) < threshold * threshold
	return has_arrived

# Serialization methods
func serialize() -> Dictionary:
	var data = SerializationUtils.serialize_mover_data(self)
	data["log"] = log
	return data

func deserialize(data: Dictionary) -> void:
	SerializationUtils.deserialize_mover_data(self, data)
	if data.has("log"):
		log = data.log
