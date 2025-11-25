extends Building
class_name Hatchery

const DRAGON_SCENE = preload("res://Scenes/Game/Unit/medievalDragon/medievalDragon_controller.tscn")
const DRAGON_COST = {"gold": 500, "resources": 300, "upkeep": 5}

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalDragon.png",
			"Invocar Dragón",
			"Invoca un poderoso dragón capaz de atacar desde el aire.\nCosto: 500 oro, 300 recursos",
			"summon_dragon"
		),
	]

	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("dragon")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("dragon")

# ==============================
# IMPLEMENTACIÓN DE HABILIDADES
# ==============================
func _summon_dragon() -> void:
	_train_unit(DRAGON_SCENE, DRAGON_COST, "Dragón")
