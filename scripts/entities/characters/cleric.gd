extends "res://scripts/entities/base/idler.gd"

var type = "cleric"
var character_name = ""

func _process(delta: float):
	pos_label.text = str(Vector2i(global_position))

	super(delta)

func _ready():
	character_name = NameGenerator._generate_name()
	super._ready()
	
	InformationRegistry._register(self)
	CharacterRegistry._add_character(self)


func _get_info():
	var inf = super()
	inf["character_name"] = character_name
	inf["type"] = type
	return inf
