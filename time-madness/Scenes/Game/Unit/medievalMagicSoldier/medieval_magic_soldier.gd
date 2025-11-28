extends Unit
class_name MagicSoldier

@onready var anim_player = $medievalMagicSoldier/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalMagicSoldier.png"

var selection_tween: Tween

func _ready():
	unit_category = "ground"
	super._ready()
	unit_type = "Medieval Magic Soldier"
	max_health = 200
	current_health = max_health
	max_magic = 30
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
		anim_player.play("mage_soell_cast_frame_rate_24_fbx")
		var anim = anim_player.get_animation("mage_soell_cast_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("Dead_frame_rate_24_fbx")
		var anim = anim_player.get_animation("Dead_frame_rate_24_fbx")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR
