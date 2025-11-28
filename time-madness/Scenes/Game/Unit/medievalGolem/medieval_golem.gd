extends Unit
class_name MedievalGolem

@onready var anim_player = $medievalGolem/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalGolem.png"

var selection_tween: Tween

func _ready():
	unit_category = "ground"
	super._ready()
	unit_type = "Medieval Golem"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 10

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)
	abilities = [
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/golemIcom.jpg",
			"Spawn",
			"....\nCosto: 50 energia",
			"spawn_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/punchIcon.jpg",
			"Punch",
			"....\nCosto: 50 energia",
			"punch_ability" 
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
		anim_player.play("Right_Hand_Sword_Slash_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Right_Hand_Sword_Slash_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("Shot_and_Fall_Backward_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Shot_and_Fall_Backward_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR
