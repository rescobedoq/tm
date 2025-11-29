extends Unit
class_name Sorcerer

@onready var anim_player = $medievalSorcerer/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalSorcerer.png"
const AREA_DEFENSE_EFFECT := "res://Scenes/Utils/AreaDefense/AreaDefense.tscn"
const HEAL_EFFECT := "res://Scenes/Utils/Heal/Heal.tscn"
const MENTAL_CONTROL_EFFECT := "res://Scenes/Utils/MentalControl/MentalControl.tscn"

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
	super._ready()
	unit_type = "Medieval Sorcerer"
	max_health = 200
	current_health = max_health
	max_magic = 150  # 🔥 Suficiente para las 3 habilidades
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 30

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)
	
	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/areaDefenseIcon.jpg",
			"Area Defense",
			"Increase defense of nearby allies.\nCosto: 1 energia",
			"areaDefense_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/healIcon.jpg",
			"Heal",
			"Restore health to target ally.\nCosto: 1 energia",
			"heal_ability" 
		),		
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/mentalControlIcon.jpg",
			"Mental Control",
			"Take control of enemy unit.\nCosto: 1 energia",
			"mentalControl_ability" 
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
		anim_player.play("Charged_Spell_Cast_2_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Charged_Spell_Cast_2_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE
			
func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player. play("Dead_frame_rate_24_fbx")
		var anim = anim_player. get_animation("Dead_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE

# 🔥 Animaciones de habilidades
func play_area_defense_cast():
	if anim_player:
		print(">>> play_area_defense_cast CALLED <<<")
		anim_player.play("mage_soell_cast_5_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_5_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

func play_heal_cast():
	if anim_player:
		print(">>> play_heal_cast CALLED <<<")
		anim_player. play("mage_soell_cast_7_frame_rate_24_fbx")
		var anim = anim_player. get_animation("mage_soell_cast_7_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE

func play_mental_control_cast():
	if anim_player:
		print(">>> play_mental_control_cast CALLED <<<")
		anim_player.play("mage_soell_cast_8_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_8_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE

# ===================================================
# 🔥 SISTEMA DE HABILIDADES
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "areaDefense_ability":
		_execute_area_defense()
	elif ability.ability_id == "heal_ability":
		_start_heal_ability()
	elif ability.ability_id == "mentalControl_ability":
		_start_mental_control_ability()
	else:
		super.use_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: AREA DEFENSE
# ===================================================
func _execute_area_defense() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Area Defense (necesita 1)")
		return
	
	# Consumir energía
	current_magic -= 1
	print("🛡️ AREA DEFENSE ACTIVADO!")
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Reproducir animación
	play_area_defense_cast()
	
	# 🔥 Spawear efecto en la posición del mago
	_spawn_area_defense_effect()
	
	# 🔥 Aplicar buff de defensa a aliados cercanos
	_apply_area_defense_buff()

func _spawn_area_defense_effect() -> void:
	var effect_scene = load(AREA_DEFENSE_EFFECT)
	if effect_scene == null:
		print("❌ No se pudo cargar Area Defense effect")
		return
	
	area_defense_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(area_defense_instance)
	area_defense_instance.global_position = global_position
	var animated_sprite = area_defense_instance.get_node("AnimatedSprite3D")
	animated_sprite.play()
	print("🛡️ Efecto de Area Defense spawneado en posición del mago: %v" % global_position)
	
	# Auto-destruir después de la duración
	await get_tree().create_timer(area_defense_duration).timeout
	if is_instance_valid(area_defense_instance):
		area_defense_instance.queue_free()
		print("🗑️ Efecto de Area Defense eliminado")
		area_defense_instance = null

func _apply_area_defense_buff() -> void:
	if player_owner == null:
		return
	
	var buffed_units: Array = []
	
	# Buscar todas las unidades aliadas en rango
	for unit in player_owner.units:
		if not is_instance_valid(unit) or not unit.is_alive:
			continue
		
		var distance = global_position.distance_to(unit.global_position)
		if distance <= area_defense_radius:
			# Aplicar buff
			unit. defense += area_defense_bonus
			buffed_units.append(unit)
			print("🛡️ Buff aplicado a: %s (defensa: +%. 1f)" % [unit.name, area_defense_bonus])
	
	# Esperar duración y remover buff
	await get_tree().create_timer(area_defense_duration).timeout
	
	for unit in buffed_units:
		if is_instance_valid(unit):
			unit.defense -= area_defense_bonus
			print("🛡️ Buff removido de: %s" % unit.name)

# ===================================================
# 🔥 HABILIDAD 2: HEAL
# ===================================================
func _start_heal_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Heal (necesita 1)")
		return
	
	print("💚 Iniciando habilidad HEAL - Selecciona un aliado")
	
	# 🔥 Activar selección de ALIADO
	if player_owner and player_owner.has_method("_start_ability_ally_selection"):
		player_owner._start_ability_ally_selection(self, "heal_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_ally_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "heal_ability" and target is Entity:
		_execute_heal(target)
	elif ability_id == "mentalControl_ability" and target is Entity:
		_execute_mental_control(target)

func _execute_heal(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Heal")
		return
	
	# Verificar que sea aliado
	if target.player_owner != player_owner:
		print("⚠️ Solo puedes curar a tus aliados")
		return
	
	# Consumir energía
	current_magic -= 1
	print("💚 HEAL ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %.1f" % current_magic)
	
	# Reproducir animación
	play_heal_cast()
	
	# 🔥 Curar al objetivo
	var old_health = target.current_health
	target.current_health += heal_amount
	if target.current_health > target. max_health:
		target. current_health = target.max_health
	
	var actual_heal = target.current_health - old_health
	print("💚 %s curado por %. 1f HP (%. 1f -> %.1f)" % [target.name, actual_heal, old_health, target.current_health])
	
	# 🔥 Spawear efecto en el objetivo
	_spawn_heal_effect(target. global_position)

func _spawn_heal_effect(world_position: Vector3) -> void:
	var effect_scene = load(HEAL_EFFECT)
	if effect_scene == null:
		print("❌ No se pudo cargar Heal effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	var animated_sprite = effect_instance.get_node("AnimatedSprite3D")
	animated_sprite.play()
	
	print("💚 Efecto de Heal spawneado en: %v" % world_position)
	
	# Auto-destruir después de la duración
	await get_tree().create_timer(heal_effect_duration).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()
		print("🗑️ Efecto de Heal eliminado")

# ===================================================
# 🔥 HABILIDAD 3: MENTAL CONTROL
# ===================================================
func _start_mental_control_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Mental Control (necesita 1)")
		return
	
	print("🧠 Iniciando habilidad MENTAL CONTROL - Selecciona un enemigo")
	
	# 🔥 Activar selección de ENEMIGO
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "mentalControl_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func _execute_mental_control(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Mental Control")
		return
	
	# Verificar que sea enemigo
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes controlar enemigos")
		return
	
	# Consumir energía
	current_magic -= 1
	print("🧠 MENTAL CONTROL ACTIVADO!  Objetivo: %s" % target. name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Reproducir animación
	play_mental_control_cast()
	
	# 🔥 Spawear efecto en el mago Y en el objetivo
	_spawn_mental_control_effect(global_position)
	_spawn_mental_control_effect(target.global_position)
	
	# 🔥 Transferir control de la unidad
	_transfer_unit_control(target)

func _spawn_mental_control_effect(world_position: Vector3) -> void:
	var effect_scene = load(MENTAL_CONTROL_EFFECT)
	if effect_scene == null:
		print("❌ No se pudo cargar Mental Control effect")
		return
	
	var effect_instance = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = world_position
	var animated_sprite = effect_instance.get_node("AnimatedSprite3D")
	animated_sprite.play()
	print("🧠 Efecto de Mental Control spawneado en: %v" % world_position)
	
	# Auto-destruir después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(effect_instance):
		effect_instance.queue_free()
		print("🗑️ Efecto de Mental Control eliminado")

func _transfer_unit_control(target: Entity) -> void:
	if target. player_owner == null or player_owner == null:
		print("❌ No se puede transferir control: player_owner no válido")
		return
	
	var old_owner = target.player_owner
	var new_owner = player_owner
	
	print("🧠 Transfiriendo control de %s" % target.name)
	print("   De: %s → A: %s" % [old_owner.player_name, new_owner.player_name])
	
	# 🔥 Remover del antiguo dueño
	if target in old_owner.units:
		old_owner.units.erase(target)
	if target in old_owner.attack_units:
		old_owner.attack_units.erase(target)
	if target in old_owner.defense_units:
		old_owner.defense_units.erase(target)
	
	# Actualizar labels del antiguo dueño
	if old_owner. has_method("_update_units_labels"):
		old_owner._update_units_labels()
	
	# 🔥 Agregar al nuevo dueño
	target.player_owner = new_owner
	new_owner.add_unit(target)
	
	# Cancelar cualquier acción de la unidad
	if target. has_method("_cancel_attack"):
		target._cancel_attack()
	target.has_move_target = false
	target.is_moving = false
	
	print("✅ Control transferido exitosamente!")
