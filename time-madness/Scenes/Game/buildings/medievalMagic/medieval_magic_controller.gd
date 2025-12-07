extends Building
class_name Magic


func _ready():
	building_type = "magic"
	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("magic")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("magic")
