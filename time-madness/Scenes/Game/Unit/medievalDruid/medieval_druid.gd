extends Unit
class_name MedievalDruid

@onready var anim_player = $medievalDruid/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalDruid.png"
const ROOT_EFFECT := "res://Scenes/Utils/Root/Root.tscn"
const STEAL_LIFE_EFFECT := "res://Scenes/Utils/StealLife/StealLife.tscn"

var selection_tween: Tween

# 🔥 Variables de Root Unit
var root_damage: float = 30.0
var root_duration: float = 5.0
var root_slow_percent: float = 0.8  # Reduce velocidad al 20% (80% de reducción)

# 🔥 Variables de Steal Life
var steal_life_damage: float = 40.0
var steal_life_heal_percent: float = 1.0  # Cura el 100% del daño hecho

func _ready():
	unit_category = "ground"
	super._ready()
	unit_type = "Medieval Druid"
	max_health = 200
	current_health = max_health
	max_magic = 100  # 🔥 Suficiente energía
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 20
	attack_range = 30

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/rootIcon.png",
			"Root Unit",
			"Damage and slow enemy unit.\nCosto: 1 energia",
			"rootUnit_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/stealcon.jpg",
			"Steal Life",
			"Drain life from enemy.\nCosto: 1 energia",
			"stealLife_ability" 
		),
	]

func play_idle():
	if anim_player:
		print(">>> play_idle CALLED <<<")
		anim_player. play("Idle_7_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Idle_7_frame_rate_24_fbx")
		if anim:
			anim. loop_mode = Animation.LOOP_LINEAR

func play_move():
	if anim_player:
		print(">>> play_move CALLED <<<")
		anim_player.play("Walking_Woman_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Walking_Woman_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_LINEAR

func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.play("Charged_Spell_Cast_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Charged_Spell_Cast_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE
			
func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("Fall_Dead_from_Abdominal_Injury_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Fall_Dead_from_Abdominal_Injury_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# 🔥 Animación de habilidades
func play_spell_cast():
	if anim_player:
		print(">>> play_spell_cast CALLED <<<")
		anim_player.play("Charged_Ground_Slam_frame_rate_24_fbx")
		var anim = anim_player. get_animation("Charged_Ground_Slam_frame_rate_24_fbx")
		if anim:
			anim. loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 SISTEMA DE HABILIDADES
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "rootUnit_ability":
		_start_root_unit_ability()
	elif ability.ability_id == "stealLife_ability":
		_start_steal_life_ability()
	else:
		super.use_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: ROOT UNIT (Enraizar)
# ===================================================
func _start_root_unit_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Root Unit (necesita 1)")
		return
	
	print("🌿 Iniciando habilidad ROOT UNIT - Selecciona un enemigo")
	
	# 🔥 Activar selección de objetivo enemigo
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "rootUnit_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "rootUnit_ability" and target is Entity:
		_execute_root_unit(target)
	elif ability_id == "stealLife_ability" and target is Entity:
		_execute_steal_life(target)

func _execute_root_unit(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Root Unit")
		return
	
	# Verificar que sea enemigo
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes enraizar enemigos")
		return
	
	# Consumir energía
	current_magic -= 1
	print("🌿 ROOT UNIT ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Reproducir animación
	play_spell_cast()
	
	# Esperar un momento
	await get_tree().create_timer(0.3).timeout
	
	# 🔥 Aplicar daño
	if target. has_method("take_damage"):
		target.take_damage(root_damage)
		print("🌿 Daño aplicado: %.1f" % root_damage)
	
	# 🔥 Spawear efecto en el objetivo
	_spawn_root_effect(target. global_position)
	
	# 🔥 Aplicar efecto de ralentización
	_apply_root_slow(target)

func _spawn_root_effect(world_position: Vector3) -> void:
	var effect_scene = load(ROOT_EFFECT)
	if effect_scene == null:
		print("❌ No se pudo cargar Root effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	
	print("🌿 Efecto de Root spawneado en: %v" % world_position)
	
	# 🔥 Reproducir animación
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	# Auto-destruir después de la duración
	await get_tree().create_timer(root_duration).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()
		print("🗑️ Efecto de Root eliminado")

func _apply_root_slow(target: Entity) -> void:
	if not is_instance_valid(target) or not target is Unit:
		return
	
	var target_unit = target as Unit
	
	# Guardar velocidad original
	var original_speed = target_unit.move_speed
	
	# Reducir velocidad (80% más lento)
	var reduced_speed = original_speed * (1.0 - root_slow_percent)
	target_unit.move_speed = reduced_speed
	
	print("🌿 Velocidad reducida: %.1f -> %.1f (%.0f%% más lento)" % [original_speed, reduced_speed, root_slow_percent * 100])
	
	# Esperar duración y restaurar velocidad
	await get_tree().create_timer(root_duration).timeout
	
	if is_instance_valid(target_unit):
		target_unit. move_speed = original_speed
		print("🌿 Velocidad restaurada a: %.1f" % original_speed)

# ===================================================
# 🔥 HABILIDAD 2: STEAL LIFE (Robar vida)
# ===================================================
func _start_steal_life_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Steal Life (necesita 1)")
		return
	
	print("💀 Iniciando habilidad STEAL LIFE - Selecciona un enemigo")
	
	# 🔥 Activar selección de objetivo enemigo
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "stealLife_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func _execute_steal_life(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Steal Life")
		return
	
	# Verificar que sea enemigo
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes robar vida a enemigos")
		return
	
	# Consumir energía
	current_magic -= 1
	print("💀 STEAL LIFE ACTIVADO!  Objetivo: %s" % target. name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Reproducir animación
	play_spell_cast()
	
	# Esperar un momento
	await get_tree().create_timer(0.3).timeout
	
	# 🔥 Aplicar daño al objetivo
	var damage_dealt = 0.0
	if target. has_method("take_damage"):
		var old_health = target.current_health
		target.take_damage(steal_life_damage)
		damage_dealt = old_health - target.current_health
		print("💀 Daño aplicado: %.1f" % damage_dealt)
	
	# 🔥 Curarse a sí misma
	var heal_amount = damage_dealt * steal_life_heal_percent
	var old_druid_health = current_health
	current_health += heal_amount
	if current_health > max_health:
		current_health = max_health
	
	var actual_heal = current_health - old_druid_health
	print("💚 Druid curada: %.1f HP (%.1f -> %.1f)" % [actual_heal, old_druid_health, current_health])
	
	# 🔥 Spawear efecto en el OBJETIVO
	_spawn_steal_life_effect(target.global_position)
	
	# 🔥 Spawear efecto en el DRUID
	_spawn_steal_life_effect(global_position)

func _spawn_steal_life_effect(world_position: Vector3) -> void:
	var effect_scene = load(STEAL_LIFE_EFFECT)
	if effect_scene == null:
		print("❌ No se pudo cargar Steal Life effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	
	print("💀 Efecto de Steal Life spawneado en: %v" % world_position)
	
	# 🔥 Reproducir animación
	var animated_sprite = effect_instance.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	# Auto-destruir después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()
		print("🗑️ Efecto de Steal Life eliminado")
