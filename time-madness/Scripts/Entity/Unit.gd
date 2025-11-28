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
		print("GROUND!!!!!!!!!!!!!!!!!!!!!!!!!")
		collision_mask |= 1 << 4  # Añadir Layer 5 a la máscara
	elif unit_category == "aquatic":
		print("uatic!!!!!!!!!!!!!!!!!!!!!!!!!")
		collision_mask |= 1 << 9
