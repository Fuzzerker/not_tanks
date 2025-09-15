extends "res://scripts/entities/base/idler.gd"

var type: String = "cleric"
var character_name: String = ""

func _process(delta: float) -> void:
	pos_label.text = str(Vector2i(global_position))

	super(delta)

func _ready() -> void:
	character_name = NameGenerator._generate_name()
	super._ready()
	
	InformationRegistry._register(self)
	CharacterRegistry._add_character(self)


func _get_info() -> Dictionary:
	var inf: Dictionary = super()
	inf["character_name"] = character_name
	inf["type"] = type
	return inf

# Serialization methods
func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["character_name"] = character_name
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("character_name"):
		character_name = data.character_name
	
	# Re-register with managers after deserialization
	CharacterRegistry._add_character(self)
	InformationRegistry._register(self)
