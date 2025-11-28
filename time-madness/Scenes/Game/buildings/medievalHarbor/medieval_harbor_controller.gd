extends Building
class_name Harbor

const SHIP_SCENE = preload("res://Scenes/Game/Unit/medievalShipNormal/medievalShipNormal_controller.tscn")
const SHIP_COST = {"gold": 1, "resources": 1, "upkeep": 2}

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalShipNormal.png",
			"Construir Barco",
			"Construye un barco básico para ataque y exploración.\nCosto: 200 oro, 100 recursos",
			"build_ship"
		),
	]
	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("harbor")
	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("harbor")

# ==============================
# IMPLEMENTACIÓN DE HABILIDADES
# ==============================
func _build_ship() -> void:
	_train_unit(SHIP_SCENE, SHIP_COST, "Barco")
