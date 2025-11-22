extends CharacterBody3D
class_name Magic
const BUILDING_SCALE: int = 30

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
