extends Node

var cleric_cost_mod: int = 2
var current_cleric_cost: int = 5

var current_num_worker: int = 1
var current_num_farmer: int = 1
var current_num_cutter: int = 1
var current_num_fighter: int = 1

func _buy_worker() -> bool:
	#if Resources.food < current_num_worker + 1:
		#return false
	Resources.food -= current_num_worker
	current_num_worker+=1
	return true

func _buy_farmer() -> bool:
	#if Resources.food < current_num_farmer + 1:
		#return false
	Resources.food -= current_num_farmer
	current_num_farmer+=1
	return true

func _buy_cutter() -> bool:
	#if Resources.food < current_num_cutter + 1:
		#return false
	Resources.food -= current_num_cutter
	current_num_cutter+=1
	return true

func _buy_fighter() -> bool:
	#if Resources.food < current_num_fighter + 1:
		#return false
	Resources.food -= current_num_fighter
	current_num_fighter+=1
	return true


func _buy_cleric() -> bool:
	#if Resources.agua < current_cleric_cost:
		#return false
	Resources.agua -= current_cleric_cost
	current_cleric_cost = current_cleric_cost * cleric_cost_mod
	return true
