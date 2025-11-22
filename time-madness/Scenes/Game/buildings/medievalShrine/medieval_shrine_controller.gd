extends CharacterBody3D
class_name Shrine
const BUILDING_SCALE: int = 25

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
