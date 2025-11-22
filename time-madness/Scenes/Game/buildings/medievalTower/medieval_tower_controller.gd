extends CharacterBody3D
class_name Tower
const BUILDING_SCALE: int = 20

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
