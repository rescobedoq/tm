# Barracks.gd
extends Building
class_name Barracks

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalSoldier.png",
			"Entrenar Soldado",
			"Entrena un soldado básico de infantería."
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalArcher.png",
			"Entrenar Arquero",
			"Entrena un arquero de rango básico."
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalCavalry.png",
			"Entrenar Caballería",
			"Entrena una unidad de caballería ligera."
		),
	]

	super._ready()


func get_building_scale() -> int:
	return Building.get_building_scale_value("barracks")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("barracks")
