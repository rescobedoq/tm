extends Unit

@onready var anim_player = $medievalSoldier/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalSoldier.png"

var selection_tween: Tween
func _ready():
	play_idle()

	# --- CARGAR RETRATO AUTOMÁTICAMENTE ---
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
	anim_player.play("Idle_3_frame_rate_24_fbx")
	anim_player.get_animation("Idle_3_frame_rate_24_fbx").loop = true


func play_move():
	print(">>> play_move CALLED <<<")
	anim_player.play("Walking_frame_rate_24_fbx")


func play_attack():
	print(">>> play_attack CALLED <<<")
	anim_player.play("Attack_frame_rate_24_fbx")
