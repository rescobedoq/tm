extends CharacterBody3D

var building_type: String = ""

func set_building_type(b: String) -> void:
	building_type = b
	print("el tipo es: ", building_type)
	
	
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
			scene_path = "res://Scenes/Game/buildings/medievalSmithy/medievalSmihty.tscn"
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
