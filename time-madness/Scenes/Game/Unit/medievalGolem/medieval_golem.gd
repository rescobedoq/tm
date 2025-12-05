extends Unit
class_name MedievalGolem

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
	portrait_path = "res://Assets/Images/Portraits/Units/medievalGolem.png"
	unit_category = "ground"
	anim_idle = "Idle"
	anim_move = "Walking_frame_rate_24_fbx"
	anim_attack = "Right_Hand_Sword_Slash_frame_rate_24_fbx"
	anim_death = "Shot_and_Fall_Backward_frame_rate_24_fbx"
	unit_type = "Medieval Golem"
	
	super._ready()
	
	original_move_speed = move_speed
	_set_abilities(["punch_ability", "spawn_ability"])

# 🔥 Animaciones
func play_punch():
	if anim_player:
		anim_player.play("Shield_Push_Left_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Shield_Push_Left_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

func play_teleport_scream():
	if anim_player:
		anim_player.play("Zombie_Scream_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Zombie_Scream_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	match ability.ability_id:
		"punch_ability":
			_start_punch_ability()
		"spawn_ability":
			_start_spawn_ability()
		_:
			super._execute_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: PUNCH (Golpe aturdidor)
# ===================================================
func _start_punch_ability() -> void:
	print("👊 Iniciando habilidad PUNCH - Selecciona un objetivo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "punch_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	match ability_id:
		"punch_ability":
			if target is Entity:
				_execute_punch(target)
		"spawn_ability":
			if target is Vector3:
				_execute_spawn(target)

func _execute_punch(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Punch")
		return
	
	print("👊 PUNCH ACTIVADO! Objetivo: %s" % target.name)
	
	is_punching = true
	attack_target_entity = target
	is_attacking = true
	has_move_target = false
	attack_timer = 0.0

func _handle_attack_behavior(delta: float) -> void:
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		if is_punching:
			is_punching = false
		_cancel_attack()
		return
	
	var direction = attack_target_entity.global_position - global_position
	direction.y = 0
	var distance = direction.length()
	
	# MOVERSE
	if distance > attack_range:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if not is_moving:
			is_moving = true
			play_move()
		
		velocity = direction.normalized() * move_speed
		move_and_slide()
	
	# ATACAR
	else:
		velocity = Vector3.ZERO
		
		if is_moving:
			is_moving = false
			play_idle()
		
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if is_punching:
			_perform_punch_impact()
		else:
			attack_timer -= delta
			if attack_timer <= 0:
				_perform_attack()
				attack_timer = attack_cooldown

func _perform_punch_impact() -> void:
	if attack_target_entity == null or not attack_target_entity.is_alive:
		is_punching = false
		_cancel_attack()
		return
	
	print("👊💥 PUNCH IMPACT!")
	
	play_punch()
	_spawn_punch_effect(attack_target_entity.global_position)
	
	if attack_target_entity.has_method("apply_stun"):
		attack_target_entity.apply_stun(punch_stun_duration)
	elif attack_target_entity.has_method("take_damage"):
		attack_target_entity.take_damage(attack_damage)
	
	move_speed = 0.0
	is_punching = false
	_cancel_attack()
	
	print("🧊 Golem congelado por %.1f segundos" % punch_stun_duration)
	
	await get_tree().create_timer(punch_stun_duration).timeout
	move_speed = original_move_speed
	print("✅ Golem puede moverse de nuevo")

func _spawn_punch_effect(world_position: Vector3) -> void:
	var ability_data = UnitAbilities.get_ability("punch_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró punch_ability en singleton")
		return
	
	var punch_scene = load(ability_data.animation_scene)
	if punch_scene == null:
		print("❌ No se pudo cargar la escena de punch")
		return
	
	var punch_instance = punch_scene.instantiate()
	get_tree().current_scene.add_child(punch_instance)
	punch_instance.global_position = world_position
	
	print("💥 Efecto de punch spawneado en: %v" % world_position)
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(punch_instance):
		punch_instance.queue_free()

# ===================================================
# 🔥 HABILIDAD 2: SPAWN (Teletransporte)
# ===================================================
func _start_spawn_ability() -> void:
	print("🌀 Iniciando habilidad SPAWN - Selecciona una ubicación")
	
	if player_owner and player_owner.has_method("_start_ability_terrain_selection"):
		player_owner._start_ability_terrain_selection(self, "spawn_ability", teleport_max_range)
	else:
		print("⚠️ PlayerController no tiene _start_ability_terrain_selection()")

func _execute_spawn(target_position: Vector3) -> void:
	if is_teleporting:
		print("⚠️ Ya está teletransportándose")
		return
	
	var distance = global_position.distance_to(target_position)
	if distance > teleport_max_range:
		print("❌ Posición demasiado lejos (%.1f / %.1f)" % [distance, teleport_max_range])
		return
	
	print("🌀 SPAWN ACTIVADO! Teletransportando a: %v" % target_position)
	
	_cancel_attack()
	has_move_target = false
	is_moving = false
	is_teleporting = true
	
	_perform_teleport(target_position)

func _perform_teleport(target_pos: Vector3) -> void:
	play_teleport_scream()
	print("😱 Reproduciendo grito de teletransporte...")
	
	await get_tree().create_timer(0.5).timeout
	
	var start_pos = global_position
	var start_y = start_pos.y
	
	print("⬇️ Bajando al Golem...")
	var descend_tween = create_tween()
	descend_tween.tween_property(self, "global_position:y", start_y - teleport_height_offset, teleport_duration * 0.4)
	await descend_tween.finished
	
	var new_pos = target_pos
	new_pos.y = target_pos.y - teleport_height_offset
	global_position = new_pos
	print("📍 Golem movido a nueva posición")
	
	print("⬆️ Subiendo al Golem...")
	var ascend_tween = create_tween()
	ascend_tween.tween_property(self, "global_position:y", target_pos.y, teleport_duration * 0.6)
	await ascend_tween.finished
	
	is_teleporting = false
	play_idle()
	print("✅ Teletransporte completado!")

func _physics_process(delta: float) -> void:
	if is_teleporting:
		return
	
	super._physics_process(delta)

func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	
	if is_moving:
		is_moving = false
		play_idle()
