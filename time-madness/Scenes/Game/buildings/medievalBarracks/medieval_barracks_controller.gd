# Barracks.gd
extends Building
class_name Barracks


func get_building_scale() -> int:
	return Building.get_building_scale_value("barracks")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("barracks")
