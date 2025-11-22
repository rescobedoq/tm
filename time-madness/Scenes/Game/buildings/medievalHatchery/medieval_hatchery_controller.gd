extends CharacterBody3D
class_name Hatchery
const BUILDING_SCALE: int = 25

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
