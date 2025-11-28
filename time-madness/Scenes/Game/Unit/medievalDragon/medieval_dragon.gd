extends Unit
class_name MedievalDragon

@onready var anim_player = $Dragon2/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalDragon.png"

var selection_tween: Tween

func _ready():
	unit_category = "flying"
	super._ready()
	unit_type = "Medieval Dragon"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 20
	attack_range = 40

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

func play_idle():
	if anim_player:
		print(">>> play_idle CALLED <<<")
		anim_player.play("Idle")
		var anim = anim_player.get_animation("Idle")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

func play_move():
	if anim_player:
		print(">>> play_move CALLED <<<")
		anim_player.play("Flying")
		var anim = anim_player.get_animation("Flying")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR


func play_attack():
	if anim_player:
		print(">>> play_attack CALLED <<<")
		anim_player.play("Attack")
		var anim = anim_player.get_animation("Attack")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE


func play_death():
	if anim_player:
		print(">>> play_death CALLED <<<")
		anim_player.play("GroundToFly")
		var anim = anim_player.get_animation("GroundToFly")
		if anim:
			anim.loop_mode = Animation.LOOP_NONE
