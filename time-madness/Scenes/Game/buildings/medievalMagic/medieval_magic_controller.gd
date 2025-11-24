# Magic.gd
extends Building
class_name Magic

func get_building_scale() -> int:
	return Building.get_building_scale_value("magic")
