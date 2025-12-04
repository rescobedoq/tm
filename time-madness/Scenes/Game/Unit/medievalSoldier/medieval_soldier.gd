extends Unit
class_name MedievalSoldier


const CHARGE_IMPACT_SCENE := "res://Scenes/Utils/Charge/Charge.tscn"

var selection_tween: Tween

# 🔥 Variables de Charge
var is_charging: bool = false
var charge_speed_multiplier: float = 3.0
var charge_damage_bonus: float = 50.0

func _ready():
	unit_category = "ground"
	portrait_path = "res://Assets/Images/Portraits/Units/medievalSoldier.png"
	anim_idle   = "Idle_3_frame_rate_24_fbx"
	anim_move   = "Walking_frame_rate_24_fbx"
	anim_attack = "Attack_frame_rate_24_fbx"
	anim_death  = "Dead_frame_rate_24_fbx"

	unit_type = "Medieval Soldier"
	super._ready()
	
	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/chageIcon.png",
			"Charge",
			"Charge against an objetive.\nCosto: 50 energia",
			"charge_ability" 
		),
	]

# ---------------------------------------------------
#   ANIMACIONES DEL SOLDADO
# ---------------------------------------------------

# 🔥 Animación de carga (Running)
func play_charge():
	if anim_player:
		print(">>> play_charge CALLED (Running) <<<")
		anim_player.play("Running_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Running_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

# ---------------------------------------------------
# 🔥 HABILIDAD: CHARGE
# ---------------------------------------------------
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "charge_ability":
		_start_charge_ability()
	else:
		super.use_ability(ability)

func _start_charge_ability() -> void:
	# Verificar energía
	if current_magic < 50:
		print("⚠️ No hay suficiente energía para Charge (necesita 50, tienes %. 1f)" % current_magic)
		return
	
	print("⚡ Iniciando habilidad CHARGE - Selecciona un objetivo")
	
	# 🔥 Activar modo de selección de objetivo en el PlayerController
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "charge_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

# 🔥 Callback cuando se selecciona el objetivo
func on_ability_target_selected(ability_id: String, target: Entity) -> void:
	if ability_id == "charge_ability":
		_execute_charge(target)

func _execute_charge(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Charge")
		return
	
	# Consumir energía
	current_magic -= 50
	print("⚡ CHARGE ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %.1f" % current_magic)
	
	# 🔥 PRIMERO activar el estado de carga
	is_charging = true
	
	# 🔥 LUEGO establecer el objetivo de ataque
	attack_target_entity = target
	is_attacking = true
	has_move_target = false
	
	# Resetear timer para atacar inmediatamente al llegar
	attack_timer = 0.0
	
	print("⚡ Estado de carga activado correctamente")

# ---------------------------------------------------
# 💥 SPAWEAR EFECTO DE IMPACTO (Node2D con Sprite3D)
# ---------------------------------------------------
func _spawn_charge_impact_effect(world_position_3d: Vector3) -> void:
	var impact_instance = load(CHARGE_IMPACT_SCENE).instantiate()
	get_tree().current_scene.add_child(impact_instance)
	impact_instance.global_position = world_position_3d
	
	var animated_sprite = impact_instance.get_node("AnimatedSprite3D")
	animated_sprite.play()
	
	await get_tree().create_timer(1.0).timeout
	impact_instance.queue_free()
	
# 🔥 Callback cuando termina la animación
func _on_impact_animation_finished(container: Node3D) -> void:
	if is_instance_valid(container):
		container.queue_free()
		print("🗑️ Efecto de impacto eliminado (animación terminada)")

# 🔥 Override del comportamiento de ataque para Charge
func _handle_attack_behavior(delta: float) -> void:
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		print("🛑 Objetivo perdido o muerto")
		if is_charging:
			print("🛑 Cancelando carga")
			is_charging = false
		_cancel_attack()
		return
	
	var direction = attack_target_entity.global_position - global_position
	direction.y = 0
	var distance = direction.length()
	
	# 🔥 Determinar velocidad según si está cargando
	var current_speed = move_speed
	if is_charging:
		current_speed = move_speed * charge_speed_multiplier
	
	# SI ESTÁ FUERA DE RANGO: PERSEGUIR
	if distance > attack_range:
		var target_rot = atan2(direction.x, direction.z)
		rotation. y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if not is_moving:
			is_moving = true
			# 🔥 Usar animación de carga si está cargando
			if is_charging:
				play_charge()
				print("⚡ Iniciando animación de carga")
			else:
				play_move()
		
		velocity = direction.normalized() * current_speed
		move_and_slide()
		
		if is_charging:
			print("⚡ CARGANDO hacia %s (distancia: %.2f / velocidad: %.1f)" % [attack_target_entity.name, distance, current_speed])
	
	# SI ESTÁ EN RANGO: ATACAR
	else:
		velocity = Vector3.ZERO
		
		if is_moving:
			is_moving = false
			play_idle()
		
		# Rotar hacia el objetivo
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		# Cooldown de ataque
		attack_timer -= delta
		if attack_timer <= 0:
			_perform_attack()
			attack_timer = attack_cooldown

# 🔥 Override del ataque para aplicar daño bonus de Charge
func _perform_attack() -> void:
	if attack_target_entity == null or not attack_target_entity.is_alive:
		if is_charging:
			is_charging = false
		_cancel_attack()
		return
	
	var damage = attack_damage
	
	# 🔥 Si está cargando, aplicar daño bonus y efecto visual
	if is_charging:
		damage += charge_damage_bonus
		print("⚡💥 CHARGE IMPACT!  Daño total: %.1f (base: %.1f + bonus: %.1f)" % [damage, attack_damage, charge_damage_bonus])
		
		# 💥 Spawear efecto de impacto en la posición del objetivo
		_spawn_charge_impact_effect(attack_target_entity. global_position)
		
		is_charging = false  # Terminar carga después del impacto
	else:
		print("⚔️ %s ATACANDO a %s (daño: %.1f)" % [name, attack_target_entity. name, damage])
	
	play_attack()
	
	# Aplicar daño al objetivo
	if attack_target_entity. has_method("take_damage"):
		attack_target_entity. take_damage(damage)
	else:
		print("⚠️ El objetivo no tiene método take_damage()")

# 🔥 Override de cancelar ataque (NO resetea charge aquí)
func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	
	if is_moving:
		is_moving = false
		play_idle()
