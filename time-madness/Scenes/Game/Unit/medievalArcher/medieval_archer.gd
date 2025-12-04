extends Unit
class_name MedievalArcher

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalArcher.png"
const ARROW_PROJECTILE := "res://Scenes/Utils/Arrows/Arrows.tscn"
const TRAP_SCENE := "res://Scenes/Utils/Trap/Trap.tscn"

var selection_tween: Tween

# 🔥 Variables de Arrows (Lluvia de flechas)
var arrows_count: int = 5
var arrows_delay: float = 0.15
var arrow_damage: float = 15.0
var arrow_speed: float = 40.0
var arrow_range: float = 50.0

# 🔥 Variables de Trap
var trap_damage: float = 40.0
var trap_duration: float = 10.0
var trap_trigger_radius: float = 2.0

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
	
	super._ready()  # 🔥 Llamar DESPUÉS de configurar el aura
	
	unit_type = "Medieval Archer"
	max_health = 200
	current_health = max_health
	max_magic = 100
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 15
	attack_range = 30.0

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)
	
	abilities = [
		UnitAbility. new(
			"res://Assets/Images/HUD/icons/arrowsIcon.jpg",
			"Arrows",
			"Shoot multiple arrows.\nCosto: 1 energia",
			"arrows_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/trapIcon.jpg",
			"Trap",
			"Place a trap on the ground.\nCosto: 1 energia",
			"trap_ability" 
		),
	]

# 🔥 NUEVA FUNCIÓN: Actualizar color del aura si cambia el propietario
func set_player_owner(new_owner: Node) -> void:
	player_owner = new_owner
	
	if aura_controller and player_owner and "player_index" in player_owner:
		aura_controller.set_aura_color_from_player(player_owner. player_index)
		print("✅ Aura actualizada para nuevo propietario (jugador %d)" % player_owner.player_index)
	
func play_idle():
	if anim_player:
		print(">>> play_idle CALLED <<<")
		anim_player.play("Idle_6_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Idle_6_frame_rate_24_fbx")
		if anim:
			anim. loop_mode = Animation.LOOP_LINEAR

func play_move():
	if anim_player:
		print(">>> play_move CALLED <<<")
		anim_player.play("RunFast_frame_rate_24_fbx")
		var anim = anim_player.get_animation("RunFast_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.play("Archery_Shot_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Archery_Shot_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("dying_backwards_frame_rate_24_fbx")
		var anim = anim_player.get_animation("dying_backwards_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation. LOOP_NONE

func play_rapid_shot():
	if anim_player:
		print(">>> play_rapid_shot CALLED <<<")
		anim_player.play("Archery_Shot_1_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Archery_Shot_1_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 SISTEMA DE HABILIDADES
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "arrows_ability":
		_start_arrows_ability()
	elif ability.ability_id == "trap_ability":
		_start_trap_ability()
	else:
		super.use_ability(ability)

# ===================================================
# 🔥 HABILIDAD 1: ARROWS (Lluvia de flechas)
# ===================================================
func _start_arrows_ability() -> void:
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Arrows")
		return
	
	print("🏹 Iniciando habilidad ARROWS - Selecciona un objetivo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "arrows_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "arrows_ability" and target is Entity:
		_execute_arrows(target)
	elif ability_id == "trap_ability" and target is Vector3:
		_execute_trap(target)

func _execute_arrows(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Arrows")
		return
	
	if target. player_owner == player_owner:
		print("⚠️ Solo puedes atacar enemigos con Arrows")
		return
	
	var distance = global_position.distance_to(target.global_position)
	if distance > arrow_range:
		print("❌ Objetivo demasiado lejos (%.1f / %.1f)" % [distance, arrow_range])
		return
	
	current_magic -= 1
	print("🏹 ARROWS ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	_shoot_arrow_barrage(target)

func _shoot_arrow_barrage(target: Entity) -> void:
	for i in range(arrows_count):
		if not is_instance_valid(target) or not target.is_alive:
			print("🛑 Objetivo perdido, cancelando lluvia de flechas")
			break
		
		play_rapid_shot()
		await get_tree().create_timer(arrows_delay).timeout
		_launch_arrow(target, i)
	
	print("✅ Lluvia de flechas completada")
	play_idle()

func _launch_arrow(target: Entity, arrow_index: int) -> void:
	var arrow_scene = load(ARROW_PROJECTILE)
	if arrow_scene == null:
		print("❌ No se pudo cargar Arrow projectile")
		return
	
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	
	var spawn_offset = Vector3(randf_range(-0.5, 0.5), 2, 1)
	arrow.global_position = global_position + spawn_offset
	
	print("🏹 Flecha %d/%d lanzada hacia: %s" % [arrow_index + 1, arrows_count, target.name])
	
	var animated_sprite = arrow.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	_move_arrow_to_target(arrow, target)

func _move_arrow_to_target(arrow: Node3D, target: Entity) -> void:
	var max_travel_time = 3.0
	var elapsed_time = 0.0
	
	while is_instance_valid(arrow) and is_instance_valid(target) and target.is_alive:
		await get_tree().process_frame
		
		if not is_instance_valid(arrow):
			break
		
		elapsed_time += get_process_delta_time()
		
		if elapsed_time > max_travel_time:
			arrow.queue_free()
			break
		
		var direction = target.global_position - arrow.global_position
		direction. y = 0
		var distance = direction.length()
		
		if distance < 1.5:
			print("💥 Flecha impactó!")
			
			if target.has_method("take_damage"):
				target.take_damage(arrow_damage)
				print("🏹 Daño aplicado: %.1f" % arrow_damage)
			
			arrow.queue_free()
			break
		
		var movement = direction.normalized() * arrow_speed * get_process_delta_time()
		arrow.global_position += movement
		
		if direction.length() > 0.01:
			var target_rotation = atan2(direction.x, direction.z)
			arrow.rotation. y = target_rotation
	
	if is_instance_valid(arrow):
		arrow.queue_free()

# ===================================================
# 🔥 HABILIDAD 2: TRAP (Trampa)
# ===================================================
func _start_trap_ability() -> void:
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Trap")
		return
	
	print("🪤 Iniciando habilidad TRAP - Selecciona un lugar")
	
	if player_owner and player_owner.has_method("_start_ability_terrain_selection"):
		player_owner._start_ability_terrain_selection(self, "trap_ability", 20.0)
	else:
		print("⚠️ PlayerController no tiene _start_ability_terrain_selection()")

func _execute_trap(target_position: Vector3) -> void:
	current_magic -= 1
	print("🪤 TRAP ACTIVADO! Posición: %v" % target_position)
	print("💙 Energía restante: %.1f" % current_magic)
	
	var trap_scene = load(TRAP_SCENE)
	if trap_scene == null:
		print("❌ No se pudo cargar Trap scene")
		return
	
	var trap = trap_scene.instantiate()
	get_tree().current_scene.add_child(trap)
	trap.global_position = target_position
	
	print("🪤 Trampa colocada en: %v" % target_position)
	
	var trap_active = true
	var trapped_units = []
	
	var animated_sprite = trap.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	var elapsed_time = 0.0
	while trap_active and elapsed_time < trap_duration:
		await get_tree().process_frame
		elapsed_time += get_process_delta_time()
		
		if not is_instance_valid(trap):
			break
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		
		var sphere = SphereShape3D.new()
		sphere.radius = trap_trigger_radius
		query.shape = sphere
		query.transform = Transform3D(Basis(), trap.global_position)
		query.collision_mask = 1 << 1
		
		var results = space_state.intersect_shape(query)
		
		for result in results:
			var collider = result["collider"]
			
			if collider is Entity and collider not in trapped_units:
				var unit = collider as Entity
				
				print("💥 TRAMPA ACTIVADA! Víctima: %s" % unit.name)
				
				if unit.has_method("take_damage"):
					unit.take_damage(trap_damage)
					print("🪤 Daño de trampa aplicado: %.1f a %s" % [trap_damage, unit.name])
				
				trapped_units.append(unit)
				trap_active = false
				
				await get_tree().create_timer(0.5).timeout
				if is_instance_valid(trap):
					trap.queue_free()
					print("🗑️ Trampa destruida después de activarse")
				
				return
	
	if is_instance_valid(trap):
		trap.queue_free()
		print("🗑️ Trampa expirada sin activarse")
