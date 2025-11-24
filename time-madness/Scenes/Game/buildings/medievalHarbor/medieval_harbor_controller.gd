# Harbor.gd
extends Building
class_name Harbor

func get_building_scale() -> int:
	return Building.get_building_scale_value("harbor")
	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("harbor")
