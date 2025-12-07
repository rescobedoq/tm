extends Unit
class_name MedievalDruid

var selection_tween: Tween

# 🔥 Variables de Root Unit
var root_damage: float = 30.0
var root_duration: float = 5.0
var root_slow_percent: float = 0.8  # Reduce velocidad al 20%

# 🔥 Variables de Steal Life
var steal_life_damage: float = 40.0
var steal_life_heal_percent: float = 1.0  # Cura el 100% del daño

func _ready():
	portrait_path = "res://Assets/Images/Portraits/Units/medievalDruid.png"
	unit_category = "ground"
	anim_idle = "Idle_7_frame_rate_24_fbx"
	anim_move = "Walking_Woman_frame_rate_24_fbx"
	anim_attack = "Charged_Spell_Cast_frame_rate_24_fbx"
	anim_death = "Fall_Dead_from_Abdominal_Injury_frame_rate_24_fbx"
	unit_type = "Medieval Druid"
	
	super._ready()
	
	_set_abilities(["rootUnit_ability", "stealLife_ability"])

# 🔥 Animación de habilidades
func play_spell_cast():
	if anim_player:
		anim_player.play("Charged_Ground_Slam_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Charged_Ground_Slam_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	match ability.ability_id:
		"rootUnit_ability":
			_start_root_unit_ability()
		"stealLife_ability":
			_start_steal_life_ability()
		_:
			super._execute_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: ROOT UNIT (Enraizar)
# ===================================================
func _start_root_unit_ability() -> void:
	print("🌿 Iniciando habilidad ROOT UNIT - Selecciona un enemigo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "rootUnit_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	match ability_id:
		"rootUnit_ability":
			if target is Entity:
				_execute_root_unit(target)
		"stealLife_ability":
			if target is Entity:
				_execute_steal_life(target)

func _execute_root_unit(target: Entity) -> void:
	if not _validate_enemy_target(target):
		return
	
	print("🌿 ROOT UNIT ACTIVADO! Objetivo: %s" % target.name)
	
	play_spell_cast()
	await get_tree().create_timer(0.3).timeout
	
	# Aplicar daño
	if target.has_method("take_damage"):
		target.take_damage(root_damage)
		print("🌿 Daño aplicado: %.1f" % root_damage)
	
	# Spawear efecto y aplicar slow
	_spawn_root_effect(target.global_position)
	_apply_root_slow(target)

func _spawn_root_effect(world_position: Vector3) -> void:
	var ability_data = UnitAbilities.get_ability("rootUnit_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró rootUnit_ability en singleton")
		return
	
	var effect_scene = load(ability_data.animation_scene)
	if effect_scene == null:
		print("❌ No se pudo cargar Root effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	
	print("🌿 Efecto de Root spawneado en: %v" % world_position)
	
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	await get_tree().create_timer(root_duration).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()

func _apply_root_slow(target: Entity) -> void:
	if not is_instance_valid(target) or not target is Unit:
		return
	
	var target_unit = target as Unit
	var original_speed = target_unit.move_speed
	var reduced_speed = original_speed * (1.0 - root_slow_percent)
	target_unit.move_speed = reduced_speed
	
	print("🌿 Velocidad reducida: %.1f -> %.1f" % [original_speed, reduced_speed])
	
	await get_tree().create_timer(root_duration).timeout
	
	if is_instance_valid(target_unit):
		target_unit.move_speed = original_speed
		print("🌿 Velocidad restaurada: %.1f" % original_speed)

# ===================================================
# 🔥 HABILIDAD 2: STEAL LIFE (Robar vida)
# ===================================================
func _start_steal_life_ability() -> void:
	print("💀 Iniciando habilidad STEAL LIFE - Selecciona un enemigo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "stealLife_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func _execute_steal_life(target: Entity) -> void:
	if not _validate_enemy_target(target):
		return
	
	print("💀 STEAL LIFE ACTIVADO! Objetivo: %s" % target.name)
	
	play_spell_cast()
	await get_tree().create_timer(0.3).timeout
	
	# Aplicar daño
	var damage_dealt = 0.0
	if target.has_method("take_damage"):
		var old_health = target.current_health
		target.take_damage(steal_life_damage)
		damage_dealt = old_health - target.current_health
		print("💀 Daño aplicado: %.1f" % damage_dealt)
	
	# Curarse
	var heal_amount = damage_dealt * steal_life_heal_percent
	var old_druid_health = current_health
	current_health += heal_amount
	if current_health > max_health:
		current_health = max_health
	
	var actual_heal = current_health - old_druid_health
	print("💚 Druid curada: %.1f HP" % actual_heal)
	
	# Spawear efectos
	_spawn_steal_life_effect(target.global_position)
	_spawn_steal_life_effect(global_position)

func _spawn_steal_life_effect(world_position: Vector3) -> void:
	var ability_data = UnitAbilities.get_ability("stealLife_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró stealLife_ability en singleton")
		return
	
	var effect_scene = load(ability_data.animation_scene)
	if effect_scene == null:
		print("❌ No se pudo cargar Steal Life effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	
	print("💀 Efecto de Steal Life spawneado en: %v" % world_position)
	
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()

# ===================================================
# 🔥 VALIDACIÓN GENÉRICA
# ===================================================
func _validate_enemy_target(target: Entity) -> bool:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido")
		return false
	
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes atacar enemigos")
		return false
	
	return true
