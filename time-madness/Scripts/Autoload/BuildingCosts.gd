extends Node

# ==============================
# 🏗️ COSTOS DE EDIFICIOS
# ==============================
var costs := {
	"barracks": {"gold": 10, "resources": 50, "upkeep": 0},
	"dragon": {"gold": 500, "resources": 300, "upkeep": 0},
	"farm": {"gold": 50, "resources": 20, "upkeep": 0},
	"harbor": {"gold": 200, "resources": 100, "upkeep": 0},
	"magic": {"gold": 300, "resources": 150, "upkeep": 0},
	"shrine": {"gold": 150, "resources": 80, "upkeep": 0},
	"smithy": {"gold": 120, "resources": 60, "upkeep": 0},
	"tower": {"gold": 200, "resources": 100, "upkeep": 0}
}


func get_cost(bulding_type: String) -> Dictionary:
	if costs.has(bulding_type):
		return costs[bulding_type]
	push_warning("No cost found for unit type: %s" % bulding_type)
	return {}
