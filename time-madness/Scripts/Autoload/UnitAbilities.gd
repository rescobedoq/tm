# UnitAbilities.gd
extends Node

var abilities: Dictionary = {
	# ----- Soldier -----
	"charge_ability": {
		"icon": "res://Assets/Images/HUD/icons/chargeIcon.png",
		"name": "Charge",
		"description": "Charge against an objective.",
		"animation_scene": "res://Scenes/Utils/Charge/Charge.tscn",
		"energy_cost": 50
	},

	# ----- Archer -----
	"arrows_ability": {
		"icon": "res://Assets/Images/HUD/icons/arrowsIcon.jpg",
		"name": "Arrows",
		"description": "Shoot multiple arrows.",
		"animation_scene": "res://Scenes/Utils/Arrows/Arrows.tscn",
		"energy_cost": 500
	},	

	"trap_ability": {
		"icon": "res://Assets/Images/HUD/icons/trapIcon.jpg",
		"name": "Trap",
		"description": "Place a trap on the ground.",
		"animation_scene": "res://Scenes/Utils/Trap/Trap.tscn",
		"energy_cost": 1
	},

	# ----- Cavalry -----
	"thrust_ability": {
		"icon": "res://Assets/Images/HUD/icons/cavalryAttackIcon.jpg",
		"name": "Thrust",
		"description": "Charge forward violently.",
		"animation_scene": "res://Scenes/Utils/Thrust/Thrust.tscn",
		"energy_cost": 30
	},

	# ----- Dragon -----
	"fireBall_ability": {
		"icon": "res://Assets/Images/HUD/icons/fireBallIcon.jpg",
		"name": "Fire Ball",
		"description": "Launch a fire projectile.",
		"animation_scene": "res://Scenes/Utils/FireBall/FireBall.tscn",
		"energy_cost": 1
	},

	# ----- Druid -----
	"rootUnit_ability": {
		"icon": "res://Assets/Images/HUD/icons/rootIcon.png",
		"name": "Root Unit",
		"description": "Damage and slow enemy unit.",
		"animation_scene": "res://Scenes/Utils/Root/Root.tscn",
		"energy_cost": 1
	},
	"stealLife_ability": {
		"icon": "res://Assets/Images/HUD/icons/stealcon.jpg",
		"name": "Steal Life",
		"description": "Drain life from enemy.",
		"animation_scene": "res://Scenes/Utils/StealLife/StealLife.tscn",
		"energy_cost": 1
	},

	# ----- Golem -----
	"punch_ability": {
		"icon": "res://Assets/Images/HUD/icons/punchIcon.jpg",
		"name": "Punch",
		"description": "Stun enemy unit for 2 seconds.",
		"animation_scene": "res://Scenes/Utils/Punch/Punch.tscn",
		"energy_cost": 1
	},
	"spawn_ability": {
		"icon": "res://Assets/Images/HUD/icons/golemIcom.jpg",
		"name": "Spawn",
		"description": "Teleport to target location.",
		"animation_scene": "res://Scenes/Utils/Spawn/Spawn.tscn",
		"energy_cost": 1
	},

	# ----- Magic Soldier -----
	"magicBall_ability": {
		"icon": "res://Assets/Images/HUD/icons/magicBallIcon.jpg",
		"name": "Magic Ball",
		"description": "Launch a magic projectile.",
		"animation_scene": "res://Scenes/Utils/MagicBall/MagicBall.tscn",
		"energy_cost": 1
	},

	# ----- Ship Normal -----
	"ghostShip_ability": {
		"icon": "res://Assets/Images/HUD/icons/ghostIcon.jpg",
		"name": "Ghost Ship",
		"description": "Evolve into Ghost Ship.",
		"animation_scene": "res://Scenes/Utils/GhostShip/GhostShip.tscn",
		"energy_cost": 1
	},
	"krakenShip_ability": {
		"icon": "res://Assets/Images/HUD/icons/krakenIcon.png",
		"name": "Kraken Ship",
		"description": "Evolve into Kraken Ship.",
		"animation_scene": "res://Scenes/Utils/KrakenShip/KrakenShip.tscn",
		"energy_cost": 1
	},

	# ----- Sorcerer -----
	"areaDefense_ability": {
		"icon": "res://Assets/Images/HUD/icons/areaDefenseIcon.jpg",
		"name": "Area Defense",
		"description": "Increase defense of nearby allies.",
		"animation_scene": "res://Scenes/Utils/AreaDefense/AreaDefense.tscn",
		"energy_cost": 1
	},
	"heal_ability": {
		"icon": "res://Assets/Images/HUD/icons/healIcon.jpg",
		"name": "Heal",
		"description": "Restore health to target ally.",
		"animation_scene": "res://Scenes/Utils/Heal/Heal.tscn",
		"energy_cost": 1
	},
	"mentalControl_ability": {
		"icon": "res://Assets/Images/HUD/icons/mentalControlIcon.jpg",
		"name": "Mental Control",
		"description": "Take control of enemy unit.",
		"animation_scene": "res://Scenes/Utils/MentalControl/MentalControl.tscn",
		"energy_cost": 1
	},
}

func get_ability(ability_id: String) -> Dictionary:
	if abilities.has(ability_id):
		return abilities[ability_id].duplicate()
	else:
		push_warning("No se encontró la habilidad: %s" % ability_id)
		return {}
