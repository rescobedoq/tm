extends Unit
class_name MedievalGolem

@onready var anim_player = $medievalGolem/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection
@onready var aura_controller = $Aura  # 🔥 Referencia directa al nodo Aura

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalGolem.png"
const PUNCH_EFFECT_SCENE := "res://Scenes/Utils/Punch/Punch.tscn"

var selection_tween: Tween

# 🔥 Variables de PUNCH
var is_punching: bool = false
var punch_stun_duration: float = 2.0
var original_move_speed: float = 0.0

# 🔥 Variables de SPAWN (Teleport)
var is_teleporting: bool = false
var teleport_max_range: float = 50.0
var teleport_height_offset: float = 20.0
var teleport_duration: float = 1.5

func _ready():
	unit_category = "ground"
	
	# 🔥 CONFIGURAR AURA ANTES DE LLAMAR A super._ready()
	if aura_controller == null:
		aura_controller = get_node_or_null("Aura")
	
	# 🔥 Configurar el aura con el color del jugador
	if aura_controller and player_owner:
		if "player_index" in player_owner:
			aura_controller. set_aura_color_from_player(player_owner.player_index)
			print("✅ Aura configurada para jugador %d en %s" % [player_owner. player_index, name])
		else:
			print("⚠️ player_owner no tiene player_index en %s" % name)
	else:
		if not aura_controller:
			print("⚠️ No se encontró nodo Aura en %s" % name)
		if not player_owner:
			print("⚠️ player_owner es null en %s" % name)
	
	super._ready()
	unit_type = "Medieval Golem"
	max_health = 200
	current_health = max_health
	max_magic = 100  # 🔥 Suficiente para las habilidades
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 15.0
	
	original_move_speed = move_speed  # Guardar velocidad original

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)
	
	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/punchIcon.jpg",
			"Punch",
			"Stun enemy unit for 2 seconds.\nCosto: 1 energia",
			"punch_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/golemIcom.jpg",
			"Spawn",
			"Teleport to target location.\nCosto: 1 energia",
			"spawn_ability" 
		),
	]

func play_idle():
	if anim_player:
		print(">>> play_idle CALLED <<<")
		if anim_player.is_playing():
			anim_player.stop()

func play_move():
	if anim_player:
		print(">>> play_move CALLED <<<")
		anim_player.play("Walking_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Walking_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.play("Right_Hand_Sword_Slash_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Right_Hand_Sword_Slash_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_LINEAR

func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("Shot_and_Fall_Backward_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Shot_and_Fall_Backward_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

# 🔥 Animación de PUNCH
func play_punch():
	if anim_player:
		print(">>> play_punch CALLED <<<")
		anim_player.play("Shield_Push_Left_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Shield_Push_Left_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# 🔥 Animación de TELEPORT
func play_teleport_scream():
	if anim_player:
		print(">>> play_teleport_scream CALLED <<<")
		anim_player.play("Zombie_Scream_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Zombie_Scream_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# ---------------------------------------------------
# 🔥 SISTEMA DE HABILIDADES
# ---------------------------------------------------
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "punch_ability":
		_start_punch_ability()
	elif ability.ability_id == "spawn_ability":
		_start_spawn_ability()
	else:
		super.use_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: PUNCH (Golpe aturdidor)
# ===================================================
func _start_punch_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Punch (necesita 1, tienes %. 1f)" % current_magic)
		return
	
	print("👊 Iniciando habilidad PUNCH - Selecciona un objetivo")
	
	# Activar selección de objetivo
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "punch_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "punch_ability" and target is Entity:
		_execute_punch(target)
	elif ability_id == "spawn_ability" and target is Vector3:
		_execute_spawn(target)

func _execute_punch(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Punch")
		return
	
	# Consumir energía
	current_magic -= 1
	print("👊 PUNCH ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Activar estado de punch
	is_punching = true
	
	# Establecer objetivo
	attack_target_entity = target
	is_attacking = true
	has_move_target = false
	attack_timer = 0.0
	
	print("👊 Acercándose al objetivo para golpear...")

# 🔥 Override del comportamiento de ataque para PUNCH
func _handle_attack_behavior(delta: float) -> void:
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		print("🛑 Objetivo perdido o muerto")
		if is_punching:
			is_punching = false
		_cancel_attack()
		return
	
	var direction = attack_target_entity.global_position - global_position
	direction. y = 0
	var distance = direction.length()
	
	# 🔥 SI ESTÁ FUERA DE RANGO: ACERCARSE (velocidad normal)
	if distance > attack_range:
		var target_rot = atan2(direction.x, direction.z)
		rotation. y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if not is_moving:
			is_moving = true
			play_move()
		
		velocity = direction.normalized() * move_speed
		move_and_slide()
		
		if is_punching:
			print("👊 Acercándose para Punch (distancia: %.2f)" % distance)
	
	# 🔥 SI ESTÁ EN RANGO: EJECUTAR PUNCH
	else:
		velocity = Vector3. ZERO
		
		if is_moving:
			is_moving = false
			play_idle()
		
		# Rotar hacia el objetivo
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		# 🔥 Si está en modo punch, ejecutar el golpe
		if is_punching:
			_perform_punch_impact()
		else:
			# Ataque normal
			attack_timer -= delta
			if attack_timer <= 0:
				_perform_attack()
				attack_timer = attack_cooldown

# 🔥 Ejecutar el impacto del PUNCH
func _perform_punch_impact() -> void:
	if attack_target_entity == null or not attack_target_entity.is_alive:
		is_punching = false
		_cancel_attack()
		return
	
	print("👊💥 PUNCH IMPACT!")
	
	# Reproducir animación de golpe
	play_punch()
	
	# 🔥 Spawear efecto visual en la posición del objetivo
	_spawn_punch_effect(attack_target_entity. global_position)
	
	# 🔥 Aturdir al objetivo (congelar movimiento por 2 segundos)
	if attack_target_entity.has_method("apply_stun"):
		attack_target_entity.apply_stun(punch_stun_duration)
	else:
		# Si no tiene método de stun, al menos hacerle daño
		if attack_target_entity.has_method("take_damage"):
			attack_target_entity.take_damage(attack_damage)
	
	# 🔥 Congelar al Golem durante el stun
	move_speed = 0.0
	is_punching = false
	_cancel_attack()
	
	print("🧊 Golem congelado por %. 1f segundos" % punch_stun_duration)
	
	# Esperar 2 segundos y restaurar velocidad
	await get_tree().create_timer(punch_stun_duration). timeout
	move_speed = original_move_speed
	print("✅ Golem puede moverse de nuevo")

# 💥 Spawear efecto de PUNCH
func _spawn_punch_effect(world_position: Vector3) -> void:
	var punch_scene = load(PUNCH_EFFECT_SCENE)
	if punch_scene == null:
		print("❌ No se pudo cargar la escena de punch: %s" % PUNCH_EFFECT_SCENE)
		return
	
	var punch_instance = punch_scene.instantiate()
	get_tree().current_scene.add_child(punch_instance)
	punch_instance.global_position = world_position
	
	print("💥 Efecto de punch spawneado en: %v" % world_position)
	
	# Auto-destruir después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(punch_instance):
		punch_instance.queue_free()
		print("🗑️ Efecto de punch eliminado")

# ===================================================
# 🔥 HABILIDAD 2: SPAWN (Teletransporte)
# ===================================================
func _start_spawn_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Spawn (necesita 1, tienes %.1f)" % current_magic)
		return
	
	print("🌀 Iniciando habilidad SPAWN - Selecciona una ubicación")
	
	# 🔥 Activar selección de TERRENO en el PlayerController
	if player_owner and player_owner.has_method("_start_ability_terrain_selection"):
		player_owner._start_ability_terrain_selection(self, "spawn_ability", teleport_max_range)
	else:
		print("⚠️ PlayerController no tiene _start_ability_terrain_selection()")

func _execute_spawn(target_position: Vector3) -> void:
	if is_teleporting:
		print("⚠️ Ya está teletransportándose")
		return
	
	# Verificar rango
	var distance = global_position.distance_to(target_position)
	if distance > teleport_max_range:
		print("❌ Posición demasiado lejos (%.1f / %.1f)" % [distance, teleport_max_range])
		return
	
	# Consumir energía
	current_magic -= 1
	print("🌀 SPAWN ACTIVADO! Teletransportando a: %v" % target_position)
	print("💙 Energía restante: %.1f" % current_magic)
	
	# Cancelar cualquier acción
	_cancel_attack()
	has_move_target = false
	is_moving = false
	is_teleporting = true
	
	# Ejecutar teletransporte
	_perform_teleport(target_position)

func _perform_teleport(target_pos: Vector3) -> void:
	# 1. Reproducir animación de grito
	play_teleport_scream()
	print("😱 Reproduciendo grito de teletransporte...")
	
	# Esperar un momento para que se vea la animación
	await get_tree().create_timer(0.5).timeout
	
	# 2. Guardar posición inicial
	var start_pos = global_position
	var start_y = start_pos.y
	
	# 3. Bajar gradualmente (desaparecer)
	print("⬇️ Bajando al Golem...")
	var descend_tween = create_tween()
	descend_tween.tween_property(self, "global_position:y", start_y - teleport_height_offset, teleport_duration * 0.4)
	await descend_tween.finished
	
	# 4.  Mover instantáneamente a la nueva posición (abajo)
	var new_pos = target_pos
	new_pos.y = target_pos.y - teleport_height_offset
	global_position = new_pos
	print("📍 Golem movido a nueva posición (bajo tierra)")
	
	# 5. Subir gradualmente (aparecer)
	print("⬆️ Subiendo al Golem...")
	var ascend_tween = create_tween()
	ascend_tween.tween_property(self, "global_position:y", target_pos.y, teleport_duration * 0.6)
	await ascend_tween.finished
	
	# 6. Finalizar teletransporte
	is_teleporting = false
	play_idle()
	print("✅ Teletransporte completado!")

# 🔥 Override de _physics_process para prevenir movimiento durante teleport
func _physics_process(delta: float) -> void:
	# Si está teletransportándose, no procesar movimiento
	if is_teleporting:
		return
	
	# Llamar al método padre
	super._physics_process(delta)

# 🔥 Override de cancelar ataque
func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	
	if is_moving:
		is_moving = false
		play_idle()
