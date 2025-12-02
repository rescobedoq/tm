# Building.gd
extends CharacterBody3D  # ← Debe extender CharacterBody3D, no Entity
class_name Building

class BuildingAbility:
	var icon: String 
	var name: String
	var description: String
	var ability_id: String  
	
	func _init(p_icon: String, p_name: String, p_description: String, p_ability_id: String = ""):
		icon = p_icon
		name = p_name
		description = p_description
		ability_id = p_ability_id
		
var abilities: Array[BuildingAbility] = []

const BUILDING_SCALES = {
	"barracks": 30,
	"dragon": 25,
	"farm": 15,
	"harbor": 20,
	"magic": 25,
	"shrine": 22,
	"smithy": 18,
	"tower": 25
}
const BUILDING_PORTRAITS = {
	"castle": "res://Assets/Images/Portraits/Buildings/medievalCasle.jpg",
	"barracks": "res://Assets/Images/Portraits/Buildings/medievalBarracks.jpg",
	"dragon": "res://Assets/Images/Portraits/Buildings/medievalHatchery.jpg",
	"farm": "res://Assets/Images/Portraits/Buildings/medievalFarm.jpg",
	"harbor": "res://Assets/Images/Portraits/Buildings/medievalHarbor.jpg",
	"magic": "res://Assets/Images/Portraits/Buildings/medievalMagicSchool.jpg",
	"shrine": "res://Assets/Images/Portraits/Buildings/medievalForestShrine.jpg",
	"smithy": "res://Assets/Images/Portraits/Buildings/medievalSmithy.jpg",
	"tower": "res://Assets/Images/Portraits/Buildings/medievalTower.jpg"
}

# 🔥 NUEVO: Atributos de Entity que necesita Building
@export var entity_name := "Edificio"
@export var current_health := 1000.0
@export var max_health := 1000.0
@export var is_alive := true
@export var portrait: Texture2D
@export var player_owner: Node

static func get_building_scale_value(building_type: String) -> int:
	return BUILDING_SCALES.get(building_type, 10)

static func get_building_portrait_path(building_type: String) -> String:
	return BUILDING_PORTRAITS.get(building_type, "")

func get_building_scale() -> int:
	return 10
	
func get_building_portrait() -> String:
	return ""

func _ready():
	
	_setup_building()

func _setup_building():
	setup_collision_layers()
	#var scale_value = get_building_scale()
	#scale = Vector3(scale_value, scale_value, scale_value)
	
	# 🔥 CONFIGURAR COLISIONES DEL CHARACTERBODY3D
	collision_layer = 1 << 3  # Layer 4 (edificios)
	collision_mask = 0         # No necesita detectar nada
	
	_setup_proximity_area()
	
func setup_collision_layers() -> void:
	# Por defecto Layer 4 (Player 2 / índice 2)
	# Esto se sobrescribirá cuando se asigne al jugador
	collision_layer = 1 << 4
	collision_mask = 0
	
	print("✅ Collision layers configurados para edificio (temporal)")

# 🔥 NUEVA FUNCIÓN: Configurar capas según el jugador
func setup_player_collision_layers(player_idx: int) -> void:
	var player_layer = 2 + player_idx  # 2-7
	
	# Este edificio está en la capa de su jugador
	collision_layer = 1 << player_layer
	
	# Los edificios no necesitan detectar nada (son estáticos)
	collision_mask = 0
	
	print("✅ [%s] Edificio configurado - Layer: %d (Jugador %d)" % [name, player_layer, player_idx])
	
	
func _setup_proximity_area():
	var area = get_node_or_null("Area3D")
	if area == null:
		print("⚠️ No se encontró Area3D en ", get_class())
		return
	
	# 🔥 El Area3D detecta edificios del MISMO jugador
	area.collision_layer = 0
	
	if player_owner and player_owner.has("player_index"):
		var player_layer = 2 + player_owner.player_index
		area. collision_mask = 1 << player_layer
		print("✅ Area3D configurada para detectar edificios del jugador %d" % player_owner.player_index)
	else:
		# Fallback temporal
		area.collision_mask = 1 << 4

func use_ability(ability: BuildingAbility) -> void:
	print("🏰 Usando habilidad:", ability.name, "en edificio:", get_class())
	
	var method_name = "_" + ability.ability_id
	
	if has_method(method_name):
		call(method_name)
	else:
		print("⚠️ Habilidad no implementada:", ability.ability_id, "- Método esperado:", method_name)

# ==============================
# 🔥 FUNCIÓN GENÉRICA DE ENTRENAMIENTO
# ==============================
@onready var col_shape: CollisionShape3D = get_node("CollisionShape3D")

func _train_unit(unit_scene: PackedScene, cost: Dictionary, unit_name: String) -> void:
	
	if unit_scene == null:
		print("❌ Escena de unidad no encontrada para:", unit_name)
		return
	
	var player = _get_player_owner()
	if player == null:
		print("❌ No se encontró PlayerController para el edificio")
		return
	
	if not _check_resources(player, cost):
		print("⚠️ Recursos insuficientes para entrenar", unit_name)
		return  
	
	# Deducir recursos
	player.gold -= cost.gold
	player.resources -= cost.resources
	player.upkeep += cost.upkeep
	player.update_team_hud()
	
	# Instanciar unidad
	var new_unit = unit_scene.instantiate()
	var parent_node: Node
	if GameStarter.is_battle_stage:
		parent_node = GameStarter.battle_map_instance
	else:
		# Obtener BaseMap desde GameScene
		var game_manager = player.get_parent()
		var game_scene = game_manager.get_parent()
		parent_node = game_scene.get_node_or_null("BaseMap")
	
	if parent_node == null:
		print("❌ No se pudo obtener el mapa para spawn")
		new_unit.queue_free()
		return
	
	parent_node.add_child(new_unit)
	
	await get_tree().process_frame
	
	if new_unit.unit_category == "aquatic":
		new_unit. global_position = _get_random_water_position()
	else:
		var min_dist := 20.0
		var max_dist := 20.0
		var angle := randf() * TAU
		var direction := Vector3(cos(angle), 0, sin(angle))
		var distance := randf_range(min_dist, max_dist)
		var spawn_offset := direction * distance
		new_unit. global_position = global_position + spawn_offset
	
	# Agregar al jugador
	if new_unit is Entity:
		player.add_unit(new_unit)
	
	print("✅", unit_name, "entrenado exitosamente en", new_unit.global_position)

func _get_player_owner() -> Node:
	if player_owner != null:
		return player_owner
	var base_map = get_parent()
	if base_map:
		var player_controller = base_map.get_parent()
		if player_controller and player_controller.has_method("add_building"):
			player_owner = player_controller 
			return player_controller
	
	print("❌ No se pudo encontrar PlayerController para:", name)
	return null
	
func _check_resources(player: Node, cost: Dictionary) -> bool:
	if player.gold < cost.gold:
		return false
	if player.resources < cost.resources:
		return false
	if player.upkeep + cost.upkeep > player.maxUpKeep:
		print("⚠️ Límite de mantenimiento alcanzado")
		return false
	return true
	
func _get_random_water_position() -> Vector3:
	var player = _get_player_owner()
	if player == null:
		print("❌ No se pudo encontrar player para spawn acuático")
		return Vector3(0, -1, 0)
	
	# 🔥 Obtener BaseMap desde GameScene
	var game_manager = player.get_parent()
	var game_scene = game_manager.get_parent()
	var base_map = game_scene.get_node_or_null("BaseMap")
	
	if base_map == null:
		print("❌ No se encontró BaseMap")
		return Vector3(0, -1, 0)
	
	var collision_shape = base_map.get_node_or_null("Water/Area3D/CollisionShape3D")
	if collision_shape == null:
		print("❌ No se encontró CollisionShape3D del agua")
		return Vector3(0, -1, 0)
	
	var shape = collision_shape.shape
	var center = collision_shape.global_position
	
	var margin = 10.0
	var half_x = (shape.size.x / 2.0) - margin
	var half_z = (shape.size.z / 2.0) - margin
	
	return Vector3(
		center.x + randf_range(-half_x, half_x),
		-1.0,
		center.z + randf_range(-half_z, half_z)
	)
