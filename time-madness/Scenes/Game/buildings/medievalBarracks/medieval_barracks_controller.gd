# Barracks.gd
extends Building
class_name Barracks

const SOLDIER_SCENE = preload("res://Scenes/Game/Unit/medievalSoldier/medievalSoldier_controler.tscn")
const ARCHER_SCENE = preload("res://Scenes/Game/Unit/medievalArcher/medievalArcher_controller.tscn")
const CAVALRY_SCENE = preload("res://Scenes/Game/Unit/medievalCavalry/medievalCavalry_controller.tscn")

const SOLDIER_COST = {"gold": 50, "resources": 0, "upkeep": 1}
const ARCHER_COST = {"gold": 75, "resources": 25, "upkeep": 1}
const CAVALRY_COST = {"gold": 150, "resources": 50, "upkeep": 2}

func _ready():
	super._ready() 
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalSoldier.png",
			"Entrenar Soldado",
			"Entrena un soldado básico de infantería.\nCosto: 50 oro",
			"train_soldier" 
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalArcher.png",
			"Entrenar Arquero",
			"Entrena un arquero de rango básico.\nCosto: 75 oro, 25 recursos",
			"train_archer" 
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalCavalry.png",
			"Entrenar Caballería",
			"Entrena una unidad de caballería ligera.\nCosto: 150 oro, 50 recursos",
			"train_cavalry"
		),
	]


func get_building_scale() -> int:
	return Building.get_building_scale_value("barracks")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("barracks")

# ==============================
# 🔥 IMPLEMENTACIÓN DE HABILIDADES
# ==============================
func _train_soldier() -> void:
	_train_unit(SOLDIER_SCENE, SOLDIER_COST, "Soldado")

func _train_archer() -> void:
	_train_unit(ARCHER_SCENE, ARCHER_COST, "Arquero")

func _train_cavalry() -> void:
	_train_unit(CAVALRY_SCENE, CAVALRY_COST, "Caballería")
