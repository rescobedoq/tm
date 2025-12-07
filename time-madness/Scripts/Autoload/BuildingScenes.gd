# BuildingScenes.gd
extends Node

# Diccionario de rutas de escenas por tipo de edificio
var scenes := {
	"castle": "res://Scenes/Game/Buildings/medievalCastle/medievalCastle_controller.tscn",
	"barracks": "res://Scenes/Game/Buildings/medievalBarracks/medievalBarracks_controller.tscn",
	"dragon": "res://Scenes/Game/Buildings/medievalHatchery/medievalHatchery_controller.tscn",
	"farm": "res://Scenes/Game/Buildings/medivalFarm/medievalFarm_controller.tscn",
	"harbor": "res://Scenes/Game/Buildings/medievalHarbor/medievalHarbor_controller.tscn",
	"magic": "res://Scenes/Game/Buildings/medievalMagic/medievalMagic_controller.tscn",
	"shrine": "res://Scenes/Game/Buildings/medievalShrine/medievalShrine_controller.tscn",
	"smithy": "res://Scenes/Game/Buildings/medievalSmithy/medievalSmithy_controller.tscn",
	"tower": "res://Scenes/Game/Buildings/medievalTower/medievalTower_controller.tscn"
}

# Devuelve la ruta de la escena según el tipo de edificio
func get_building_path(building_type: String) -> String:
	if building_type == "":
		push_warning("BuildingScenes.get_path: building_type vacío")
		return ""
	if not scenes.has(building_type):
		push_warning("BuildingScenes.get_path: No se encontró escena para '%s'" % building_type)
		return ""
	return scenes[building_type]
