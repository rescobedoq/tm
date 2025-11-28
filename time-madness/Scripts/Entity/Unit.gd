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
@export var attack_range: float = 50.0
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

# Radio de llegada
@export var arrival_radius: float = 2.0

# 🔥 Sistema de ataque
var attack_target_entity: Entity = null
var is_attacking: bool = false
var attack_timer: float = 0.0
@export var attack_cooldown: float = 1.5  # Tiempo entre ataques

# 💀 Sistema de muerte
var is_dying: bool = false
var death_timer: float = 0.0
@export var death_animation_duration: float = 2.0  # Duración de la animación de muerte

# ------------------------------------------
# Animaciones
# ------------------------------------------
func play_idle() -> void:
	pass

func play_move() -> void:
	pass

func play_attack() -> void:
	pass

func play_death() -> void:
	pass


class UnitAbility:
	var icon: String 
	var name: String
	var description: String
	var ability_id: String  
	
	func _init(p_icon: String, p_name: String, p_description: String, p_ability_id: String = ""):
		icon = p_icon
		name = p_name
		description = p_description
		ability_id = p_ability_id
		
var abilities: Array[UnitAbility] = []


# ------------------------------------------
# 🔥 Ordenar ataque a un objetivo
# ------------------------------------------
func attack_target(target: Entity) -> void:
	if not is_alive or target == null:
		return
	
	attack_target_entity = target
	is_attacking = true
	has_move_target = false  # Cancelar movimiento normal
	print("⚔️ %s iniciando ataque a %s" % [name, target.name])

# ------------------------------------------
# Movimiento hacia un punto
# ------------------------------------------
func move_to(target: Vector3, custom_radius: float = -1.0) -> void:
	if not is_alive:
		return

	# Cancelar ataque si estábamos atacando
	attack_target_entity = null
	is_attacking = false

	move_target = target
	has_move_target = true
	
	if custom_radius > 0:
		arrival_radius = custom_radius

# ------------------------------------------
# 💀 Recibir daño (Override de Entity)
# ------------------------------------------
func take_damage(amount: float) -> void:
	if not is_alive or is_dying:
		return
	
	var actual_damage = max(0, amount - defense)
	current_health -= actual_damage
	
	print("💥 %s recibió %.1f de daño (vida: %.1f/%.1f)" % [name, actual_damage, current_health, max_health])
	
	# 💀 Verificar si murió
	if current_health <= 0:
		current_health = 0
		_trigger_death()

# ------------------------------------------
# 💀 Activar muerte
# ------------------------------------------
func _trigger_death() -> void:
	if is_dying:
		return
	
	print("💀 %s HA MUERTO" % name)
	
	is_alive = false
	is_dying = true
	death_timer = death_animation_duration
	
	# Cancelar cualquier acción
	_cancel_attack()
	has_move_target = false
	is_moving = false
	velocity = Vector3.ZERO
	
	# Reproducir animación de muerte
	play_death()
	
	# Notificar al dueño que la unidad murió
	if player_owner and player_owner.has_method("_on_unit_died"):
		player_owner._on_unit_died(self)

func _physics_process(delta: float) -> void:
	# 💀 Si está muriendo, solo contar el timer
	if is_dying:
		death_timer -= delta
		if death_timer <= 0:
			_finish_death()
		return
	
	if not is_alive:
		return
	
	# 🔥 MODO ATAQUE: Perseguir y atacar
	if is_attacking and attack_target_entity != null:
		_handle_attack_behavior(delta)
		return
	
	# MODO MOVIMIENTO NORMAL
	if not has_move_target:
		velocity = Vector3.ZERO
		return

	var direction = move_target - global_position
	direction. y = 0
	var distance = direction.length()

	if distance > arrival_radius:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation. y, target_rot, rotation_speed * delta)

		if not is_moving:
			is_moving = true
			play_move()

		velocity = direction.normalized() * move_speed
		move_and_slide()
	else:
		velocity = Vector3. ZERO
		has_move_target = false
		if is_moving:
			is_moving = false
			play_idle()

# ------------------------------------------
# 🔥 Comportamiento de ataque
# ------------------------------------------
func _handle_attack_behavior(delta: float) -> void:
	# Verificar que el objetivo sigue vivo
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		print("🛑 Objetivo perdido o muerto, cancelando ataque")
		_cancel_attack()
		return
	
	var direction = attack_target_entity.global_position - global_position
	direction. y = 0
	var distance = direction.length()
	
	# 🔥 SI ESTÁ FUERA DE RANGO: PERSEGUIR
	if distance > attack_range:
		var target_rot = atan2(direction.x, direction. z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if not is_moving:
			is_moving = true
			play_move()
		
		velocity = direction.normalized() * move_speed
		move_and_slide()
		
		print("🏃 Persiguiendo a %s (distancia: %.2f / rango: %.2f)" % [attack_target_entity. name, distance, attack_range])
	
	# 🔥 SI ESTÁ EN RANGO: ATACAR
	else:
		velocity = Vector3. ZERO
		
		if is_moving:
			is_moving = false
			play_idle()
		
		# Rotar hacia el objetivo
		var target_rot = atan2(direction. x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		# Cooldown de ataque
		attack_timer -= delta
		if attack_timer <= 0:
			_perform_attack()
			attack_timer = attack_cooldown

# ------------------------------------------
# 🔥 Ejecutar el ataque
# ------------------------------------------
func _perform_attack() -> void:
	if attack_target_entity == null or not attack_target_entity.is_alive:
		_cancel_attack()
		return
	
	print("⚔️ %s ATACANDO a %s (daño: %.1f)" % [name, attack_target_entity. name, attack_damage])
	play_attack()
	
	# Aplicar daño al objetivo
	if attack_target_entity. has_method("take_damage"):
		attack_target_entity. take_damage(attack_damage)
	else:
		print("⚠️ El objetivo no tiene método take_damage()")

# ------------------------------------------
# 🔥 Cancelar ataque
# ------------------------------------------
func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	
	if is_moving:
		is_moving = false
		play_idle()

# ------------------------------------------
# 💀 Finalizar muerte y eliminar unidad
# ------------------------------------------
func _finish_death() -> void:
	print("🪦 %s removido del juego" % name)
	queue_free()

func _ready() -> void:
	super._ready()
	setup_collision_layers()
	play_idle()

func setup_collision_layers() -> void:
	collision_layer = 1 << 1              
	collision_mask = (1 << 1) | (1 << 3) 

	if unit_category == "ground":
		print("GROUND UNIT - Puede chocar con terreno")
		collision_mask |= 1 << 4
	elif unit_category == "aquatic":
		print("AQUATIC UNIT")
		collision_mask |= 1 << 9


func use_ability(ability):
	print("Ejecutando habilidad de UNIDAD:", ability.name)
