# Harbor.gd
extends Building
class_name Harbor

func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalShipNormal.png",
			"Construir Barco",
			"Construye un barco básico para ataque y exploración."
		),
	]
	super._ready()



func get_building_scale() -> int:
	return Building.get_building_scale_value("harbor")
	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("harbor")
