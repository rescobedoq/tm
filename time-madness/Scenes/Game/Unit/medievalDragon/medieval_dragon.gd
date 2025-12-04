extends Unit
class_name MedievalDragon

const FIRE_BALL_PROJECTILE := "res://Scenes/Utils/FireBall/FireBall.tscn"

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
	
	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/fireBallIcon.jpg",
			"Fire Ball",
			"Launch a fire projectile.\nCosto: 1 energia",
			"fireBall_ability" 
		),
	]


# ===================================================
# 🔥 HABILIDAD: FIRE BALL
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "fireBall_ability":
		_start_fire_ball_ability()
	else:
		super.use_ability(ability)

func _start_fire_ball_ability() -> void:
	# Verificar energía
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Fire Ball (necesita 1)")
		return
	
	print("🔥 Iniciando habilidad FIRE BALL - Selecciona un objetivo")
	
	# 🔥 Activar selección de objetivo enemigo
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "fireBall_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "fireBall_ability" and target is Entity:
		_execute_fire_ball(target)

func _execute_fire_ball(target: Entity) -> void:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Fire Ball")
		return
	
	# Verificar que sea enemigo
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes atacar enemigos con Fire Ball")
		return
	
	# Verificar rango
	var distance = global_position.distance_to(target.global_position)
	if distance > fire_ball_range:
		print("❌ Objetivo demasiado lejos (%.1f / %.1f)" % [distance, fire_ball_range])
		return
	
	# Consumir energía
	current_magic -= 1
	print("🔥 FIRE BALL ACTIVADO!  Objetivo: %s" % target.name)
	print("💙 Energía restante: %. 1f" % current_magic)
	
	# Reproducir animación de ataque
	play_attack()
	
	# Esperar un momento para que se vea la animación
	await get_tree().create_timer(0.4).timeout
	
	# 🔥 Lanzar el proyectil
	_launch_fire_ball_projectile(target)

func _launch_fire_ball_projectile(target: Entity) -> void:
	var projectile_scene = load(FIRE_BALL_PROJECTILE)
	if projectile_scene == null:
		print("❌ No se pudo cargar Fire Ball projectile")
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	# 🔥 Posicionar el proyectil en la boca del dragón (ajusta según tu modelo)
	var spawn_offset = Vector3(0, 1, 2)  # Adelante y un poco arriba
	projectile. global_position = global_position + spawn_offset
	
	print("🔥 Fire Ball lanzado desde: %v hacia: %s" % [projectile.global_position, target. name])
	
	# 🔥 Reproducir animación del proyectil
	var animated_sprite = projectile.get_node_or_null("AnimatedSprite3D")
	if animated_sprite and animated_sprite is AnimatedSprite3D:
		animated_sprite.play()
		print("🔥 Animación del proyectil iniciada")
	
	# 🔥 Mover el proyectil hacia el objetivo
	_move_projectile_to_target(projectile, target)

func _move_projectile_to_target(projectile: Node3D, target: Entity) -> void:
	var max_travel_time = 5.0  # Máximo 5 segundos de vuelo
	var elapsed_time = 0.0
	
	while is_instance_valid(projectile) and is_instance_valid(target) and target.is_alive:
		await get_tree().process_frame
		
		if not is_instance_valid(projectile):
			break
		
		elapsed_time += get_process_delta_time()
		
		# Timeout de seguridad
		if elapsed_time > max_travel_time:
			print("⚠️ Fire Ball timeout - destruyendo proyectil")
			projectile.queue_free()
			break
		
		# 🔥 Calcular dirección hacia el objetivo (seguimiento cada frame)
		var direction = target.global_position - projectile. global_position
		direction.y = 0  # Mantener horizontal (opcional)
		var distance = direction.length()
		
		# 🔥 Si llegó al objetivo, aplicar daño y destruir
		if distance < 2.0:  # Radio de impacto
			print("💥 Fire Ball impactó a %s!" % target.name)
			
			# Aplicar daño
			if target.has_method("take_damage"):
				target.take_damage(fire_ball_damage)
				print("🔥 Daño por fuego aplicado: %.1f" % fire_ball_damage)
			
			# Destruir proyectil
			projectile.queue_free()
			break
		
		# 🔥 Mover el proyectil hacia el objetivo
		var movement = direction.normalized() * fire_ball_speed * get_process_delta_time()
		projectile.global_position += movement
		
		# 🔥 Rotar el proyectil hacia el objetivo
		if direction.length() > 0.01:
			var target_rotation = atan2(direction.x, direction.z)
			projectile. rotation. y = target_rotation
	
	# 🔥 Destruir proyectil si el objetivo murió o es inválido
	if is_instance_valid(projectile):
		print("🗑️ Fire Ball destruido (objetivo perdido)")
		projectile.queue_free()
