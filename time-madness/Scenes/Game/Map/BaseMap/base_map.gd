extends Node3D

const CASTLE_SCENE = preload("res://Scenes/Game/buildings/medievalCastle/medievalCastle_controller.tscn")

var player_castle: Building = null

func _ready() -> void:
	# El castillo se creará cuando se asigne el player_owner
	pass

# 🔥 NUEVA FUNCIÓN: Crear castillo para el jugador específico
func setup_for_player(player_controller: PlayerController) -> void:
	if player_castle != null:
		print("⚠️ El castillo ya existe para este BaseMap")
		return
	
	# Instanciar castillo
	player_castle = CASTLE_SCENE.instantiate()
	player_castle.name = "Castle_%s" % player_controller.player_name
	player_castle. global_position = Vector3(81.21299, 0, -140.2713)  # Posición original del castillo
	
	add_child(player_castle)
	
	await get_tree().process_frame
	
	# 🔥 INICIALIZAR CON JUGADOR (configura collision layers)
	if player_castle.has_method("initialize_for_player"):
		player_castle.initialize_for_player(player_controller)
	else:
		# Fallback: configurar manualmente
		player_castle.player_owner = player_controller
		if player_castle.has_method("setup_player_collision_layers"):
			player_castle.setup_player_collision_layers(player_controller.player_index)
	
	# Asignar al jugador
	player_controller.add_building(player_castle)
	
	print("🏰 Castillo creado para %s (Jugador %d) en BaseMap" % [player_controller.player_name, player_controller.player_index])
