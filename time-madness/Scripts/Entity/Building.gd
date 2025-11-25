# Building.gd
extends Entity
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
	"barracks": "res://Assets/Images/Portraits/Buildings/medievalBarracks.jpg",
	"dragon": "res://Assets/Images/Portraits/Buildings/medievalHatchery.jpg",
	"farm": "res://Assets/Images/Portraits/Buildings/medievalFarm.jpg",
	"harbor": "res://Assets/Images/Portraits/Buildings/medievalHarbor.jpg",
	"magic": "res://Assets/Images/Portraits/Buildings/medievalMagicSchool.jpg",
	"shrine": "res://Assets/Images/Portraits/Buildings/medievalForestShrine.jpg",
	"smithy": "res://Assets/Images/Portraits/Buildings/medievalSmithy.jpg",
	"tower": "res://Assets/Images/Portraits/Buildings/medievalTower.jpg"
}



# Función estática para obtener escala sin instanciar
static func get_building_scale_value(building_type: String) -> int:
	return BUILDING_SCALES.get(building_type, 10)

static func get_building_portrait_path(building_type: String) -> String:
	return BUILDING_PORTRAITS.get(building_type, "")

func get_building_scale() -> int:
	return 10  # Valor por defecto, los hijos lo sobrescriben
func get_building_portrait() -> String:
	return ""  # Valor por defecto, los hijos lo sobrescriben

func _ready():
	_setup_building()

func _setup_building():
	var scale_value = get_building_scale()
	scale = Vector3(scale_value, scale_value, scale_value)
	
	_setup_proximity_area()

func _setup_proximity_area():
	var area = get_node_or_null("Area3D")
	if area == null:
		print("⚠️ No se encontró Area3D en ", get_class())
		return
	
	area.collision_layer = 1 << 3  # Layer 4
	area.collision_mask = 1 << 3   # Detecta Layer 4
	
	print("✅ Area3D configurada en Layer 4 para ", get_class())

func use_ability(ability: BuildingAbility) -> void:
	print("🏰 Usando habilidad:", ability.name, "en edificio:", get_class())
	
	# Buscar si existe un método con el nombre del ability_id
	var method_name = "_" + ability.ability_id
	
	if has_method(method_name):
		call(method_name)
	else:
		print("⚠️ Habilidad no implementada:", ability.ability_id, "- Método esperado:", method_name)


# ==============================
# 🔥 FUNCIÓN GENÉRICA DE ENTRENAMIENTO
# ==============================
# ==============================
# 🔥 FUNCIÓN GENÉRICA DE ENTRENAMIENTO
# ==============================
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
	
	# 🔥 Esperar un frame para que la unidad esté en el árbol
	await get_tree().process_frame
	
	# Posicionar la unidad cerca del edificio
	var spawn_offset = Vector3(5, 0, 5)
	new_unit.global_position = global_position + spawn_offset
	
	# 🔥 CONFIGURAR LAYER 2 PARA UNIDADES
	if new_unit is CharacterBody3D:
		new_unit.collision_layer = 1 << 1  # Layer 2
		new_unit.collision_mask = 1       # Colisiona con Layer 1 (terreno)
		print("✅ Unidad configurada en Layer 2:", unit_name)
	
	# Agregar al jugador
	if new_unit is Entity:
		player.add_unit(new_unit)
	
	print("✅", unit_name, "entrenado exitosamente en", global_position)

# ==============================
# 🔥 FUNCIONES AUXILIARES
# ==============================
func _get_player_owner() -> Node:
	var root = get_tree().current_scene
	for child in root.get_children():
		if child.has_method("add_building"):
			if self in child.buildings:
				return child
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
