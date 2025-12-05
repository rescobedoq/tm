extends Node

var costs := {
	"worker": {"gold": 1, "resources": 0, "upkeep": 1},
	"train_soldier": {"gold": 1, "resources": 0, "upkeep": 1},
	"train_archer": {"gold": 1, "resources": 25, "upkeep": 1},
	"train_cavalry": {"gold": 1, "resources": 50, "upkeep": 2},
	"train_dragon": {"gold": 1, "resources": 200, "upkeep": 5},
	"train_druid": {"gold": 1, "resources": 50, "upkeep": 2},
	"train_golem": {"gold": 1, "resources": 100, "upkeep": 3},
	"train_magic_soldier": {"gold": 1, "resources": 60, "upkeep": 2},
	"train_sorcerer": {"gold": 1, "resources": 80, "upkeep": 3},

	# Barcos
	"build_ship": {"gold": 200, "resources": 100, "upkeep": 2},
	"build_ship_kraken": {"gold": 500, "resources": 300, "upkeep": 4},
	"build_ship_ghost": {"gold": 400, "resources": 250, "upkeep": 3}
}

func get_cost(unit_type: String) -> Dictionary:
	if costs.has(unit_type):
		return costs[unit_type]
	push_warning("No cost found for unit type: %s" % unit_type)
	return {}
