extends Resource

class_name WorkRequest

@export var type: String
@export var cell: Vector2i
@export var position: Vector2
@export var status: String = "pending"
@export var effort: int = 100
var on_complete: Callable = Callable()
