extends Unit
class_name MedievalDruid

@onready var anim_player = $medievalDruid/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalDruid.png"

var selection_tween: Tween

func _ready():
	super._ready()
	unit_category = "ground"
	unit_type = "Medieval Druid"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 20
	attack_range = 3.0

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

func play_idle():
	if anim_player:
		print(">>> play_idle CALLED <<<")
		anim_player.play("Idle_7_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Idle_7_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_move():
	if anim_player:
		print(">>> play_move CALLED <<<")
		anim_player.play("Walking_Woman_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Walking_Woman_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.play("Attack_frame_rate_24_fbx")
