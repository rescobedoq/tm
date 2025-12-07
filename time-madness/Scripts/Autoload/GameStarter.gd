# GameStarter.gd (Autoload)
extends Node

class_name PlayerData

var player_name: String
var race: String
var difficulty: String
var team: int
var is_bot: bool

func _init(name: String = "", race_val: String = "", diff: String = "easy", team_val: int = 0, bot: bool = false):
	player_name = name
	race = race_val
	difficulty = diff
	team = team_val
	is_bot = bot

signal game_starting(players_data: Array)
signal stage_changed(new_stage: int)
signal player_controllers_ready(controllers: Array)

signal second_tick(time_left: int)
signal stage_time_over(stage: int)

signal battle_mode_started
signal battle_mode_ended

const LAYER_BATTLE_UNITS = 8

var stage_duration := 100
var stage_time_left := stage_duration
var _timer := Timer.new()
var _timer_is_running := false

var configured_players: Array = []

var current_stage: int = 1
var max_stages: int = 10

var is_base_stage: bool = true
var is_battle_stage: bool = false

# 🔥 Escenas de PlayerController y BotController
var player_controller_scene = preload("res://Scripts/Player/PlayerController/PlayerController.tscn")
var bot_controller_scene = preload("res://Scripts/Player/BotController/BotController.tscn")
var battle_map_scene = preload("res://Scenes/Game/Map/Map1/map1.tscn")

var player_controllers: Array = []
var battle_map_instance: Node = null


var all_battle_units: Array[Entity] = []
var all_battle_builds: Array = []

func _ready():
	_timer.one_shot = false
	_timer.wait_time = 1.0
	add_child(_timer)
	_timer.timeout.connect(_on_timer_tick)
	print("⏱️ Timer configurado (pero NO iniciado)")

func update_stage_type():
	if current_stage % 2 != 0:
		is_base_stage = true
		is_battle_stage = false
		print("🏠 Stage %d = BASE STAGE" % current_stage)
	else:
		is_base_stage = false
		is_battle_stage = true
		print("⚔️ Stage %d = BATTLE STAGE" % current_stage)

func start_game(players: Array) -> void:
	configured_players = players
	current_stage = 1
	update_stage_type()

	_create_player_controllers()
	
	emit_signal("game_starting", players)
	print("🎮 Señal game_starting emitida con %d jugadores" % players.size())
	print("⏱️ Stage inicial: %d" % current_stage)

func _create_battle_map():
	print("\n🏰 Creando Battle Map persistente...")
	
	battle_map_instance = battle_map_scene.instantiate()
	battle_map_instance.name = "BattleMap"
	battle_map_instance.visible = false
	add_child(battle_map_instance)
	
	var castle_scene = preload("res://Scenes/Game/buildings/medievalCastle/medievalCastle.tscn")
	var bases = battle_map_instance.get_node("PlayerBases")

	for i in range(configured_players.size()):
		var marker_name = "player%d" % (i + 1)

		if bases.has_node(marker_name):
			var marker = bases.get_node(marker_name)

			var castle = castle_scene.instantiate()
			castle.name = "Castle_Player%d" % (i + 1)
			var height_offset = 22
			castle.position = marker.position + Vector3(0, height_offset, 0)
			castle.visible = true

			battle_map_instance.add_child(castle)
			print("  ✅ Castillo colocado para jugador %d" % (i + 1))

	print("✅ Battle Map creado y listo (oculto inicialmente)\n")

func start_stage_timer() -> void:
	if _timer_is_running:
		print("⚠️ El timer ya estaba corriendo, reiniciando...")
		_timer.stop()
	
	stage_time_left = stage_duration
	_timer_is_running = true
	_timer.start()
	print("⏱️ ✅ TIMER INICIADO - Stage %d comenzará a contar %d segundos" % [current_stage, stage_duration])

func stop_stage_timer() -> void:
	if _timer_is_running:
		_timer.stop()
		_timer_is_running = false
		print("⏱️ ⏸️ TIMER DETENIDO")

func next_stage() -> void:
	if current_stage < max_stages:
		current_stage += 1
		update_stage_type()
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage avanzado a: %d" % current_stage)
	else:
		print("⚠️ Ya estás en el último stage")

func set_stage(stage: int) -> void:
	if stage >= 1 and stage <= max_stages:
		current_stage = stage
		update_stage_type()
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage establecido a: %d" % current_stage)

func get_current_stage() -> int:
	return current_stage

# 🔥🔥🔥 MODIFICADO: Crear PlayerControllers O BotControllers según is_bot
func _create_player_controllers() -> void:
	for controller in player_controllers:
		if is_instance_valid(controller):
			controller.queue_free()
	player_controllers. clear()
	
	print("\n" + "=".repeat(60))
	print("🎮 CREANDO PLAYER CONTROLLERS")
	print("=".repeat(60))
	
	for i in range(configured_players.size()):
		var player_data = configured_players[i]
		
		# 🔥 ELEGIR ESCENA SEGÚN SI ES BOT O NO
		var controller_scene: PackedScene
		if player_data.is_bot:
			controller_scene = bot_controller_scene
		else:
			controller_scene = player_controller_scene
		
		# Instanciar
		var controller = controller_scene. instantiate()
		controller.name = "Player%d" % (i + 1)
		controller.player_name = player_data.player_name
		controller.is_active_player = not player_data.is_bot
		controller.faction = player_data.race
		controller.gold = 2000
		controller.resources = 2000
		controller.player_index = i
		
		# Posicionar
		controller.position = Vector3(i * 300, 0, 0)
		
		# Guardar referencia
		player_controllers.append(controller)
		
		# Imprimir info
		var player_type = "🎮 HUMANO" if not player_data.is_bot else "🤖 BOT [" + player_data.difficulty. to_upper() + "]"
		var controller_type = "PlayerController" if not player_data. is_bot else "BotController"
		print("  [%d] %s | %s | %s | Facción: %s | Equipo: %d" % 
			[i + 1, player_data.player_name, player_type, controller_type, player_data.race, player_data.team])
	
	print("=".repeat(60))
	print("✅ Total de jugadores creados: %d\n" % player_controllers.size())
	
	# Emitir señal
	emit_signal("player_controllers_ready", player_controllers)

func get_player_controllers() -> Array:
	return player_controllers

func get_player_controller(index: int):
	if index >= 0 and index < player_controllers.size():
		return player_controllers[index]
	return null

func get_active_player_controller():
	for controller in player_controllers:
		if controller.is_active_player:
			return controller
	return null

func _on_timer_tick():
	if not _timer_is_running:
		return
	
	stage_time_left -= 1
	
	emit_signal("second_tick", stage_time_left)

	print("⏱️ Tiempo restante del stage %d: %ds" % [current_stage, stage_time_left])

	if stage_time_left <= 0:
		stop_stage_timer()
		emit_signal("stage_time_over", current_stage)
		print("⏳ Stage %d terminado automáticamente" % current_stage)
		
		next_stage()
