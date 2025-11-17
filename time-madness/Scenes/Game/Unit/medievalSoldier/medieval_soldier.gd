extends Unit

@onready var anim_player = $AnimationPlayer

func play_idle():
	print(">>> play_idle CALLED <<<")
	anim_player.play("Idle_3_frame_rate_24_fbx")
	anim_player.get_animation("Idle_3_frame_rate_24_fbx").loop = true

func play_move():
	print(">>> play_move CALLED <<<")
	anim_player.play("Walking_frame_rate_24_fbx")

func play_attack():
	print(">>> play_move CALLED <<<")
	anim_player.play("Attack_frame_rate_24_fbx")
