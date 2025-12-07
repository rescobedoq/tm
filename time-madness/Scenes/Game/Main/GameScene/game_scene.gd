extends Node3D

func _ready():
	print("\n==============================")
	print("🚀 GameScene cargada")
	print("==============================")
	if GameStarter.configured_players.size() == 0:
		print("❌ ERROR: No hay jugadores configurados")
		print("⚠️ Asegúrate de pasar por el lobby primero")
		return
		print("✅ Jugadores recibidos desde el lobby:")
	for i in range(GameStarter.configured_players.size()):
		var p = GameStarter.configured_players[i]
		print("  [%d] %s | Raza: %s | Equipo: %d | Bot: %s" % [i+1, p.player_name, p.race, p.team, p.is_bot])
	
	$Map1.disable_map()
	
	GameStarter.battle_map_instance = $Map1
		
	_setup_player_controllers()

func _setup_player_controllers():
	"""
	Toma los PlayerControllers que ya creó GameStarter y los añade al GameManager
	"""
	var game_manager = $GameManager
	var controllers = GameStarter.get_player_controllers()
	
	print("\n🎮 Añadiendo %d Jugador al GameManager..." % controllers.size())
	
	for controller in controllers:
		if is_instance_valid(controller) and controller.get_parent() == null:
			game_manager.add_child(controller)
			print("  ✅ Añadido: %s" % controller.player_name)
	
	# 🔥 Configurar BaseMap para cada jugador
	var base_map = $BaseMap
	for controller in controllers:
		if controller.is_active_player and base_map.has_method("setup_for_player"):
			base_map.setup_for_player(controller)
	
	print("✅ Todos los PlayerControllers configurados\n")
