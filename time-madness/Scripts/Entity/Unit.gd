extends Entity
class_name Unit

signal health_changed(current_health: float, max_health: float)
signal energy_changed(current_magic: float, max_magic: float)

var portrait_path: String = ""
# ------------------------------------------
# 🔄 Sistema de patrulla
# ------------------------------------------
var is_patrolling: bool = false
var patrol_start_point: Vector3 = Vector3.ZERO
var patrol_end_point: Vector3 = Vector3.ZERO
var patrol_target_index: int = 0  # 0 = ir a end_point, 1 = volver a start_point
@export var attack_sfx: AudioStream

@onready var anim_player = $model/AnimationPlayer 
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection
@onready var aura_controller = $Aura  

@export var anim_idle: String = ""
@export var anim_move: String = ""
@export var anim_attack: String = ""
@export var anim_death: String = ""

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
var original_move_speed: float = 0.0
var slow_timer: float = 0.0
var is_slowed: bool = false

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
func play_idle():
	if anim_player and anim_idle != "":
		anim_player.play(anim_idle)
		var anim = anim_player.get_animation(anim_idle)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR  # Idle siempre loop

func play_move():
	if anim_player and anim_move != "":
		anim_player.play(anim_move)
		var anim = anim_player.get_animation(anim_move)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR  # Movimiento siempre loop

func play_attack():
	if anim_player and anim_attack != "":
		anim_player.play(anim_attack)
		var anim = anim_player.get_animation(anim_attack)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE  # Ataque normalmente no loop

func play_death():
	if anim_player and anim_death != "":
		SoundManager.play_sfx(preload("res://Assets/Sounds/SFX/unit/dead.mp3"))
		anim_player.play(anim_death)
		var anim = anim_player.get_animation(anim_death)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE  # Muerte no loop


class UnitAbility:
	var icon: String
	var name: String
	var description: String
	var ability_id: String
	var animation_scene: String
	var energy_cost: int
	
	func _init(p_icon: String, p_name: String, p_description: String, p_ability_id: String = "", p_animation_scene: String = "", p_energy_cost: int = 0):
		icon = p_icon
		name = p_name
		description = p_description
		ability_id = p_ability_id
		animation_scene = p_animation_scene
		energy_cost = p_energy_cost

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
	is_patrolling = false

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
	emit_signal("health_changed", current_health, max_health)

	print("💥 %s recibió %.1f de daño (vida: %.1f/%.1f)" % [name, actual_damage, current_health, max_health])
	_apply_slow_on_hit(0.5, 0.2)
	# 💀 Verificar si murió
	if current_health <= 0:
		current_health = 0
		_trigger_death()
func _apply_slow_on_hit(duration: float, factor: float) -> void:
	if is_slowed:
		return  # No acumular efectos repetidos
	
	is_slowed = true
	original_move_speed = move_speed
	move_speed *= factor      # ej: 0.5 = 50% de velocidad
	slow_timer = duration
	
	print("🐢 %s ralentizado a %.2f por %.1f s" % [name, move_speed, duration])

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
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			is_slowed = false
			move_speed = original_move_speed
			print("⚡ %s velocidad restaurada" % name)
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
		
	if is_patrolling:
		_handle_patrol_behavior(delta)
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
	SoundManager.play_sfx(attack_sfx)

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
	_init_aura()
	_init_stats()
		# 🔥 Cargar habilidades automáticamente desde UnitStats
	if UnitStats != null:
		var base_stats = UnitStats.get_stats(unit_type)
		if base_stats.has("abilities"):
			_set_abilities(base_stats.abilities)
			print("✅ Habilidades cargadas automáticamente para %s: %s" % [name, base_stats.abilities])
		else:
			print("⚠️ No hay habilidades definidas en UnitStats para %s" % name)
	else:
		push_error("❌ UnitStats no está cargado! No se pudieron inicializar habilidades.")
	
	if portrait_path != "":
		var tex := load(portrait_path)
		if tex:
			portrait = tex
		else:
			print("❌ ERROR: No se pudo cargar el retrato:", portrait_path)
		
	setup_collision_layers()
	play_idle()
	print("🟢 [Unit._ready()] FIN - abilities.size() en %s: %d" % [name, abilities.size()])


func setup_collision_layers() -> void:
	# Por defecto, capa 2 (Player 1)
	# Esto se sobrescribirá cuando se asigne el player_owner
	collision_layer = 1 << 2
	collision_mask = (1 << 2) | (1 << 0)  # Mismo jugador + terreno
	
	# Configuración específica por tipo de unidad
	if unit_category == "ground":
		collision_mask |= 1 << 0  # Terreno
	elif unit_category == "aquatic":
		collision_mask |= 1 << 1  # Agua

# 🔥 NUEVA FUNCIÓN: Configurar capas según el jugador
func setup_player_collision_layers(player_idx: int) -> void:
	# Bits:
	# 0 = Terreno
	# 1 = Agua
	# 2 = Player 0
	# 3 = Player 1
	# 4 = Player 2
	# 5 = Player 3
	# 6 = Player 4
	# 7 = Player 5
	
	var player_layer = 2 + player_idx  # 2-7
	
	# Esta unidad está en la capa de su jugador
	collision_layer = 1 << player_layer
	
	# Puede colisionar con:
	# - Unidades/edificios de su mismo jugador
	# - Terreno (bit 0)
	collision_mask = (1 << player_layer) | (1 << 0)
	
	# Agregar agua si es unidad acuática
	if unit_category == "aquatic":
		collision_mask |= 1 << 1
	
	print("✅ [%s] Capas configuradas - Layer: %d, Mask: %d (Jugador %d)" % [name, player_layer, collision_mask, player_idx])

# ===================================================
# 🔥 SISTEMA GENÉRICO DE HABILIDADES
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	# 🔥 Validación de energía
	if not _can_use_ability(ability):
		return
	
	# 🔥 Consumir energía y notificar
	_consume_ability_energy(ability)
	
	# 🔥 Llamar implementación específica (override en subclases)
	_execute_ability(ability)

# ===================================================
# 🔥 VALIDACIÓN Y CONSUMO (Genérico)
# ===================================================
func _can_use_ability(ability: UnitAbility) -> bool:
	if ability == null:
		push_error("❌ Habilidad es null")
		return false
	
	if current_magic < ability.energy_cost:
		print("⚠️ No hay suficiente energía para %s (necesita %d, tienes %. 1f)" % 
			[ability.name, ability.energy_cost, current_magic])
		if player_owner and player_owner.has_method("_show_energy_not"):
			player_owner._show_energy_not()
		return false
	
	return true

func _consume_ability_energy(ability: UnitAbility) -> void:
	current_magic -= ability.energy_cost
	emit_signal("energy_changed", current_magic, max_magic)
	print("⚡ %s usado - Energía restante: %.1f" % [ability.name, current_magic])

# ===================================================
# 🔥 EJECUCIÓN (Override en subclases)
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	# Implementación por defecto (vacía)
	# Las subclases deben hacer override
	push_warning("⚠️ _execute_ability no implementado en %s" % get_class())
	
func _apply_stats(stats: Dictionary) -> void:
	max_health = stats.get("max_health", 100)
	current_health = stats.get("current_health", max_health)
	attack_damage = stats.get("attack_damage", 10)
	defense = stats.get("defense", 5)
	move_speed = stats.get("move_speed", 10)
	attack_range = stats.get("attack_range", 20)
	max_magic = stats.get("max_magic", 50)
	current_magic = max_magic

func _init_stats():
	if UnitStats == null:
		push_error("UnitStats no cargado!")
		return
	
	var base_stats = UnitStats.get_stats(unit_type)
	_apply_stats(base_stats)

func _init_aura() -> void:
	if aura_controller == null:
		aura_controller = get_node_or_null("Aura")

	if aura_controller and player_owner:
		if "player_index" in player_owner:
			aura_controller.set_aura_color_from_player(player_owner.player_index)
			print("✅ Aura configurada para jugador %d en %s" %
				[player_owner.player_index, name])
		else:
			print("⚠️ player_owner no tiene player_index en %s" % name)
	else:
		if not aura_controller:
			print("⚠️ No se encontró nodo Aura en %s" % name)
		if not player_owner:
			print("⚠️ player_owner es null en %s" % name)

func set_player_owner(new_owner):
	player_owner = new_owner

	if aura_controller and "player_index" in player_owner:
		aura_controller.set_aura_color_from_player(player_owner.player_index)
		print("🔄 Aura actualizada para nuevo jugador")


func _set_abilities(ability_ids: Array) -> void:
	abilities.clear()  # Limpiar habilidades existentes
	
	for ability_id in ability_ids:
		var data = UnitAbilities.get_ability(ability_id)
		if data.size() == 0:
			continue  # O saltar si no se encuentra la habilidad
			
		var ua = UnitAbility.new(
			data.icon,
			data.name,
			data.description,
			ability_id,
			data.animation_scene,
			data.energy_cost
		)

		abilities.append(ua)
	
# ------------------------------------------
# 🔄 Iniciar patrulla entre posición actual y objetivo
# ------------------------------------------
func start_patrol(target: Vector3) -> void:
	if not is_alive:
		return
	
	# Cancelar ataque
	attack_target_entity = null
	is_attacking = false
	
	# Configurar patrulla
	patrol_start_point = global_position
	patrol_end_point = target
	patrol_target_index = 0  # Empezar yendo al punto objetivo
	is_patrolling = true
	has_move_target = true
	move_target = patrol_end_point
	
	print("🔄 %s iniciando patrulla entre %v y %v" % [name, patrol_start_point, patrol_end_point])

# ------------------------------------------
# 🛑 Detener completamente la unidad
# ------------------------------------------
func stop() -> void:
	if not is_alive:
		return
	
	# Cancelar todo
	attack_target_entity = null
	is_attacking = false
	is_patrolling = false
	has_move_target = false
	is_moving = false
	velocity = Vector3.ZERO
	
	play_idle()
	print("🛑 %s detenido" % name)
# ------------------------------------------
# 🔄 Comportamiento de patrulla
# ------------------------------------------
func _handle_patrol_behavior(delta: float) -> void:
	var direction = move_target - global_position
	direction.y = 0
	var distance = direction.length()
	
	# Si llegamos al punto objetivo
	if distance <= arrival_radius:
		# Cambiar al siguiente punto
		patrol_target_index = 1 - patrol_target_index  # Alternar entre 0 y 1
		
		if patrol_target_index == 0:
			move_target = patrol_end_point
			print("🔄 %s llegó al punto inicial, volviendo al objetivo" % name)
		else:
			move_target = patrol_start_point
			print("🔄 %s llegó al objetivo, volviendo al punto inicial" % name)
		
		return
	
	# Moverse hacia el punto objetivo actual
	var target_rot = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation. y, target_rot, rotation_speed * delta)
	
	if not is_moving:
		is_moving = true
		play_move()
	
	velocity = direction.normalized() * move_speed
	move_and_slide()
func deselect() -> void:
	if selection_circle:
		selection_circle.visible = false
