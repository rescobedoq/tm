extends Unit
class_name MagicSoldier

@onready var anim_player = $medievalMagicSoldier/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalMagicSoldier.png"

var selection_tween: Tween
func _ready():
	unit_type = "Medieval Magic Soldier"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 3.0
	
	
	play_idle()

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

# ---------------------------------------------------
#   ANIMACIONES DEL SOLDADO
# ---------------------------------------------------

func play_idle():
	print(">>> play_idle CALLED <<<")
	if anim_player.is_playing():
		anim_player.stop()



func play_move():
	print(">>> play_move CALLED <<<")
	anim_player.play("Walking_frame_rate_24_fbx")
	anim_player.get_animation("Walking_frame_rate_24_fbx").loop = true


func play_attack():
	print(">>> play_attack CALLED <<<")
