extends Resource
class_name WorkRequest

var type: String
var cell: Vector2i
var position: Vector2
var status: String = "pending"
var effort: int
var marker: Sprite2D = null
var marker_path: String

func _init(_type: String, _cell: Vector2i, _position: Vector2, _marker_path: String = "", _effort: int = 100):
	type = _type
	cell = _cell
	position = _position
	marker_path = _marker_path
	effort = _effort

	if marker_path != "":
		marker = load(marker_path).instantiate() as Sprite2D
		WorkCallbackFactory._get_terrain_gen().add_child(marker)
		marker.position = position

	WorkQueue._add_work(self)
