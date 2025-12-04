extends PlayerController
class_name BotPlayer

# ==============================
# CONFIGURACIÓN DEL BOT
# ==============================
enum Difficulty { EASY, NORMAL, HARD }
@export var difficulty: Difficulty = Difficulty.NORMAL

# ==============================
# 🧠 ESTADO DEL BOT
# ==============================
var ai_state: String = "idle"  # idle, building, training, attacking, defending
var ai_timer: float = 0.0
var target_enemy: Entity = null
var next_building_type: String = ""

# ==============================
# 🎯 ESTRATEGIA
# ==============================
var build_order: Array[String] = ["farm", "barracks", "tower"]
var current_build_index: int = 0

# ==============================
# ♻️ SOBRESCRIBIR FUNCIONES
# ==============================
func _ready() -> void:
	super._ready()  # Llamar al _ready() de PlayerController
	_init_bot()

func _process(delta: float) -> void:
	super._process(delta)  # Mantener funcionalidad de cámara, etc.
	
	# 🤖 Solo ejecutar IA si NO es el jugador activo (para no interferir con control manual)
	if not is_active_player:
		_run_ai(delta)
		

# ==============================
# 🤖 FUNCIONES DEL BOT
# ==============================
func _init_bot() -> void:
	# 🧪 TEST DE RECURSOS
	print("\n🧪 ===== TEST DE RECURSOS =====")
	print("Oro: %d" % bot_get_gold())
	print("Recursos: %d" % bot_get_resources())
	print("Upkeep: %d / %d" % [bot_get_upkeep(), bot_get_max_upkeep()])
	print("Trabajadores: %d" % bot_get_workers())
	
	# Probar si puede pagar una granja (ejemplo: 100 oro, 50 recursos, 1 upkeep)
	if bot_can_afford(100, 50, 1):
		print("✅ Puede pagar una granja")
		bot_consume_resources(100, 50, 1)
		print("Oro después: %d" % bot_get_gold())
	else:
		print("❌ No puede pagar una granja")
	print("===========================\n")

func _run_ai(delta: float) -> void:
	# Lógica principal del bot
	pass

func _decide_next_action() -> void:
	# Máquina de estados / árbol de decisión
	pass


# ==============================
# 📦 GESTIÓN DE RECURSOS
# ==============================

# 🪙 Obtener oro actual
func bot_get_gold() -> int:
	return gold

# 🌾 Obtener recursos actuales
func bot_get_resources() -> int:
	return resources

# ⚙️ Obtener mantenimiento actual / máximo
func bot_get_upkeep() -> int:
	return upkeep

func bot_get_max_upkeep() -> int:
	return maxUpKeep

# 👷 Obtener cantidad de trabajadores
func bot_get_workers() -> int:
	return workers

# 💰 Verificar si puede pagar algo (oro, recursos, upkeep)
func bot_can_afford(cost_gold: int = 0, cost_resources: int = 0, cost_upkeep: int = 0) -> bool:
	var has_gold = gold >= cost_gold
	var has_resources = resources >= cost_resources
	var has_upkeep_space = (upkeep + cost_upkeep) <= maxUpKeep
	
	return has_gold and has_resources and has_upkeep_space

# 💸 Consumir recursos (usar después de verificar bot_can_afford)
func bot_consume_resources(cost_gold: int = 0, cost_resources: int = 0, cost_upkeep: int = 0) -> void:
	gold -= cost_gold
	resources -= cost_resources
	upkeep += cost_upkeep
	update_team_hud()
	
	print("🤖 %s consumió: Oro=%d, Recursos=%d, Upkeep=%d" % [player_name, cost_gold, cost_resources, cost_upkeep])

# ==============================
# 🏗️ CONSTRUCCIÓN DE EDIFICIOS
# ==============================

# 🔍 Encontrar posición válida para construir cerca del castillo
func bot_find_build_position(radius: float = 50.0, max_attempts: int = 20) -> Vector3:
	# 🔥 BUSCAR CASTILLO EN EL ARRAY DE EDIFICIOS
	var castle = _bot_get_castle()
	
	if castle == null:
		print("❌ Bot: No tiene castillo")
		return Vector3.ZERO
	
	var castle_pos = castle.global_position
	
	for attempt in range(max_attempts):
		# Generar posición aleatoria alrededor del castillo
		var angle = randf() * TAU
		var distance = randf_range(20.0, radius)
		var offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		var test_pos = castle_pos + offset
		
		# Verificar si es válida
		if _bot_is_position_valid(test_pos):
			print("✅ Bot: Posición válida encontrada en intento %d: %v" % [attempt + 1, test_pos])
			return test_pos
	
	print("⚠️ Bot: No se encontró posición válida después de %d intentos" % max_attempts)
	return Vector3.ZERO

# 🏰 Obtener el castillo del bot
func _bot_get_castle() -> Building:
	for building in buildings:
		if is_instance_valid(building):
			# Verificar si es un castillo por nombre de clase o script
			var script_path = building.get_script(). resource_path if building.get_script() else ""
			
			# Opción 1: Por ruta del script
			if "medievalCastle" in script_path:
				return building
			
			# Opción 2: Por nombre del nodo
			if "Castle" in building.name:
				return building
			
			# Opción 3: Por tipo de edificio (si tiene la propiedad)
			if "building_type" in building and building.building_type == "castle":
				return building
	
	return null

# 🔍 Verificar si una posición es válida (sin colisiones)
func _bot_is_position_valid(pos: Vector3, check_radius: float = 15.0) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D. new()
	shape.radius = check_radius
	query.shape = shape
	query.transform = Transform3D(Basis(), pos)
	
	# Solo detectar edificios del mismo jugador
	var player_layer = 2 + player_index
	query.collision_mask = 1 << player_layer
	
	var results = space_state.intersect_shape(query, 10)
	
	return results. size() == 0

# 🏗️ Construir edificio en posición específica
func bot_build_building(building_type: String, position: Vector3) -> Building:
	print("🤖 %s construyendo '%s' en %v" % [player_name, building_type, position])
	
	# 1. Validar posición
	if position == Vector3.ZERO or not _bot_is_position_valid(position):
		print("❌ Bot: Posición inválida o ocupada")
		return null
	
	# 2.  Cargar escena del edificio
	var building_scene = _get_building_scene_path(building_type)
	if building_scene == "":
		print("❌ Bot: Tipo de edificio desconocido: %s" % building_type)
		return null
	
	var scene = load(building_scene)
	if scene == null:
		print("❌ Bot: No se pudo cargar escena")
		return null
	
	# 3. Instanciar
	var building = scene.instantiate()
	if building == null:
		return null
	
	# 4. Configurar
	building.global_position = position
	building.scale = _get_building_scale_vector(building_type)
	
	# 5. Añadir al mapa
	var parent_node = get_battle_map() if is_battle_mode else get_base_map()
	if parent_node == null:
		building.queue_free()
		return null
	
	parent_node.add_child(building)
	await get_tree().process_frame
	
	# 6. Registrar
	add_building(building)
	
	print("✅ Bot: Edificio '%s' construido" % building_type)
	return building

# 📋 Obtener todos los edificios
func bot_get_all_buildings() -> Array[Building]:
	return buildings

# ==============================
# 🔧 AUXILIARES MÍNIMAS
# ==============================

func _get_building_scene_path(type: String) -> String:
	match type:
		"barracks": return "res://Scenes/Game/buildings/medievalBarracks/medievalBarracks_controller.tscn"
		"dragon": return "res://Scenes/Game/buildings/medievalHatchery/medievalHatchery_controller.tscn"
		"farm": return "res://Scenes/Game/buildings/medivalFarm/medievalFarm_controller. tscn"
		"harbor": return "res://Scenes/Game/buildings/medievalHarbor/medievalHarbor_controller.tscn"
		"magic": return "res://Scenes/Game/buildings/medievalMagic/medievalMagic_controller.tscn"
		"shrine": return "res://Scenes/Game/buildings/medievalShrine/medievalShrine_controller.tscn"
		"smithy": return "res://Scenes/Game/buildings/medievalSmithy/medievalSmithy_controller.tscn"
		"tower": return "res://Scenes/Game/buildings/medievalTower/medievalTower_controller.tscn"
		_: return ""

func _get_building_scale_vector(type: String) -> Vector3:
	match type:
		"barracks": return Vector3(30, 30, 30)
		"dragon": return Vector3(25, 25, 25)
		"farm": return Vector3(15, 15, 15)
		"harbor": return Vector3(20, 20, 20)
		"magic": return Vector3(25, 25, 25)
		"shrine": return Vector3(22, 22, 22)
		"smithy": return Vector3(18, 18, 18)
		"tower": return Vector3(25, 25, 25)
		_: return Vector3(10, 10, 10)
