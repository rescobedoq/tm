# Farm.gd
extends Building
class_name Farm

func get_building_scale() -> int:
	return Building.get_building_scale_value("farm")
