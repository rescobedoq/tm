extends Unit
class_name MedievalSoldier

var selection_tween: Tween

# 🔥 Variables de Charge
var is_charging: bool = false
var charge_speed_multiplier: float = 3.0
var charge_damage_bonus: float = 50.0

func _ready():
	unit_category = "ground"
	portrait_path = "res://Assets/Images/Portraits/Units/medievalSoldier.png"
	anim_idle = "Idle_3_frame_rate_24_fbx"
	anim_move = "Walking_frame_rate_24_fbx"
	anim_attack = "Attack_frame_rate_24_fbx"
	anim_death = "Dead_frame_rate_24_fbx"
	unit_type = "Medieval Soldier"
	
	super._ready()
	
	_set_abilities(["charge_ability"])

# ---------------------------------------------------
# ANIMACIONES DEL SOLDADO
# ---------------------------------------------------
func play_charge():
	if anim_player:
		anim_player.play("Running_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Running_frame_rate_24_fbx")
		if anim:
			anim. loop_mode = Animation.LOOP_LINEAR

# ---------------------------------------------------
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ---------------------------------------------------
func _execute_ability(ability: UnitAbility) -> void:
	if ability.ability_id == "charge_ability":
		_start_charge_ability()
	else:
		super._execute_ability(ability)

# ---------------------------------------------------
# 🔥 HABILIDAD: CHARGE
# ---------------------------------------------------
func _start_charge_ability() -> void:
	print("⚡ Iniciando habilidad CHARGE - Selecciona un objetivo")
	
	if player_owner and player_owner. has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "charge_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target: Entity) -> void:
	if ability_id == "charge_ability":
		_execute_charge(target)

func _execute_charge(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Charge")
		return
	
	print("⚡ CHARGE ACTIVADO!  Objetivo: %s" % target.name)
	
	is_charging = true
	attack_target_entity = target
	is_attacking = true
	has_move_target = false
	attack_timer = 0.0

# ---------------------------------------------------
# 💥 SPAWEAR EFECTO DE IMPACTO
# ---------------------------------------------------
func _spawn_charge_impact_effect(world_position_3d: Vector3) -> void:
	var ability_data = UnitAbilities.get_ability("charge_ability")
	if ability_data. size() == 0:
		print("❌ No se encontró charge_ability en singleton")
		return
	
	var impact_scene = load(ability_data. animation_scene)
	if impact_scene == null:
		print("❌ No se pudo cargar Charge impact scene")
		return
	
	var impact_instance = impact_scene.instantiate()
	get_tree().current_scene.add_child(impact_instance)
	impact_instance.global_position = world_position_3d
	
	var animated_sprite = impact_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	await get_tree(). create_timer(1.0). timeout
	if is_instance_valid(impact_instance):
		impact_instance. queue_free()

# ---------------------------------------------------
# 🔥 OVERRIDE: COMPORTAMIENTO DE ATAQUE
# ---------------------------------------------------
func _handle_attack_behavior(delta: float) -> void:
	if not is_instance_valid(attack_target_entity) or not attack_target_entity.is_alive:
		if is_charging:
			is_charging = false
		_cancel_attack()
		return
	
	var direction = attack_target_entity.global_position - global_position
	direction.y = 0
	var distance = direction.length()
	
	var current_speed = move_speed
	if is_charging:
		current_speed = move_speed * charge_speed_multiplier
	
	# MOVERSE
	if distance > attack_range:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		if not is_moving:
			is_moving = true
			if is_charging:
				play_charge()
			else:
				play_move()
		
		velocity = direction.normalized() * current_speed
		move_and_slide()
	
	# ATACAR
	else:
		velocity = Vector3.ZERO
		
		if is_moving:
			is_moving = false
			play_idle()
		
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)
		
		attack_timer -= delta
		if attack_timer <= 0:
			_perform_attack()
			attack_timer = attack_cooldown

# ---------------------------------------------------
# 🔥 OVERRIDE: ATAQUE CON BONUS DE CHARGE
# ---------------------------------------------------
func _perform_attack() -> void:
	if attack_target_entity == null or not attack_target_entity.is_alive:
		if is_charging:
			is_charging = false
		_cancel_attack()
		return
	
	var damage = attack_damage
	
	if is_charging:
		damage += charge_damage_bonus

		_spawn_charge_impact_effect(attack_target_entity.global_position)
		is_charging = false
	else:
		print("⚔️ %s atacando a %s (daño: %.1f)" % [name, attack_target_entity.name, damage])
	
	play_attack()
	
	if attack_target_entity.has_method("take_damage"):
		attack_target_entity.take_damage(damage)

# ---------------------------------------------------
# 🔥 OVERRIDE: CANCELAR ATAQUE
# ---------------------------------------------------
func _cancel_attack() -> void:
	attack_target_entity = null
	is_attacking = false
	attack_timer = 0.0
	
	if is_moving:
		is_moving = false
		play_idle()
