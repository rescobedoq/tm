# GameStarter.gd (Autoload)
extends Node

signal game_starting(players_data: Array)
signal stage_changed(new_stage: int)
signal player_controllers_ready(controllers: Array)  # 🔥 Nueva señal

signal second_tick(time_left: int)
signal stage_time_over(stage: int)

var stage_duration := 300  # 5 minutos
var stage_time_left := stage_duration
var _timer := Timer.new()


var configured_players: Array = []

# 🔥 Variable de stage global
var current_stage: int = 1
var max_stages: int = 10

# 🔥 Escenas
var player_controller_scene = preload("res://Scripts/Player/PlayerController/PlayerController.tscn")
var base_map_scene = preload("res://Scenes/Game/Map/BaseMap/baseMap.tscn")


# 🔥 PlayerControllers creados
var player_controllers: Array = []

func start_game(players: Array) -> void:
	_setup_stage_timer()

	configured_players = players
	current_stage = 1
	
	# 🔥 Crear los PlayerControllers con sus mapas
	_create_player_controllers()
	
	emit_signal("game_starting", players)
	print("🎮 Señal game_starting emitida con %d jugadores" % players.size())
	print("⏱️ Stage inicial: %d" % current_stage)

# 🔥 Avanzar al siguiente stage
func next_stage() -> void:
	if current_stage < max_stages:
		current_stage += 1
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage avanzado a: %d" % current_stage)
	else:
		print("⚠️ Ya estás en el último stage")

# 🔥 Establecer un stage específico
func set_stage(stage: int) -> void:
	if stage >= 1 and stage <= max_stages:
		current_stage = stage
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage establecido a: %d" % current_stage)

# 🔥 Obtener stage actual
func get_current_stage() -> int:
	return current_stage

# 🔥 Crear PlayerControllers con BaseMap como hijo
func _create_player_controllers() -> void:
	# Limpiar controllers previos
	for controller in player_controllers:
		if is_instance_valid(controller):
			controller.  queue_free()
	player_controllers.clear()
	
	print("\n" + "=".repeat(60))
	print("🎮 SE HAN CREADO A LOS JUGADORES")
	print("=".repeat(60))
	
	for i in range(configured_players. size()):
		var player_data = configured_players[i]
		
		# 🔥 Crear PlayerController
		var controller = player_controller_scene.instantiate()
		controller.name = "Player%d" % (i + 1)
		controller. player_name = player_data. player_name
		controller.is_active_player = not player_data.is_bot
		controller.faction = player_data.race
		controller.difficult_bot = player_data.is_bot
		controller.gold = 500
		controller.resources = 500
		

		# Posicionar el controller
		controller.position = Vector3(i * 300, 0, 0)
		
		# Guardar referencia
		player_controllers.append(controller)
		
		# 🔥 Imprimir info del jugador
		var player_type = "🎮 HUMANO" if not player_data.is_bot else "🤖 BOT [" + player_data.difficulty. to_upper() + "]"
		print("  [%d] %s | %s | Facción: %s | Equipo: %d" % 
			[i + 1, player_data.player_name, player_type, player_data.race, player_data.team])
	
	print("=".repeat(60))
	print("✅ Total de jugadores creados: %d\n" % player_controllers.size())
	
	# Emitir señal
	emit_signal("player_controllers_ready", player_controllers)

# 🔥 Obtener controllers
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
	
func _setup_stage_timer():
	stage_time_left = stage_duration
	
	# Configurar timer
	_timer.one_shot = false
	_timer.wait_time = 1.0  # cada segundo
	add_child(_timer)

	if not _timer.timeout.is_connected(_on_timer_tick):
		_timer.timeout.connect(_on_timer_tick)
	
	_timer.start()

func _on_timer_tick():
	stage_time_left -= 1
	
	emit_signal("second_tick", stage_time_left)

	print("⏱️ Tiempo restante del stage %d: %ds" % [current_stage, stage_time_left])

	if stage_time_left <= 0:
		emit_signal("stage_time_over", current_stage)
		print("⏳ Stage %d terminado automáticamente" % current_stage)
		
		_timer.stop()
		next_stage()  # avanzar al siguiente stage
		
		# reiniciar tiempo del nuevo stage
		_setup_stage_timer()
