extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var fade_rect = $ColorRect

var next_scene_path: String = ""



func fade_to_scene(path: String):
	next_scene_path = path
	anim_player.play("fade_out")

func _ready():
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	anim_player.play("fade_in")

func _on_animation_finished(anim_name: String):
	if anim_name == "fade_out" and next_scene_path != "":
		var path = next_scene_path
		next_scene_path = ""
		get_tree().change_scene_to_file(path)
		await get_tree().process_frame
		anim_player.play("fade_in")
