extends Node

var cleric_cost_mod = 2
var current_cleric_cost = 5




func  _buy_cleric() -> bool:
	if Resources.agua < current_cleric_cost:
		return false
	Resources.agua -= current_cleric_cost
	current_cleric_cost = current_cleric_cost * cleric_cost_mod
	return true
