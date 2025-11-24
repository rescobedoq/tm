# Hatchery.gd
extends Building
class_name Dragon

func get_building_scale() -> int:
	return Building.get_building_scale_value("dragon")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("dragon")
