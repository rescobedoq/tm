extends Control

@onready var back_button = $backButton
const MAIN_MENU_SCENE := "res://Scenes/GUI/MainMenu/mainMenu.tscn"
func _ready():
	if back_button and not back_button.is_connected("pressed", _on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)

	if Engine.has_singleton("FadeLayer"):
		FadeLayer.anim_player.play("fade_in")
	else:
		print("Advertencia: FadeLayer no encontrado (¿autoload configurado?)")

func _on_back_button_pressed():
	FadeLayer.fade_to_scene(MAIN_MENU_SCENE)
