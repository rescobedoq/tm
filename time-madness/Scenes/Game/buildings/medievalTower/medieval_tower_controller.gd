# Tower.gd
extends Building
class_name Tower

func get_building_scale() -> int:
	return Building.get_building_scale_value("tower")

	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("tower")
