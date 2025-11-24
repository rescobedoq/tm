# Tower.gd
extends Building
class_name Tower

func get_building_scale() -> int:
	return Building.get_building_scale_value("tower")
