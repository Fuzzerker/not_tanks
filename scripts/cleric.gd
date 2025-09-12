extends "res://preloads/idler.gd"


func _ready():
	super()
	CharacterRegistry._add_character({"ref":self, "type":"cleric"})
