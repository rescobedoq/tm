# Entity.gd
extends Node3D
class_name Entity

@export var entity_name: String = "Entidad"
@export var health: float = 100
@export var max_health: float = 100
@export var move_speed: float = 10.0
@export var is_alive: bool = true
@export var selected: bool = false:
	set(value):
		print("=== SET SELECTED ===")
		selected = value
		print("Selected cambió a: ", value)
		_update_selection_visual()

@onready var model: Node3D = $Model
var selection_indicator: Sprite3D

func _ready():
	print("=== ENTITY READY ===")
	print("Entity _ready() llamado")
	print("Model: ", model)
	set_process_input(true)
	_create_selection_indicator()

func _create_selection_indicator():
	print("=== CREATE SELECTION INDICATOR ===")
	print("Creando selection indicator")
	
	selection_indicator = Sprite3D.new()
	print("Sprite3D creado: ", selection_indicator)
	
	var texture = load("res://Assets/Images/UI/Chaos Toroidal 303.png")
	print("Textura cargada: ", texture)
	
	if texture == null:
		print("ERROR: No se pudo cargar la textura")
		print("Selection indicator NO se creó por falta de textura")
		selection_indicator = null
		return
	
	selection_indicator.texture = texture
	selection_indicator.pixel_size = 0.02
	selection_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	selection_indicator.visible = false
	
	add_child(selection_indicator)
	print("Selection indicator añadido como hijo")
	print("Número de hijos ahora: ", get_child_count())
	
	call_deferred("_position_selection_indicator")

func _position_selection_indicator():
	print("=== POSITION SELECTION INDICATOR ===")
	print("selection_indicator en _position: ", selection_indicator)
	
	if selection_indicator == null:
		print("ERROR CRÍTICO: selection_indicator es null en _position_selection_indicator")
		return
		
	var aabb = get_aabb()
	print("AABB calculado: ", aabb)
	print("AABB size: ", aabb.size)
	print("AABB volume: ", aabb.get_volume())
	
	if aabb.size != Vector3.ZERO:
		selection_indicator.position.y = -aabb.size.y / 2 - 0.2
		print("Posicionado en base del modelo")
	else:
		selection_indicator.position.y = -1.0
		print("Posicionado en altura por defecto")
	
	print("Posición final del indicator: ", selection_indicator.position)
	print("Selection indicator visible: ", selection_indicator.visible)

func _update_selection_visual():
	print("=== UPDATE SELECTION VISUAL ===")
	print("selection_indicator: ", selection_indicator)
	print("selected: ", selected)
	
	if selection_indicator == null:
		print("ERROR CRÍTICO: Selection indicator es null")
		print("Intentando recrear...")
		_create_selection_indicator()
		if selection_indicator == null:
			print("FALLO TOTAL: No se pudo crear selection indicator")
			return
		else:
			print("Selection indicator recreado exitosamente")
	
	print("Selection indicator existe, estableciendo visible = ", selected)
	selection_indicator.visible = selected
	print("Visible establecido a: ", selection_indicator.visible)

func get_aabb() -> AABB:
	print("=== GET AABB ===")
	print("Model: ", model)
	print("Model es MeshInstance3D: ", model is MeshInstance3D)
	
	if model and model is MeshInstance3D:
		var aabb = model.get_aabb()
		print("AABB del modelo: ", aabb)
		return aabb
	
	print("Usando AABB por defecto")
	return AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1))

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("=== INPUT DETECTADO ===")
		print("Click detectado")
		
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		print("Cámara: ", camera)
		
		if camera == null:
			print("ERROR: No hay cámara")
			return
			
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		print("Ray from: ", from, " to: ", to)
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		
		var result = space_state.intersect_ray(query)
		print("Resultado del raycast: ", result)
		
		if result and result.collider == self:
			print("Click en esta entidad")
			_on_click()
		else:
			print("Click no en esta entidad")

func _on_click():
	print("=== ON CLICK ===")
	print("_on_click llamado")
	selected = true
	print("Seleccionado: ", entity_name)

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	health -= amount
	if health <= 0:
		die()

func heal(amount: float) -> void:
	if not is_alive:
		return
	health = min(health + amount, max_health)

func die() -> void:
	is_alive = false
	if model:
		model.visible = false
	print("%s ha sido destruida" % name)

func move_to(target_position: Vector3, delta: float) -> void:
	if not is_alive:
		return
	var direction = (target_position - global_position)
	if direction.length() > 0.1:
		direction = direction.normalized()
		global_translate(direction * move_speed * delta)
