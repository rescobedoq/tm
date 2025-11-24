# Shrine.gd
extends Building
class_name Shrine

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalGolem.png",
			"Invocar Gólem",
			"Invoca un gólem resistente con gran fuerza física."
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalDruid.png",
			"Entrenar Druida",
			"Entrena un druida capaz de usar magia natural y de apoyo."
		),
	]

	super._ready()


func get_building_scale() -> int:
	return Building.get_building_scale_value("shrine")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("shrine")
