extends Building
class_name Shrine

const GOLEM_SCENE = preload("res://Scenes/Game/Unit/medievalGolem/medievalGolem_controller.tscn")
const DRUID_SCENE = preload("res://Scenes/Game/Unit/medievalDruid/medievalDruid_controller.tscn")

const GOLEM_COST = {"gold": 250, "resources": 150, "upkeep": 3}
const DRUID_COST = {"gold": 120, "resources": 60, "upkeep": 1}

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalGolem.png",
			"Invocar Gólem",
			"Invoca un gólem resistente con gran fuerza física.\nCosto: 250 oro, 150 recursos",
			"summon_golem"
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalDruid.png",
			"Entrenar Druida",
			"Entrena un druida capaz de usar magia natural y de apoyo.\nCosto: 120 oro, 60 recursos",
			"train_druid"
		),
	]

	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("shrine")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("shrine")

# ==============================
# IMPLEMENTACIÓN DE HABILIDADES
# ==============================
func _summon_golem() -> void:
	_train_unit(GOLEM_SCENE, GOLEM_COST, "Gólem")

func _train_druid() -> void:
	_train_unit(DRUID_SCENE, DRUID_COST, "Druida")
