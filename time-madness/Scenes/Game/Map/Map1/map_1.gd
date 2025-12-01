extends Node3D

func _ready():
	# Ocultar el mapa por defecto
	disable_map()

# 🔥 NUEVA FUNCIÓN: Deshabilitar TODO el mapa
func disable_map() -> void:
	print("❌ Map1: Deshabilitando mapa completo")
	_recursive_disable(self)

# 🔥 NUEVA FUNCIÓN: Habilitar TODO el mapa
func enable_map() -> void:
	print("✅ Map1: Habilitando mapa completo")
	_recursive_enable(self)

# 🔥 Deshabilitar recursivamente
func _recursive_disable(node: Node) -> void:
	# Ocultar visualmente
	if node is Node3D:
		node. visible = false
	elif node is CanvasItem:
		node.visible = false
	
	# Deshabilitar procesamiento
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	
	# Deshabilitar colisiones
	if node is CollisionShape3D:
		node.disabled = true
	elif node is CollisionPolygon3D:
		node.disabled = true
	elif node is Area3D:
		node.monitoring = false
		node.monitorable = false
	elif node is PhysicsBody3D:
		node.set_physics_process(false)
	
	# Deshabilitar rendering
	if node is MeshInstance3D:
		node.visible = false
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif node is Light3D:
		node.visible = false
	
	# Aplicar a todos los hijos
	for child in node. get_children():
		_recursive_disable(child)

# 🔥 Habilitar recursivamente
func _recursive_enable(node: Node) -> void:
	# Mostrar visualmente
	if node is Node3D:
		node. visible = true
	elif node is CanvasItem:
		node.visible = true
	
	# Habilitar procesamiento
	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)
	node.set_process_unhandled_input(true)
	
	# Habilitar colisiones
	if node is CollisionShape3D:
		node.disabled = false
	elif node is CollisionPolygon3D:
		node. disabled = false
	elif node is Area3D:
		node. monitoring = true
		node.monitorable = true
	elif node is PhysicsBody3D:
		node.set_physics_process(true)
	
	# Habilitar rendering
	if node is MeshInstance3D:
		node.visible = true
		node.cast_shadow = GeometryInstance3D. SHADOW_CASTING_SETTING_ON
	elif node is Light3D:
		node.visible = true
	
	# Aplicar a todos los hijos
	for child in node.get_children():
		_recursive_enable(child)
