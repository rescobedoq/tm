extends CharacterBody3D
class_name Hatchery
const BUILDING_SCALE: int = 25

func _ready():
	scale = Vector3(BUILDING_SCALE, BUILDING_SCALE, BUILDING_SCALE)
	_setup_proximity_area()

func _setup_proximity_area():
	var area = get_node_or_null("Area3D")
	if area == null:
		print("❌ No se encontró Area3D")
		return
	
	# Configurar capas de colisión
	area.collision_layer = 1 << 3  # Layer 4
	area.collision_mask = 1 << 3   # Detecta Layer 4
	
	print("✅ Area3D de Barracks configurada en Layer 4")
