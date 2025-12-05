# UnitStats.gd
extends Node

var stats: Dictionary = {
	"Medieval Dragon": {
		"max_health": 200,
		"current_health": 200,
		"attack_damage": 25,
		"defense": 10,
		"move_speed": 50,
		"attack_range": 40,
		"max_magic": 1000,
		"abilities": ["fireBall_ability"]
	},
	"Medieval Druid": {
		"max_health": 200,
		"current_health": 200,
		"attack_damage": 25,
		"defense": 10,
		"move_speed": 20,
		"attack_range": 30,
		"max_magic": 1000,
		"abilities": ["rootUnit_ability", "stealLife_ability"]
	},
	"Medieval Golem": {
		"max_health": 350,
		"current_health": 350,
		"attack_damage": 40,
		"defense": 20,
		"move_speed": 10,
		"attack_range": 10,
		"max_magic": 1000,
		"abilities": ["punch_ability", "spawn_ability"]
	},
	"Medieval Soldier": {
		"max_health": 150,
		"current_health": 150,
		"attack_damage": 15,
		"defense": 5,
		"move_speed": 25,
		"attack_range": 10,
		"max_magic": 1000,
		"abilities": ["charge_ability"]
	},
	"Medieval Archer": {
		"max_health": 120,
		"current_health": 120,
		"attack_damage": 12,
		"defense": 3,
		"move_speed": 20,
		"attack_range": 50,
		"max_magic": 1000,
		"abilities": ["arrows_ability", "trap_ability"]
	},
	"Medieval Cavalry": {
		"max_health": 180,
		"current_health": 180,
		"attack_damage": 25,
		"defense": 8,
		"move_speed": 40,
		"attack_range": 15,
		"max_magic": 1000,
		"abilities": ["thrust_ability"]
	},
	"Medieval Sorcerer": {
		"max_health": 200,
		"current_health": 200,
		"attack_damage": 25,
		"defense": 10,
		"move_speed": 7,
		"attack_range": 30,
		"max_magic": 1000,
		"abilities": ["areaDefense_ability", "heal_ability", "mentalControl_ability"]
	},
	"Medieval Magic Soldier": {
		"max_health": 180,
		"current_health": 180,
		"attack_damage": 20,
		"defense": 8,
		"move_speed": 15,
		"attack_range": 25,
		"max_magic": 1000,
		"abilities": ["magicBall_ability"]
	},
	"Medieval Ship Ghost": {
		"max_health": 250,
		"current_health": 250,
		"attack_damage": 30,
		"defense": 10,
		"move_speed": 15,
		"attack_range": 35,
		"max_magic": 1000,
		"abilities": []
	},
	"Medieval Ship Kraken": {
		"max_health": 400,
		"current_health": 400,
		"attack_damage": 50,
		"defense": 20,
		"move_speed": 10,
		"attack_range": 30,
		"max_magic": 1000,
		"abilities": []
	},
	"Medieval Ship Normal": {
		"max_health": 300,
		"current_health": 300,
		"attack_damage": 20,
		"defense": 12,
		"move_speed": 12,
		"attack_range": 25,
		"max_magic": 1000,
		"abilities": ["ghostShip_ability", "krakenShip_ability"]
	}
}

func get_stats(unit_type: String) -> Dictionary:
	if stats.has(unit_type):
		return stats[unit_type].duplicate() 
	else:
		push_warning("No se encontraron stats para la unidad: %s" % unit_type)
		return {}
