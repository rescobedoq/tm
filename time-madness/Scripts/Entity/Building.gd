# Building.gd
extends Entity
class_name Building

class BuildingAbility:
	var icon: String 
	var name: String
	var description: String 
	
	func _init(p_icon: String, p_name: String, p_description: String):
		icon = p_icon
		name = p_name
		description = p_description
		
		
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
