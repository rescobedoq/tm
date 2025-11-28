extends Entity
class_name Unit

# ------------------------------------------
# Tipo de unidad para lógica de terreno, ataques y pathfinding
# ------------------------------------------
@export var unit_category: String = "ground" # Valores: "ground", "aquatic", "flying"

# ------------------------------------------
# Atributos base de la unidad
# ------------------------------------------
@export var unit_type: String = "Default"

# ------------------------------------------
# Atributos de combate
# ------------------------------------------
@export var attack_damage: float = 10.0
@export var attack_range: float = 5.0
@export var defense: float = 5.0

# Magia
@export var max_magic: float = 50.0
@export var current_magic: float = 50.0

# ------------------------------------------
# Movimiento
# ------------------------------------------
var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false
var is_moving: bool = false

# Velocidad de rotación 
@export var rotation_speed: float = 6.0

# Radio de llegada: la unidad se detiene cuando está dentro de este radio
@export var arrival_radius: float = 2.0

# ------------------------------------------
# Animaciones (cada unidad puede sobreescribir)
# ------------------------------------------
func play_idle() -> void:
	pass

func play_move() -> void:
	pass

func play_attack() -> void:
	pass

# ------------------------------------------
# Movimiento hacia un punto
# ------------------------------------------
func move_to(target: Vector3, custom_radius: float = -1.0) -> void:
	if not is_alive:
		return

	move_target = target
	has_move_target = true
	
	# Si se pasa un radio personalizado, usarlo
	if custom_radius > 0:
		arrival_radius = custom_radius

func _physics_process(delta: float) -> void:
	if not has_move_target:
		velocity = Vector3.ZERO
		return

	var direction = move_target - global_position
	direction.y = 0
	var distance = direction.length()

	if distance > arrival_radius:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)

		if not is_moving:
			is_moving = true
			play_move()

		velocity = direction.normalized() * move_speed
		move_and_slide()  # ¡Aquí ya maneja colisiones automáticamente!
		# 🔥 Si es unidad acuática, mantenerla dentro del agua
		if unit_category == "aquatic":
			_clamp_to_water_area()
	else:
		velocity = Vector3.ZERO
		has_move_target = false
		if is_moving:
			is_moving = false
			play_idle()

func _ready() -> void:
	super._ready()
	setup_collision_layers()
	play_idle()

func setup_collision_layers() -> void:
	collision_layer = 1 << 1              
	collision_mask = (1 << 1) | (1 << 3) 

	if unit_category == "ground":
		print("LA UNIDAD ES GROUND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		collision_mask |= 1 << 4  # Añadir Layer 5 a la máscara

# 🔥 Mantener unidades acuáticas dentro del área de agua
func _clamp_to_water_area() -> void:
	# Obtener el área de agua desde el PlayerController
	if player_owner == null:
		return
	
	var base_map = player_owner.get_node_or_null("BaseMap")
	if base_map == null:
		return
	
	var water = base_map.get_node_or_null("Water")
	if water == null:
		return
	
	var water_area = water.get_node_or_null("Area3D")
	if water_area == null:
		return
	
	var collision_shape = water_area. get_node_or_null("CollisionShape3D")
	if collision_shape == null:
		return
	
	var shape = collision_shape.shape
	if shape == null:
		return
	
	var water_center = water_area.global_position
	var local_pos = global_position - water_center
	
	# 🔥 Limitar según tipo de shape
	if shape is BoxShape3D:
		var box_size = shape.size
		local_pos. x = clamp(local_pos.x, -box_size.x / 2, box_size.x / 2)
		local_pos.z = clamp(local_pos.z, -box_size.z / 2, box_size.z / 2)
		global_position = water_center + local_pos
		
	elif shape is CylinderShape3D:
		var radius = shape.radius
		var distance = Vector2(local_pos.x, local_pos.z).length()
		if distance > radius:
			var direction = Vector2(local_pos.x, local_pos.z).normalized()
			local_pos.x = direction.x * radius
			local_pos.z = direction.y * radius
			global_position = water_center + local_pos
