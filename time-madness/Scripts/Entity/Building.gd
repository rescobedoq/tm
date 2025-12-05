# Building.gd
extends CharacterBody3D  # ← Debe extender CharacterBody3D, no Entity
class_name Building
@export var building_type: String = ""  # ej: "barracks", "harbor", etc.


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
	initialize_abilities()
	pass
	#_setup_building()

func initialize_for_player(player: Node) -> void:
	player_owner = player
	
	print("\n🔍 ========== DEBUG BUILDING ==========")
	print("🏗️ Edificio: %s" % name)
	print("👤 Player: %s" % (player.player_name if "player_name" in player else "Unknown"))
	print("🔢 Player Index: %s" % (player.player_index if "player_index" in player else "NULL"))
	
	if "player_index" in player:
		setup_player_collision_layers(player.player_index)
	else:
		print("❌ El player no tiene player_index")
	
	_setup_proximity_area()
	
	# 🔍 Verificar collision layers DESPUÉS de configurar
	print("\n📊 CharacterBody3D Collision:")
	print("   collision_layer = %d (binario: %s)" % [collision_layer, String. num_uint64(collision_layer, 2)])
	print("   collision_mask = %d (binario: %s)" % [collision_mask, String.num_uint64(collision_mask, 2)])
	
	var area = get_node_or_null("Area3D")
	if area:
		print("\n📊 Area3D Collision:")
		print("   collision_layer = %d (binario: %s)" % [area.collision_layer, String.num_uint64(area.collision_layer, 2)])
		print("   collision_mask = %d (binario: %s)" % [area. collision_mask, String.num_uint64(area.collision_mask, 2)])
	
	print("🔍 ====================================\n")
	
func _setup_building():
	#var scale_value = get_building_scale()
	#scale = Vector3(scale_value, scale_value, scale_value)
	
	# 🔥 CONFIGURAR COLISIONES DEL CHARACTERBODY3D
	collision_layer = 1 << 3  # Layer 4 (edificios)
	collision_mask = 0         # No necesita detectar nada
	
	_setup_proximity_area()
	


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
		print("⚠️ No se encontró Area3D en ", name)
		return
	
	if player_owner == null or not ("player_index" in player_owner):
		print("❌ player_owner no válido para configurar Area3D")
		return
	
	var player_layer = 2 + player_owner. player_index
	
	area. collision_layer = 0
	area.collision_mask = 1 << player_layer
	
	# 🔍 CONECTAR SEÑALES PARA DEBUG
	if not area.body_entered.is_connected(_on_area_body_entered):
		area.body_entered.connect(_on_area_body_entered)
	if not area.body_exited.is_connected(_on_area_body_exited):
		area.body_exited. connect(_on_area_body_exited)
	
	print("✅ Area3D de '%s' configurada - Detecta layer %d" % [name, player_layer])

# 🔍 FUNCIONES DE DEBUG
func _on_area_body_entered(body: Node3D):
	print("🟢 [%s] Area3D detectó ENTRADA: %s" % [name, body.name])
	if body is Building:
		print("   ✅ Es un edificio!")

func _on_area_body_exited(body: Node3D):
	print("🔴 [%s] Area3D detectó SALIDA: %s" % [name, body.name])
	
func use_ability(ability: BuildingAbility) -> void:
	print("🏰 Usando habilidad:", ability.name, "en edificio:", get_class())

	# Caso especial para trabajadores ("slave")
	if ability.ability_id == "train_slave":
		_train_slave()
		return  # ya ejecutamos, no hace falta seguir

	# Para todas las demás unidades que usan singletones
	train_unit_from_ability(ability.ability_id)


func _train_slave() -> void:
	var player = _get_player_owner()
	if player == null:
		print("❌ No se encontró PlayerController")
		return

	if not player.has_method("add_worker"):
		print("❌ PlayerController no tiene método add_worker()")
		return

	player.add_worker()
	print("✅ Worker entrenado para el jugador:", player.player_name if "player_name" in player else player)

# ==============================
# 🔥 FUNCIÓN GENÉRICA DE ENTRENAMIENTO
# ==============================
func train_unit_from_ability(ability_id: String) -> void:
	if building_type == "":
		push_warning("Building '%s' tiene building_type vacío" % name)
		return
	
	var ability_list = BuildingAbilities.get_building_ability(building_type)
	
	for ability in ability_list:
		if ability["id"] == ability_id:
			var unit_key = ability["id"]  # si estás usando id como clave para UnitScenes/UnitCosts
			var scene_path = UnitScenes.get_scene(unit_key) # devuelve un string
			var scene = load(scene_path) as PackedScene
			var cost = UnitCosts.get_cost(unit_key)
			var display_name = ability["name"]
			#Invalid type in function '_train_unit' in base 'CharacterBody3D (Barracks)'. Cannot convert argument 1 from String to Object.
			print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX, ", unit_key);
			print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX, ", scene_path);
			_train_unit(scene, cost, display_name)
			return
	
	print("❌ Ability '%s' not found for building '%s'" % [ability_id, building_type])


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
	
	player.gold -= cost. gold
	player.resources -= cost.resources
	player.upkeep += cost.upkeep
	player.update_team_hud()
	
	var new_unit = unit_scene.instantiate()
	
	# 🔥 ASIGNAR PLAYER_OWNER ANTES DE AÑADIR AL ÁRBOL
	if new_unit is Entity:
		new_unit.player_owner = player
		print("✅ player_owner asignado a %s (jugador %d)" % [unit_name, player.player_index])
	
	var parent_node: Node
	if GameStarter.is_battle_stage:
		parent_node = GameStarter.battle_map_instance
	else:
		var game_manager = player.get_parent()
		var game_scene = game_manager.get_parent()
		parent_node = game_scene.get_node_or_null("BaseMap")
	
	if parent_node == null:
		print("❌ No se pudo obtener el mapa para spawn")
		new_unit.queue_free()
		return
	
	parent_node.add_child(new_unit)
	
	await get_tree().process_frame
	
	if new_unit. unit_category == "aquatic":
		new_unit. global_position = _get_random_water_position()
	else:
		var min_dist := 20.0
		var max_dist := 20.0
		var angle := randf() * TAU
		var direction := Vector3(cos(angle), 0, sin(angle))
		var distance := randf_range(min_dist, max_dist)
		var spawn_offset := direction * distance
		new_unit. global_position = global_position + spawn_offset
	
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
func initialize_abilities() -> void:
	abilities.clear()
	if building_type == "":
		push_warning("Building '%s' tiene building_type vacío" % name)
		return
	print("BXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXUILDING TYPE: ", building_type)
	for ability_dict in BuildingAbilities.get_building_ability(building_type):
		abilities.append(
			BuildingAbility.new(
				ability_dict["icon"],
				ability_dict["name"],
				ability_dict["description"],
				ability_dict["id"]
			)
		)
