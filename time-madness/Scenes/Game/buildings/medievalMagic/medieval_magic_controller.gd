extends Building
class_name Magic

const MAGIC_SOLDIER_SCENE = preload("res://Scenes/Game/Unit/medievalMagicSoldier/medievalMagicSoldier_controller.tscn")
const SORCERER_SCENE = preload("res://Scenes/Game/Unit/medievalSorcerer/medievalSorcerer_controller.tscn")

const MAGIC_SOLDIER_COST = {"gold": 100, "resources": 40, "upkeep": 1}
const SORCERER_COST = {"gold": 150, "resources": 75, "upkeep": 2}

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalMagicSoldier.png",
			"Entrenar Soldado Mágico",
			"Entrena un soldado que combina combate físico con habilidades mágicas.\nCosto: 100 oro, 40 recursos",
			"train_magic_soldier"
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalSorcerer.png",
			"Entrenar Hechicero",
			"Entrena un hechicero especializado en magia ofensiva.\nCosto: 150 oro, 75 recursos",
			"train_sorcerer"
		),
	]

	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("magic")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("magic")

# ==============================
# IMPLEMENTACIÓN DE HABILIDADES
# ==============================
func _train_magic_soldier() -> void:
	_train_unit(MAGIC_SOLDIER_SCENE, MAGIC_SOLDIER_COST, "Soldado Mágico")

func _train_sorcerer() -> void:
	_train_unit(SORCERER_SCENE, SORCERER_COST, "Hechicero")
