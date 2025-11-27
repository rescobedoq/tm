extends Building
class_name Castle

const SOLDIER_COST = {"gold": 50, "resources": 0, "upkeep": 1}

func _ready():
	super._ready() 
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalSlave.png",
			"Entrenar Esclavo",
			"Entrena un Esclavo, obtiene oro y recursos.\nCosto: 30 oro",
			"train_slave" 
		),
	]


func get_building_scale() -> int:
	return Building.get_building_scale_value("barracks")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("castle")
