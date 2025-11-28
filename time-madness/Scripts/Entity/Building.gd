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
	var scale_value = get_building_scale()
	scale = Vector3(scale_value, scale_value, scale_value)
	
	# 🔥 CONFIGURAR COLISIONES DEL CHARACTERBODY3D
	collision_layer = 1 << 3  # Layer 4 (edificios)
	collision_mask = 0         # No necesita detectar nada
	
	_setup_proximity_area()
	
func setup_collision_layers() -> void:
	# Edificios en Layer 4
	collision_layer = 1 << 3  # 8 en decimal (binario: 00001000)
	collision_mask = 0         # No necesita detectar nada
	
	print("✅ Collision layers configurados para edificio: Layer 4")
	
	
func _setup_proximity_area():
	var area = get_node_or_null("Area3D")
	if area == null:
		print("⚠️ No se encontró Area3D en ", get_class())
		return
	
	# El Area3D detecta edificios cercanos para validar construcción
	area.collision_layer = 0       # No está en ningún layer
	area.collision_mask = 1 << 3   # Detecta Layer 4 (otros edificios)
	
	print("✅ Area3D configurada para detectar otros edificios en ", get_class())

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
	get_tree().current_scene.add_child(new_unit)
	
	await get_tree().process_frame
	
	if new_unit.unit_category == "aquatic":
		# 🌊 Unidades acuáticas: spawn en área de agua
		var spawn_pos = _get_random_water_position()
		if spawn_pos != Vector3.ZERO:
			new_unit.global_position = spawn_pos
			print("🚢 Unidad acuática generada en agua:", spawn_pos)
		else:
			print("❌ No se encontró área de agua, spawn en posición del edificio")
			new_unit.global_position = global_position
	else:
		# 🚶 Unidades terrestres/voladoras: spawn cerca del edificio
		var min_dist := 15.0
		var max_dist := 20.0
		var angle := randf() * TAU
		var direction := Vector3(cos(angle), 0, sin(angle))
		var distance := randf_range(min_dist, max_dist)
		var spawn_offset := direction * distance
		new_unit.global_position = global_position + spawn_offset

	
	# 🔥 NO TOCAR AQUÍ - La configuración ya está en Unit.setup_collision_layers()
	# Las unidades YA tienen:
	# - collision_layer = 2 (Layer 2)
	# - collision_mask = 2 + 4 (Detecta unidades y edificios)
	
	# Agregar al jugador
	if new_unit is Entity:
		player.add_unit(new_unit)
	
	print("✅", unit_name, "entrenado exitosamente en", global_position)

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


# 🔥 Obtener una posición aleatoria dentro del área de agua
func _get_random_water_position() -> Vector3:
	var player = _get_player_owner()
	if player == null:
		return Vector3. ZERO
	
	# Buscar BaseMap → Water → Area3D
	var base_map = player.get_node_or_null("BaseMap")
	if base_map == null:
		print("❌ No se encontró BaseMap")
		return Vector3.ZERO
	
	var water = base_map.get_node_or_null("Water")
	if water == null:
		print("❌ No se encontró Water en BaseMap")
		return Vector3.ZERO
	
	var water_area = water.get_node_or_null("Area3D")
	if water_area == null:
		print("❌ No se encontró Area3D en Water")
		return Vector3.ZERO
	
	# Obtener el CollisionShape3D del área
	var collision_shape = water_area.get_node_or_null("CollisionShape3D")
	if collision_shape == null:
		print("❌ No se encontró CollisionShape3D en Area3D del agua")
		return Vector3. ZERO
	
	var shape = collision_shape.shape
	if shape == null:
		return Vector3.ZERO
	
	# 🔥 Generar posición aleatoria según el tipo de shape
	var random_pos := Vector3.ZERO
	
	if shape is BoxShape3D:
		var box_size = shape.size
		random_pos = Vector3(
			randf_range(-box_size.x / 2, box_size.x / 2),
			0,
			randf_range(-box_size.z / 2, box_size.z / 2)
		)
	elif shape is CylinderShape3D:
		var radius = shape.radius
		var angle = randf() * TAU
		var distance = randf() * radius
		random_pos = Vector3(
			cos(angle) * distance,
			0,
			sin(angle) * distance
		)
	else:
		print("⚠️ Tipo de shape no soportado:", shape.get_class())
		return Vector3.ZERO
	
	# Convertir a posición global
	var global_pos = water_area.global_position + random_pos
	
	return global_pos
