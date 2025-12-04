extends Unit
class_name MedievalCavalry


const IMPACT_SCENE := "res://Scenes/Utils/Charge/Charge.tscn"

# Tween para animación de thrust
var thrust_tween: Tween
var attack_tween: Tween
var death_tween: Tween


# Variables Thrust
var is_thrusting: bool = false
var thrust_speed_multiplier: float = 3.5
var thrust_damage_bonus: float = 70.0

func _ready():
	portrait_path = "res://Assets/Images/Portraits/Units/medievalCavalry.png"
	unit_category = "ground"
	unit_type = "Medieval Cavalry"

	# 🎯 Asignar animaciones normales al padre
	# (solo play_move depende de animación real)
	anim_idle = ""  # Idle lo manejas con tween -> se sobrescribe
	anim_move = "Armature|Armature|Armature|Armature|Unreal Take|baselayer"
	anim_attack = ""  # Attack usa tween -> se sobrescribe
	anim_death = ""   # Death usa tween -> se sobrescribe

	super._ready()

	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/cavalryAttackIcon.jpg",
			"Thrust",
			"Charge forward violently.\nCosto: 30 energia",
			"thrust_ability"
		),
	]

# ---------------------------------------------------------
# ANIMACIONES
# ---------------------------------------------------------

func play_idle():
	if anim_player:
		if anim_player.is_playing():
			anim_player.stop()
	_reset_rotation()


func play_thrust():
	# Animación simple: inclinar al caballo hacia adelante
	if thrust_tween:
		thrust_tween.kill()

	thrust_tween = create_tween()
	thrust_tween.tween_property(self, "rotation_degrees:x", -25, 0.20)
func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.stop()

	# Tween de ataque simple (golpe hacia adelante y volver)
	if attack_tween:
		attack_tween.kill()

	attack_tween = create_tween()
	attack_tween.tween_property(self, "rotation_degrees:x", -18, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(self, "rotation_degrees:x", 0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.stop()

	if death_tween:
		death_tween.kill()

	death_tween = create_tween()

	# Caída hacia un lado con rotación y descenso
	death_tween.tween_property(self, "rotation_degrees:z", 75, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	death_tween.tween_property(self, "global_position:y", global_position.y - 1.2, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Al finalizar, dejarlo inmóvil
	death_tween.tween_callback(func():
		velocity = Vector3.ZERO
	)


func _reset_rotation():
	var t = create_tween()
	t.tween_property(self, "rotation_degrees:x", 0, 0.25)

# ---------------------------------------------------------
# HABILIDAD: THRUST
# ---------------------------------------------------------

func use_ability(ability: UnitAbility) -> void:
	if ability.ability_id == "thrust_ability":
		_start_thrust_ability()
	else:
		super.use_ability(ability)

func _start_thrust_ability() -> void:
	if current_magic < 30:
		print("⚠️ No hay energía para Thrust (30)")
		return

	print("⚡ Selecciona objetivo para THRUST")

	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "thrust_ability")
	else:
		print("❌ PlayerController no implementa selección")

func on_ability_target_selected(ability_id: String, target: Entity) -> void:
	if ability_id == "thrust_ability":
		_execute_thrust(target)

func _execute_thrust(target: Entity) -> void:
	if not target or not is_instance_valid(target):
		print("❌ Objetivo inválido para Thrust")
		return

	current_magic -= 30
	print("⚡ THRUST ACTIVADO contra", target.name)

	is_thrusting = true
	attack_target_entity = target
	is_attacking = true
	has_move_target = false
	attack_timer = 0.0

	play_thrust()

# ---------------------------------------------------------
# MOVIMIENTO Y ATAQUE OVERRIDE
# ---------------------------------------------------------

func _handle_attack_behavior(delta: float) -> void:
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		is_thrusting = false
		_cancel_attack()
		return

	var dir = attack_target_entity.global_position - global_position
	dir.y = 0
	var dist = dir.length()

	var speed = move_speed
	if is_thrusting:
		speed *= thrust_speed_multiplier

	# MOVERSE
	if dist > attack_range:
		var rot = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, rot, rotation_speed * delta)

		if not is_moving:
			is_moving = true

			if is_thrusting:
				play_thrust()
			else:
				play_move()

		velocity = dir.normalized() * speed
		move_and_slide()

	else:
		velocity = Vector3.ZERO
		
		if is_moving:
			is_moving = false
			play_idle()

		var rot = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, rot, rotation_speed * delta)

		attack_timer -= delta
		if attack_timer <= 0:
			_perform_attack()
			attack_timer = attack_cooldown

# ---------------------------------------------------------
# ATAQUE CON BONUS
# ---------------------------------------------------------

func _perform_attack() -> void:
	if not attack_target_entity or not attack_target_entity.is_alive:
		is_thrusting = false
		_cancel_attack()
		return

	var dmg = attack_damage

	if is_thrusting:
		dmg += thrust_damage_bonus
		print("⚡💥 THRUST IMPACT — daño:", dmg)

		_spawn_impact_effect(attack_target_entity.global_position)

		is_thrusting = false
		_reset_rotation()

	else:
		print("⚔️ Caballería atacando — daño:", dmg)

	# Aplicar daño real
	if attack_target_entity.has_method("take_damage"):
		attack_target_entity.take_damage(dmg)

# ---------------------------------------------------------
# EFECTO DE IMPACTO
# ---------------------------------------------------------

func _spawn_impact_effect(pos: Vector3):
	var scene = load(IMPACT_SCENE)
	if not scene:
		print("❌ No se pudo cargar IMPACT_SCENE")
		return

	var inst = scene.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = pos

	if inst.has_node("AnimatedSprite3D"):
		inst.get_node("AnimatedSprite3D").play()

	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(inst):
		inst.queue_free()

# ---------------------------------------------------------
# CANCELAR ATAQUE
# ---------------------------------------------------------

func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	is_thrusting = false

	if is_moving:
		is_moving = false
		play_idle()
	_reset_rotation()
