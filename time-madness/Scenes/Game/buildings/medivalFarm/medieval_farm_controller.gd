extends CharacterBody3D
class_name Farm
const BUILDING_SCALE: int = 15

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
