# Unit.gd
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
@export var current_magic: float


# ------------------------------------------
# Movimiento
# ------------------------------------------
var velocity: Vector3 = Vector3.ZERO
var move_target: Vector3
var is_moving: bool = false

# Estas animaciones NO se implementan aquí.
# Cada unidad las sobreescribe con sus propias animaciones.
func play_idle() -> void:
	pass

func play_move() -> void:
	pass

func play_attack() -> void:
	pass

# ------------------------------------------
# Movimiento hacia un punto
# ------------------------------------------
func move_to(target: Vector3, delta: float) -> void:
	if not is_alive:
		return

	move_target = target
	var direction = target - global_position
	direction.y = 0

	if direction.length() > 0.1:
		if not is_moving:
			is_moving = true
			play_move()

		velocity = direction.normalized() * move_speed
		global_translate(velocity * delta)
	else:
		if is_moving:
			is_moving = false
			play_idle()


# ------------------------------------------
# Ataque
# ------------------------------------------
func attack(target: Entity) -> void:
	if not is_alive or not target.is_alive:
		return

	var dist := global_position.distance_to(target.global_position)

	if dist <= attack_range:
		play_attack()
		target.take_damage(attack_damage)
	else:
		# Acercarse al enemigo
		move_to(target.global_position, get_process_delta_time())
		
func _ready() -> void:
	play_idle()
