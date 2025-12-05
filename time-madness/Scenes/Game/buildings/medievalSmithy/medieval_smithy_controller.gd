# Smithy.gd
extends Building
class_name Smithy
func _ready():
	building_type = "smithy"
	super._ready() 
func get_building_scale() -> int:
	return Building.get_building_scale_value("smithy")
	
func get_building_portrait() -> String:
	return Building.get_building_portrait_path("smithy")
