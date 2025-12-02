extends Node3D




func _ready():
	print("\n==============================")
	print("🚀 GameScene cargada")
	print("==============================")
	$Map1.disable_map()
	GameStarter.battle_map_instance = $Map1
	
	# Conectar señales importantes del GameStarter (autoload)
	GameStarter.player_controllers_ready.connect(_on_player_controllers_ready)
	GameStarter.stage_changed. connect(_on_stage_changed)
	GameStarter.game_starting.connect(_on_game_starting)

	# Crear configuración de 2 jugadores de prueba
	var players = [
		PlayerData.new("Player1", "humans", "easy", 1, false),
		PlayerData.new("AI Bot", "orcs", "normal", 2, true)
	]

	# 🔥 Lanzar el inicio del juego con 2 jugadores
	GameStarter. start_game(players)


func _on_game_starting(players):
	print("\n🎮 GameScene: Recibido game_starting")
	print("  Jugadores configurados: %d" % players.size())

	# Activar el primer stage
	_update_stage_visibility()
	GameStarter. start_stage_timer()


func _on_player_controllers_ready(controllers):
	print("\n🎮 GameScene: PlayerControllers listos")

	# 🔥 Añadir los controllers al GameManager (no a GameScene)
	var game_manager = $GameManager
	for c in controllers:
		game_manager.add_child(c)
		print("  ➕ Añadido controller a GameManager: %s" % c.name)
	
	# 🔥 Configurar BaseMap con castillos para cada jugador
	var base_map = $BaseMap
	for c in controllers:
		if base_map.has_method("setup_for_player"):
			base_map.setup_for_player(c)

	print("🎮 Todos los PlayerControllers añadidos a GameManager\n")


func _on_stage_changed(new_stage):
	print("\n🔄 GameScene: Stage cambió a %d" % new_stage)
	_update_stage_visibility()
	GameStarter.start_stage_timer()

func _update_stage_visibility():
	var is_base = GameStarter.is_base_stage
	var is_battle = GameStarter.is_battle_stage

	# 🔥 Controlar visibilidad de los mapas
	if is_battle:
		$Map1.enable_map()
		$BaseMap.visible = false
		print("👁️ Map1 HABILITADO (Battle Stage)")
	else:
		$Map1. disable_map()
		$BaseMap.visible = true
		print("👁️ Map1 DESHABILITADO (Base Stage)")

	print("👁️ BaseMap visible:", is_base)
	print("👁️ BattleMap visible:", is_battle)
