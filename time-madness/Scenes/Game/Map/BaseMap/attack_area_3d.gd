extends Area3D

var is_active: bool = true  # 🔥 NUEVO: Flag para controlar si el área está activa

func _ready():
	collision_layer = 0
	
	# 🔥 Configurar mask según el jugador dueño
	var player = _get_player_owner()
	if player and player.has("player_index"):
		var player_layer = 2 + player.player_index
		collision_mask = 1 << player_layer
		print("✅ AttackArea configurada para detectar unidades del jugador %d (layer %d)" % [player.player_index, player_layer])
	else:
		# Fallback
		collision_mask = 1 << 2
		print("⚠️ AttackArea sin player_owner, usando layer 2 por defecto")
	
	body_entered.connect(_on_body_entered)
	body_exited. connect(_on_body_exited)
	
	print("✅ Area3D configurada para detectar unidades de ataque")

func _on_body_entered(body):
	if not is_active:  # 🔥 Ignorar si está desactivada
		return
		
	if body is Unit:
		print("🔥 Unidad ENTRÓ al área de ataque:", body.unit_type)
		
		var player = _get_player_owner()
		if player:
			player.move_unit_to_attack(body)

func _on_body_exited(body):
	if not is_active:  # 🔥 Ignorar si está desactivada
		return
		
	if body is Unit:
		print("🚶 Unidad SALIÓ del área de ataque:", body.unit_type)
		
		var player = _get_player_owner()
		if player:
			player.move_unit_to_defense(body)

# 🔥 NUEVA FUNCIÓN: Desactivar el área
func deactivate():
	is_active = false
	monitoring = false
	print("❌ AttackArea desactivada")

# 🔥 NUEVA FUNCIÓN: Reactivar el área
func activate():
	is_active = true
	monitoring = true
	print("✅ AttackArea activada")

func _get_player_owner():
	var base_map = get_parent()
	if base_map == null:
		print("❌ No se encontró BaseMap")
		return null
	
	var game_scene = base_map.get_parent()
	if game_scene == null:
		print("❌ No se encontró GameScene")
		return null
	
	var game_manager = game_scene.get_node_or_null("GameManager")
	if game_manager == null:
		print("❌ No se encontró GameManager")
		return null
	
	var active_player = GameStarter.get_active_player_controller()
	if active_player:
		return active_player
	
	print("❌ No se encontró PlayerController activo")
	return null
