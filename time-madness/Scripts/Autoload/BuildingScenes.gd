# BuildingScenes.gd
extends Node

# Diccionario de rutas de escenas por tipo de edificio
var scenes := {
	"barracks": "res://Scenes/Game/Buildings/medievalBarracks/medieval_barracks_controller.gd",
	"dragon": "res://Scenes/Game/buildings/medievalHatchery/medievalHatchery_controller.tscn",
	"farm": "res://Scenes/Game/Buildings/medivalFarm/medievalFarm_controller.tscn",
	"harbor": "res://Scenes/Game/buildings/medievalHarbor/medievalHarbor_controller.tscn",
	"magic": "res://Scenes/Game/buildings/medievalMagic/medievalMagic_controller.tscn",
	"shrine": "res://Scenes/Game/buildings/medievalShrine/medievalShrine_controller.tscn",
	"smithy": "res://Scenes/Game/buildings/medievalSmithy/medievalSmithy_controller.tscn",
	"tower": "res://Scenes/Game/buildings/medievalTower/medievalTower_controller.tscn"
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
