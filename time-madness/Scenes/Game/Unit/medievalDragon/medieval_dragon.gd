extends Unit
class_name MedievalDragon

var selection_tween: Tween

# 🔥 Variables de Fire Ball
var fire_ball_damage: float = 75.0
var fire_ball_speed: float = 35.0
var fire_ball_range: float = 60.0

func _ready():
	portrait_path = "res://Assets/Images/Portraits/Units/medievalDragon.png"
	unit_category = "flying"
	anim_idle = "Idle"
	anim_move = "Flying"
	anim_attack = "Attack"
	anim_death = "GroundToFly"
	unit_type = "Medieval Dragon"
	
	super._ready()
	
	_set_abilities(["fireBall_ability"])

# ===================================================
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	if ability.ability_id == "fireBall_ability":
		_start_fire_ball_ability()
	else:
		super._execute_ability(ability)

# ===================================================
# 🔥 HABILIDAD: FIRE BALL
# ===================================================
func _start_fire_ball_ability() -> void:
	print("🔥 Iniciando habilidad FIRE BALL - Selecciona un objetivo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "fireBall_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "fireBall_ability" and target is Entity:
		_execute_fire_ball(target)

func _execute_fire_ball(target: Entity) -> void:
	if not _validate_fire_ball_target(target):
		return
	
	print("🔥 FIRE BALL ACTIVADO! Objetivo: %s" % target.name)
	
	# Reproducir animación de ataque
	play_attack()
	
	# Esperar animación
	await get_tree().create_timer(0.4).timeout
	
	# Lanzar proyectil
	_launch_fire_ball_projectile(target)

func _validate_fire_ball_target(target: Entity) -> bool:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Fire Ball")
		return false
	
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes atacar enemigos con Fire Ball")
		return false
	
	var distance = global_position.distance_to(target.global_position)
	if distance > fire_ball_range:
		print("❌ Objetivo demasiado lejos (%.1f / %.1f)" % [distance, fire_ball_range])
		return false
	
	return true

func _launch_fire_ball_projectile(target: Entity) -> void:
	var ability_data = UnitAbilities.get_ability("fireBall_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró fireBall_ability en singleton")
		return
	
	var projectile_scene = load(ability_data.animation_scene)
	if projectile_scene == null:
		print("❌ No se pudo cargar Fire Ball projectile")
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	# Posicionar en la boca del dragón
	var spawn_offset = Vector3(0, 1, 2)
	projectile.global_position = global_position + spawn_offset
	
	print("🔥 Fire Ball lanzado hacia: %s" % target.name)
	
	# Reproducir animación del proyectil
	var animated_sprite = projectile.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
	
	_move_projectile_to_target(projectile, target)

func _move_projectile_to_target(projectile: Node3D, target: Entity) -> void:
	var max_travel_time = 5.0
	var elapsed_time = 0.0
	
	while is_instance_valid(projectile) and is_instance_valid(target) and target.is_alive:
		await get_tree().process_frame
		
		if not is_instance_valid(projectile):
			break
		
		elapsed_time += get_process_delta_time()
		
		if elapsed_time > max_travel_time:
			print("⚠️ Fire Ball timeout")
			projectile.queue_free()
			break
		
		var direction = target.global_position - projectile.global_position
		direction.y = 0
		var distance = direction.length()
		
		# Impacto
		if distance < 2.0:
			print("💥 Fire Ball impactó a %s!" % target.name)
			
			if target.has_method("take_damage"):
				target.take_damage(fire_ball_damage)
				print("🔥 Daño por fuego: %.1f" % fire_ball_damage)
			
			projectile.queue_free()
			break
		
		# Mover proyectil
		var movement = direction.normalized() * fire_ball_speed * get_process_delta_time()
		projectile.global_position += movement
		
		# Rotar hacia objetivo
		if direction.length() > 0.01:
			var target_rotation = atan2(direction.x, direction.z)
			projectile.rotation.y = target_rotation
	
	# Limpiar si queda el proyectil
	if is_instance_valid(projectile):
		print("🗑️ Fire Ball destruido (objetivo perdido)")
		projectile.queue_free()
