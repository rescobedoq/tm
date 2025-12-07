extends Building
class_name Hatchery
# Barracks.gd
func _ready():
	building_type = "dragon"
	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("dragon")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("dragon")
