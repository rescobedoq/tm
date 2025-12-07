extends Node

var abilities := {
	"barracks": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalSoldier.png",
			"name": "Train Soldier",
			"description": "Trains a basic infantry soldier.",
			"id": "train_soldier"
		},
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalArcher.png",
			"name": "Train Archer",
			"description": "Trains a basic ranged archer.",
			"id": "train_archer"
		},
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalCavalry.png",
			"name": "Train Cavalry",
			"description": "Trains a light cavalry unit.",
			"id": "train_cavalry"
		}
	],

	"castle": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalSlave.png",
			"name": "Train Slave",
			"description": "Trains a worker unit for gathering gold and resources.",
			"id": "train_slave"
		}
	],

	"harbor": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalShipNormal.png",
			"name": "Build Ship",
			"description": "Builds a basic ship for attack and exploration.",
			"id": "build_ship"
		}
	],

	"dragon": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalDragon.png",
			"name": "Summon Dragon",
			"description": "Summons a powerful flying dragon.",
			"id": "train_dragon"
		}
	],

	"magic": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalMagicSoldier.png",
			"name": "Train Magic Soldier",
			"description": "Trains a soldier using both physical and magical combat.",
			"id": "train_magic_soldier"
		},
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalSorcerer.png",
			"name": "Train Sorcerer",
			"description": "Trains an offensive magic sorcerer.",
			"id": "train_sorcerer"
		}
	],

	"shrine": [
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalGolem.png",
			"name": "Summon Golem",
			"description": "Summons a durable brute-force golem.",
			"id": "train_golem"
		},
		{
			"icon": "res://Assets/Images/Portraits/Units/medievalDruid.png",
			"name": "Train Druid",
			"description": "Trains a druid with natural magic abilities.",
			"id": "train_druid"
		}
	],
}

func get_building_ability(building_type: String) -> Array:
	if abilities.has(building_type):
		return abilities[building_type]
	push_warning("No abilities found for building: %s" % building_type)
	return []
