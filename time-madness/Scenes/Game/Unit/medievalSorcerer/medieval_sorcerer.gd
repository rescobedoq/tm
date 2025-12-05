extends Unit
class_name Sorcerer

var selection_tween: Tween

# 🔥 Variables de habilidades
var area_defense_radius: float = 20.0
var area_defense_bonus: float = 15.0
var area_defense_duration: float = 10.0
var area_defense_instance: Node3D = null

var heal_amount: float = 50.0
var heal_effect_duration: float = 2.0

func _ready():
	unit_category = "ground"
	anim_idle = "Idle_3_frame_rate_24_fbx"
	anim_move = "Walking_frame_rate_24_fbx"
	anim_attack = "Charged_Spell_Cast_2_frame_rate_24_fbx"
	anim_death = "Dead_frame_rate_24_fbx"
	portrait_path = "res://Assets/Images/Portraits/Units/medievalSorcerer. png"
	unit_type = "Medieval Sorcerer"
	
	super._ready()
	
	_set_abilities(["areaDefense_ability", "heal_ability", "mentalControl_ability"])

# 🔥 Animaciones de habilidades
func play_area_defense_cast():
	if anim_player:
		anim_player.play("mage_soell_cast_5_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_5_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

func play_heal_cast():
	if anim_player:
		anim_player. play("mage_soell_cast_7_frame_rate_24_fbx")
		var anim = anim_player. get_animation("mage_soell_cast_7_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE

func play_mental_control_cast():
	if anim_player:
		anim_player.play("mage_soell_cast_8_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_8_frame_rate_24_fbx")
		if anim:
			anim. loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	match ability.ability_id:
		"areaDefense_ability":
			_execute_area_defense()
		"heal_ability":
			_start_heal_ability()
		"mentalControl_ability":
			_start_mental_control_ability()
		_:
			super._execute_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: AREA DEFENSE
# ===================================================
func _execute_area_defense() -> void:
	print("🛡️ AREA DEFENSE ACTIVADO!")
	
	play_area_defense_cast()
	_spawn_area_defense_effect()
	_apply_area_defense_buff()

func _spawn_area_defense_effect() -> void:
	var ability_data = UnitAbilities.get_ability("areaDefense_ability")
	if ability_data. size() == 0:
		print("❌ No se encontró areaDefense_ability en singleton")
		return
	
	var effect_scene = load(ability_data. animation_scene)
	if effect_scene == null:
		print("❌ No se pudo cargar Area Defense effect")
		return
	
	area_defense_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(area_defense_instance)
	area_defense_instance. global_position = global_position
	
	var animated_sprite = area_defense_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	print("🛡️ Efecto de Area Defense spawneado")
	
	await get_tree().create_timer(area_defense_duration).timeout
	if is_instance_valid(area_defense_instance):
		area_defense_instance.queue_free()
		area_defense_instance = null

func _apply_area_defense_buff() -> void:
	if player_owner == null:
		return
	
	var buffed_units: Array = []
	
	for unit in player_owner.units:
		if not is_instance_valid(unit) or not unit. is_alive:
			continue
		
		var distance = global_position.distance_to(unit. global_position)
		if distance <= area_defense_radius:
			unit.defense += area_defense_bonus
			buffed_units.append(unit)
			print("🛡️ Buff aplicado a: %s (+%. 1f defensa)" % [unit.name, area_defense_bonus])
	
	await get_tree().create_timer(area_defense_duration).timeout
	
	for unit in buffed_units:
		if is_instance_valid(unit):
			unit. defense -= area_defense_bonus
			print("🛡️ Buff removido de: %s" % unit.name)

# ===================================================
# 🔥 HABILIDAD 2: HEAL
# ===================================================
func _start_heal_ability() -> void:
	print("💚 Iniciando habilidad HEAL - Selecciona un aliado")
	
	if player_owner and player_owner.has_method("_start_ability_ally_selection"):
		player_owner._start_ability_ally_selection(self, "heal_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_ally_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	match ability_id:
		"heal_ability":
			if target is Entity:
				_execute_heal(target)
		"mentalControl_ability":
			if target is Entity:
				_execute_mental_control(target)

func _execute_heal(target: Entity) -> void:
	if not _validate_ally_target(target):
		return
	
	print("💚 HEAL ACTIVADO!  Objetivo: %s" % target.name)
	
	play_heal_cast()
	
	var old_health = target. current_health
	target.current_health += heal_amount
	if target.current_health > target.max_health:
		target.current_health = target.max_health
	
	var actual_heal = target.current_health - old_health
	print("💚 %s curado por %. 1f HP" % [target.name, actual_heal])
	
	_spawn_heal_effect(target. global_position)

func _spawn_heal_effect(world_position: Vector3) -> void:
	var ability_data = UnitAbilities. get_ability("heal_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró heal_ability en singleton")
		return
	
	var effect_scene = load(ability_data. animation_scene)
	if effect_scene == null:
		print("❌ No se pudo cargar Heal effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene. add_child(effect_instance)
	effect_instance.global_position = world_position
	
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	await get_tree().create_timer(heal_effect_duration).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()

# ===================================================
# 🔥 HABILIDAD 3: MENTAL CONTROL
# ===================================================
func _start_mental_control_ability() -> void:
	print("🧠 Iniciando habilidad MENTAL CONTROL - Selecciona un enemigo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "mentalControl_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func _execute_mental_control(target: Entity) -> void:
	if not _validate_enemy_target(target):
		return
	
	print("🧠 MENTAL CONTROL ACTIVADO! Objetivo: %s" % target.name)
	
	play_mental_control_cast()
	
	_spawn_mental_control_effect(global_position)
	_spawn_mental_control_effect(target. global_position)
	
	_transfer_unit_control(target)

func _spawn_mental_control_effect(world_position: Vector3) -> void:
	var ability_data = UnitAbilities.get_ability("mentalControl_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró mentalControl_ability en singleton")
		return
	
	var effect_scene = load(ability_data.animation_scene)
	if effect_scene == null:
		print("❌ No se pudo cargar Mental Control effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(effect_instance):
		effect_instance. queue_free()

func _transfer_unit_control(target: Entity) -> void:
	if target.player_owner == null or player_owner == null:
		print("❌ No se puede transferir control")
		return
	
	var old_owner = target.player_owner
	var new_owner = player_owner
	
	print("🧠 Transfiriendo control de %s" % target.name)
	
	# Remover del antiguo dueño
	if target in old_owner.units:
		old_owner.units.erase(target)
	if target in old_owner.attack_units:
		old_owner.attack_units. erase(target)
	if target in old_owner.defense_units:
		old_owner. defense_units.erase(target)
	
	if old_owner. has_method("_update_units_labels"):
		old_owner._update_units_labels()
	
	# Agregar al nuevo dueño
	target. set_player_owner(new_owner)
	new_owner. add_unit(target)
	
	# Cancelar acciones
	if target.has_method("_cancel_attack"):
		target._cancel_attack()
	target.has_move_target = false
	target.is_moving = false
	
	print("✅ Control transferido!")

# ===================================================
# 🔥 VALIDACIONES
# ===================================================
func _validate_ally_target(target: Entity) -> bool:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido")
		return false
	
	if target.player_owner != player_owner:
		print("⚠️ Solo puedes curar a tus aliados")
		return false
	
	return true

func _validate_enemy_target(target: Entity) -> bool:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido")
		return false
	
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes controlar enemigos")
		return false
	
	return true
