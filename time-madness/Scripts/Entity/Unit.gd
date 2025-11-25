extends Entity
class_name Unit

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
var velocity: Vector3 = Vector3.ZERO
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
		return

	var direction = move_target - global_position
	direction.y = 0
	var distance = direction.length()

	# Usar arrival_radius en vez de un valor fijo
	if distance > arrival_radius:

		# ------------------------------------------
		# ROTACIÓN SUAVE EN DIRECCIÓN DEL MOVIMIENTO
		# ------------------------------------------
		var target_rot = atan2(direction.x, direction.z)  # rotación Y
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)

		if not is_moving:
			is_moving = true
			play_move()

		velocity = direction.normalized() * move_speed
		global_translate(velocity * delta)

	else:
		# Llegó a la región objetivo
		has_move_target = false
		if is_moving:
			is_moving = false
			play_idle()

# ------------------------------------------
# Ataque
# ------------------------------------------
func attack(target: Entity) -> void:
	if not is_alive or not target.is_alive:
		return
	# Aquí se puede agregar lógica de ataque

# ------------------------------------------
# Inicialización
# ------------------------------------------
func _ready() -> void:
	play_idle()
