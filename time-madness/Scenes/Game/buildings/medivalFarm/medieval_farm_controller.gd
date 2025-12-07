# Farm.gd
extends Building
class_name Farm

func _ready():
	building_type = "farm"
	super._ready() 


func get_building_scale() -> int:
	return Building.get_building_scale_value("farm")
	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("farm")
