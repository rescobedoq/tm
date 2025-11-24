# Building.gd
extends CharacterBody3D
class_name Building

# 🔥 Diccionario de escalas (accesible sin instanciar)
const BUILDING_SCALES = {
	"barracks": 30,
	"dragon": 35,
	"farm": 15,
	"harbor": 20,
	"magic": 25,
	"shrine": 22,
	"smithy": 18,
	"tower": 25
}

# Función estática para obtener escala sin instanciar
static func get_building_scale_value(building_type: String) -> int:
	return BUILDING_SCALES.get(building_type, 10)

func get_building_scale() -> int:
	return 10  # Valor por defecto, los hijos lo sobrescriben

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
