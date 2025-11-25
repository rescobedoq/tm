extends Unit
class_name ShipNormal

@onready var anim_player = $medievalShipNormal/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalShipNormal.png"

var selection_tween: Tween

func _ready():
	super._ready()
	
	unit_type = "Medieval Ship Normal"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 3.0

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

func play_idle():
	print(">>> play_idle CALLED <<<")
	# No tiene animación

func play_move():
	print(">>> play_move CALLED <<<")
	# No tiene animación

func play_attack():
	print(">>> play_attack CALLED <<<")
	# No tiene animación
