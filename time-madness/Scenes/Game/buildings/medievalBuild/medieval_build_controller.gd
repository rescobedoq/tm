extends CharacterBody3D

var building_type: String = ""
var default_scale: Vector3 = Vector3(10, 10, 10)

func _ready():
	pass 


func set_building_type(b: String) -> void:
	building_type = b
	var sz: int = 1

	match building_type:
		"barracks": sz = Barracks.BUILDING_SCALE
		"dragon": sz = Hatchery.BUILDING_SCALE
		"farm": sz = Farm.BUILDING_SCALE
		"harbor": sz = Harbor.BUILDING_SCALE
		"magic": sz = Magic.BUILDING_SCALE
		"shrine": sz = Shrine.BUILDING_SCALE
		"smithy": sz = Smithy.BUILDING_SCALE
		"tower": sz = Tower.BUILDING_SCALE
		_:
			print("Tipo de edificio desconocido: %s" % building_type)
			return

	scale = Vector3(sz, sz, sz)
	print("Placeholder escalado a: ", scale)


func get_build() -> Node3D:
	if building_type == "":
		print("No se ha definido building_type")
		return null
		
	var scene_path := ""


	match building_type:
		"barracks":
			scene_path = "res://Scenes/Game/buildings/medievalBarracks/medievalBarracks_controller.tscn"
		"dragon":
			scene_path = "res://Scenes/Game/buildings/medievalHatchery/medievalHatchery_controller.tscn"
		"farm":
			scene_path = "res://Scenes/Game/buildings/medivalFarm/medievalFarm_controller.tscn"
		"harbor":
			scene_path = "res://Scenes/Game/buildings/medievalHarbor/medievalHarbor_controller.tscn"
		"magic":
			scene_path = "res://Scenes/Game/buildings/medievalMagic/medievalMagic_controller.tscn"
		"shrine":
			scene_path = "res://Scenes/Game/buildings/medievalShrine/medievalShrine_controller.tscn"
		"smithy":
			scene_path = "res://Scenes/Game/buildings/medievalSmithy/medievalSmithy_controller.tscn"
		"tower":
			scene_path = "res://Scenes/Game/buildings/medievalTower/medievalTower_controller.tscn"
		_:
			print("Tipo de edificio desconocido: %s" % building_type)
			return null

	var scene = load(scene_path)
	print("la ruta es:", scene_path)
	if not scene:
		push_error("No se pudo cargar la escena: %s" % scene_path)
		return null

	return scene.instantiate()
