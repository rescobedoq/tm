extends Node3D
class_name BotController

# ==============================
# 🤖 CONFIGURACIÓN DEL BOT
# ==============================
@export var player_name: String = "Bot"
@export var player_index: int = 1
@export var is_active_player: bool = false
@export var difficult_bot: bool = true
@export var faction: String = "default"

# ==============================
# 💰 RECURSOS
# ==============================
@export var gold: int = 500
@export var resources: int = 500
@export var upkeep: int = 0
@export var maxUpKeep: int = 10
var workers: int = 0

# ==============================
# 🎯 UNIDADES Y EDIFICIOS
# ==============================
var units: Array[Entity] = []
var buildings: Array[Building] = []
var attack_units: Array[Entity] = []
var defense_units: Array[Entity] = []
var battle_units: Array[Entity] = []

# ==============================
# 🎬 ESTADOS
# ==============================
var is_battle_mode: bool = false
var is_defeated: bool = false
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
const INVULNERABILITY_DURATION: float = 2.0  # 🔥 AGREGADO

# ==============================
# ❤️ SISTEMA DE VIDAS
# ==============================
var max_lives: int = 6
var current_lives: int = 6
var battle_life_bar = null

# ==============================
# 🔄 INICIALIZACIÓN
# ==============================
func _ready() -> void:
	print("🤖 [BotController] Bot '%s' inicializado (Player %d)" % [player_name, player_index])
	create_building("castle")

	# 🔥 Crear 1 cuarteles al iniciar
	for i in range(1):
		create_building("barracks")
	for i in range(2):
		create_unit("train_soldier")
	print("🏢 Buildings del bot: ", buildings)
	print("🏢 Unidades del bot: ", units)


func _process(delta: float) -> void:
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			invulnerability_timer = 0.0
			print("🤖 [BotController] Invulnerabilidad terminada")
			
# ==============================
# 🏗️ GESTIÓN DE EDIFICIOS
# ==============================
func create_building(building_type: String) -> bool:
	# Verificar costo
	var cost = BuildingCosts.get_cost(building_type)
	if not cost or cost. size() == 0:
		print("🤖 [BotController] Edificio '%s' no tiene costo definido" % building_type)
		return false
	
	# Verificar recursos suficientes
	if gold < cost.gold or resources < cost.resources:
		print("🤖 [BotController] Recursos insuficientes para '%s'" % building_type)
		return false
	
	# Cargar escena del edificio
	var building_scene = load(BuildingScenes.get_building_path(building_type))
	if not building_scene:
		print("🤖 [BotController] No se pudo cargar la escena para '%s'" % building_type)
		return false
	
	# Instanciar edificio
	var building = building_scene.instantiate()
	building.name = "Bot_%s_%d" % [building_type, buildings.size() + 1]
	building. building_type = building_type
	
	# Añadir al arreglo
	add_building(building)
	
	# Descontar recursos
	gold -= cost.gold
	resources -= cost.resources
	
	# Actualizar límites
	if building_type == "farm":
		maxUpKeep += 5
	
	print("🤖 [BotController] Edificio '%s' añadido (Total: %d)" % [building_type, buildings.size()])
	return true

func add_building(building: Building) -> void:
	if building == null or building in buildings:
		return
	buildings.append(building)
	building.player_owner = self
	if building.has_method("setup_player_collision_layers"):
		building.setup_player_collision_layers(player_index)




# ==============================
# 🪖 GESTIÓN DE UNIDADES
# ==============================
func create_unit(unit_type: String) -> bool:
	# Obtener costo de la unidad
	var cost = UnitCosts.get_cost(unit_type)
	if not cost or cost.size() == 0:
		print("🤖 [BotController] Unidad '%s' no tiene costo definido" % unit_type)
		return false
	
	# Verificar recursos suficientes
	if gold < cost. gold or resources < cost.resources or upkeep + cost.upkeep > maxUpKeep:
		print("🤖 [BotController] Recursos insuficientes para '%s'" % unit_type)
		return false
	
	# Obtener escena de la unidad
	var scene_path = UnitScenes.get_scene(unit_type)
	if scene_path == "":
		print("🤖 [BotController] No se encontró escena para '%s'" % unit_type)
		return false
	
	var unit_scene = load(scene_path) as PackedScene
	if not unit_scene:
		print("🤖 [BotController] No se pudo cargar escena '%s'" % scene_path)
		return false
	
	# Instanciar unidad
	var new_unit = unit_scene.instantiate()
	
	# 🔥 ASIGNAR PLAYER_OWNER ANTES DE AÑADIR AL ÁRBOL
	if new_unit is Entity:
		new_unit.player_owner = self
		print("🤖 [BotController] player_owner asignado a %s" % unit_type)
	
	# 🔥 El bot NO añade unidades al mapa, solo al array
	# (No tiene BaseMap ni BattleMap visual)
	
	# Añadir a attack_units directamente
	if new_unit is Entity:
		attack_units.append(new_unit)
		units.append(new_unit)
		
		# Descontar recursos
		gold -= cost.gold
		resources -= cost. resources
		upkeep += cost.upkeep
		
		print("🤖 [BotController] Unidad '%s' creada y añadida a attack_units (Total: %d)" % [unit_type, attack_units.size()])
		return true
	else:
		new_unit.queue_free()
		print("❌ [BotController] La unidad instanciada no es Entity")
		return false

func add_unit(unit: Entity) -> void:
	if unit == null or unit in units:
		return
	
	units.append(unit)
	unit.player_owner = self
	
	if unit.has_method("setup_player_collision_layers"):
		unit.setup_player_collision_layers(player_index)
	
	if unit not in defense_units:
		defense_units.append(unit)
	
	print("🤖 [BotController] Unidad añadida: %s (Total: %d)" % [unit. name, units.size()])


# ==============================
# ⚔️ GESTIÓN DE BATALLA
# ==============================
func set_battle_mode_layers(enable: bool) -> void:
	if enable:
		# Activar capas de batalla
		for unit in battle_units:
			if not is_instance_valid(unit):
				continue
			unit.collision_layer = 1 << 8
			unit.collision_mask = (1 << 0) | (1 << 8)
			if unit.unit_category == "aquatic":
				unit.collision_mask |= 1 << 1
		print("🤖 [BotController] Capas de batalla ACTIVADAS para %s" % player_name)
	else:
		# Restaurar capas normales
		for unit in units:
			if not is_instance_valid(unit):
				continue
			if unit.has_method("setup_player_collision_layers"):
				unit.setup_player_collision_layers(player_index)
		print("🤖 [BotController] Capas de batalla DESACTIVADAS para %s" % player_name)

func transfer_attack_units_to_battle_map() -> void:
	var battle_map = GameStarter.battle_map_instance
	if not battle_map or attack_units.size() == 0:
		print("🤖 [BotController] No hay Battle Map o unidades de ataque para transferir")
		return
	
	var ground_area = battle_map.get_node_or_null("Node3D/Player%dArea3D" % (player_index + 1))
	var water_area = battle_map.get_node_or_null("Node3D/Player%dWArea3D" % (player_index + 1))
	
	if not ground_area or not water_area:
		print("🤖 [BotController] No se encontraron áreas de spawn")
		return
	
	var ground_collision = ground_area.get_node_or_null("CollisionShape3D")
	var water_collision = water_area.get_node_or_null("CollisionShape3D")
	
	if not ground_collision or not water_collision:
		print("🤖 [BotController] No se encontraron CollisionShape3D")
		return
	
	var units_to_transfer = attack_units.duplicate()
	
	for unit in units_to_transfer:
		if not is_instance_valid(unit) or not unit.is_alive:
			continue
		
		attack_units.erase(unit)
		defense_units.erase(unit)
		units.erase(unit)
		
		if unit not in battle_units:
			battle_units.append(unit)
		
		var spawn_collision = water_collision if unit.unit_category == "aquatic" else ground_collision
		var spawn_pos = _get_random_position_in_area(spawn_collision)
		
		var old_parent = unit.get_parent()
		if old_parent:
			old_parent.remove_child(unit)
		
		battle_map.add_child(unit)
		unit.collision_layer = 1 << 8
		unit.collision_mask = (1 << 0) | (1 << 8)
		if unit.unit_category == "aquatic":
			unit.collision_mask |= 1 << 1
		
		unit.global_position = spawn_pos
		unit.visible = true
		unit.set_physics_process(true)
		unit.set_process(true)
	
	await get_tree().process_frame
	attack_units. clear()
	print("🤖 [BotController] %d unidades transferidas al Battle Map" % battle_units.size())

func _get_random_position_in_area(collision_shape: CollisionShape3D) -> Vector3:
	var shape = collision_shape.shape
	var center = collision_shape.global_position
	if shape is BoxShape3D:
		var half_x = shape.size.x / 2.0
		var half_z = shape.size.z / 2.0
		return Vector3(
			center.x + randf_range(-half_x, half_x),
			center. y,
			center.z + randf_range(-half_z, half_z)
		)
	return center

func return_units_from_battle_map() -> void:
	var copy = battle_units.duplicate()
	for u in copy:
		if not is_instance_valid(u) or (u is Unit and not u.is_alive):
			battle_units.erase(u)
	print("🤖 [BotController] Unidades limpiadas del Battle Map")

# ==============================
# 💀 SISTEMA DE VIDAS Y DERROTA
# ==============================
func lose_life() -> void:
	if is_defeated or is_invulnerable:
		return
	
	current_lives -= 1
	current_lives = max(0, current_lives)
	
	print("💔 [BotController] %s perdió 1 vida (Vidas restantes: %d/%d)" % [player_name, current_lives, max_lives])
	
	# Actualizar barra de vida visual
	if battle_life_bar and is_instance_valid(battle_life_bar) and battle_life_bar.has_method("lose_life"):
		battle_life_bar.lose_life()
	
	# Activar invulnerabilidad temporal
	is_invulnerable = true
	invulnerability_timer = INVULNERABILITY_DURATION
	
	# Verificar derrota
	if current_lives <= 0:
		_on_defeat()

func _on_defeat() -> void:
	if is_defeated:
		return
	
	is_defeated = true
	
	print("💀 [BotController] %s ha sido DERROTADO" % player_name)
	
	# Ocultar/destruir todas las entidades del bot
	_hide_all_entities()
	_destroy_battle_castle()
	
	# Notificar al GameManager para verificar condiciones de victoria
	var game_manager = get_parent()
	if game_manager and game_manager.has_method("check_victory_conditions"):
		await get_tree().process_frame
		game_manager. check_victory_conditions()

func _hide_all_entities() -> void:
	for unit in battle_units + units + defense_units + attack_units:
		if is_instance_valid(unit):
			unit.visible = false
			unit.set_physics_process(false)
			unit.set_process(false)
			unit.queue_free()
	
	for building in buildings:
		if is_instance_valid(building):
			building.queue_free()
	
	print("🧹 [BotController] Todas las entidades del bot eliminadas")

func _destroy_battle_castle() -> void:
	var battle_map = GameStarter.battle_map_instance
	if not battle_map:
		return
	
	var castle_name = "BattleCastle_Player%d" % (player_index + 1)
	var castle = battle_map.get_node_or_null(castle_name)
	if castle and is_instance_valid(castle):
		castle.queue_free()
		print("🏰 [BotController] Castillo destruido: %s" % castle_name)
	
	if battle_life_bar and is_instance_valid(battle_life_bar):
		battle_life_bar.queue_free()
		battle_life_bar = null
		print("❤️ [BotController] Barra de vida eliminada")


# ==============================
# 🧹 UTILIDADES (para compatibilidad con PlayerController)
# ==============================
func disable_node_3d_recursive(node: Node) -> void:
	# El bot no tiene nodos 3D que deshabilitar, pero necesita la función para compatibilidad
	pass

func enable_node_3d_recursive(node: Node) -> void:
	# El bot no tiene nodos 3D que habilitar, pero necesita la función para compatibilidad
	pass
