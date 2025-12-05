extends Unit
class_name MagicSoldier

var selection_tween: Tween

# 🔥 Variables de Magic Ball
var magic_ball_damage: float = 50.0
var magic_ball_speed: float = 30.0
var magic_ball_range: float = 50.0

func _ready():
	portrait_path = "res://Assets/Images/Portraits/Units/medievalMagicSoldier.png"
	unit_category = "ground"
	anim_idle = "Idle"
	anim_move = "Walking_frame_rate_24_fbx"
	anim_attack = "mage_soell_cast_frame_rate_24_fbx"
	anim_death = "Dead_frame_rate_24_fbx"
	unit_type = "Medieval Magic Soldier"
	
	super._ready()
	
	_set_abilities(["magicBall_ability"])

# 🔥 Animación de lanzar Magic Ball
func play_magic_ball_cast():
	if anim_player:
		anim_player.play("mage_soell_cast_3_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_3_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

# ===================================================
# 🔥 OVERRIDE: EJECUTAR HABILIDADES
# ===================================================
func _execute_ability(ability: UnitAbility) -> void:
	if ability.ability_id == "magicBall_ability":
		_start_magic_ball_ability()
	else:
		super._execute_ability(ability)

# ===================================================
# 🔥 HABILIDAD: MAGIC BALL
# ===================================================
func _start_magic_ball_ability() -> void:
	print("🔮 Iniciando habilidad MAGIC BALL - Selecciona un objetivo")
	
	if player_owner and player_owner.has_method("_start_ability_target_selection"):
		player_owner._start_ability_target_selection(self, "magicBall_ability")
	else:
		print("⚠️ PlayerController no tiene _start_ability_target_selection()")

func on_ability_target_selected(ability_id: String, target) -> void:
	if ability_id == "magicBall_ability" and target is Entity:
		_execute_magic_ball(target)

func _execute_magic_ball(target: Entity) -> void:
	if not _validate_magic_ball_target(target):
		return
	
	print("🔮 MAGIC BALL ACTIVADO! Objetivo: %s" % target.name)
	
	play_magic_ball_cast()
	await get_tree().create_timer(0.3).timeout
	
	_launch_magic_ball_projectile(target)

func _validate_magic_ball_target(target: Entity) -> bool:
	if target == null or not is_instance_valid(target):
		print("❌ Objetivo inválido para Magic Ball")
		return false
	
	if target.player_owner == player_owner:
		print("⚠️ Solo puedes atacar enemigos con Magic Ball")
		return false
	
	var distance = global_position.distance_to(target.global_position)
	if distance > magic_ball_range:
		print("❌ Objetivo demasiado lejos (%.1f / %.1f)" % [distance, magic_ball_range])
		return false
	
	return true

func _launch_magic_ball_projectile(target: Entity) -> void:
	var ability_data = UnitAbilities.get_ability("magicBall_ability")
	if ability_data.size() == 0:
		print("❌ No se encontró magicBall_ability en singleton")
		return
	
	var projectile_scene = load(ability_data.animation_scene)
	if projectile_scene == null:
		print("❌ No se pudo cargar Magic Ball projectile")
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	var spawn_offset = Vector3(0, 2, 1)
	projectile.global_position = global_position + spawn_offset
	
	print("🔮 Magic Ball lanzado hacia: %s" % target.name)
	
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
			print("⚠️ Magic Ball timeout")
			projectile.queue_free()
			break
		
		var direction = target.global_position - projectile.global_position
		direction.y = 0
		var distance = direction.length()
		
		if distance < 1.5:
			print("💥 Magic Ball impactó a %s!" % target.name)
			
			if target.has_method("take_damage"):
				target.take_damage(magic_ball_damage)
				print("⚡ Daño aplicado: %.1f" % magic_ball_damage)
			
			projectile.queue_free()
			break
		
		var movement = direction.normalized() * magic_ball_speed * get_process_delta_time()
		projectile.global_position += movement
		
		if direction.length() > 0.01:
			var target_rotation = atan2(direction.x, direction.z)
			projectile.rotation.y = target_rotation
	
	if is_instance_valid(projectile):
		print("🗑️ Magic Ball destruido (objetivo perdido)")
		projectile.queue_free()
