extends Node

var scenes := {
	"train_soldier": "res://Scenes/Game/Unit/medievalSoldier/medievalSoldier_controler.tscn",
	"train_archer": "res://Scenes/Game/Unit/medievalArcher/medievalArcher_controller.tscn",
	"train_cavalry": "res://Scenes/Game/Unit/medievalCavalry/medievalCavalry_controller.tscn",
	"train_dragon": "res://Scenes/Game/Unit/medievalDragon/medievalDragon_controller.tscn",
	"train_druid": "res://Scenes/Game/Unit/medievalDruid/medievalDruid_controller.tscn",
	"train_golem": "res://Scenes/Game/Unit/medievalGolem/medievalGolem_controller.tscn",
	"train_magic_soldier": "res://Scenes/Game/Unit/medievalMagicSoldier/medievalMagicSoldier_controller.tscn",
	"train_sorcerer": "res://Scenes/Game/Unit/medievalSorcerer/medievalSorcerer_controller.tscn",

	# Barcos
	"build_ship": "res://Scenes/Game/Unit/medievalShipNormal/medievalShipNormal_controller.tscn",
	"build_ship_kraken": "res://Scenes/Game/Unit/medievalShipKraken/medievalShipKraken_controller.tscn",
	"build_ship_ghost": "res://Scenes/Game/Unit/medievalShipGhost/medievalShipGhost_controller.tscn"
}

func get_scene(unit_type: String) -> String:
	if scenes.has(unit_type):
		return scenes[unit_type]
	push_warning("❌ No se encontró la escena para la unidad: %s" % unit_type)
	return ""
