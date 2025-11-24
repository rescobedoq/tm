# Hatchery.gd
extends Building
class_name Dragon
func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalDragon.png",
			"Invocar Dragón",
			"Invoca un poderoso dragón capaz de atacar desde el aire."
		),
	]

	super._ready()


func get_building_scale() -> int:
	return Building.get_building_scale_value("dragon")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("dragon")
