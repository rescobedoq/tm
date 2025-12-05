extends Building
class_name Shrine


func _ready():
	building_type = "shrine"
	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("shrine")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("shrine")
