extends Control

@onready var back_button = $backButton

func _ready():
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	if Engine.has_singleton("FadeLayer"):
		FadeLayer.anim_player.play("fade_in")
	else:
		print("Advertencia: FadeLayer no encontrado (¿autoload configurado?)")


func _on_back_button_pressed():
	FadeLayer.fade_to_scene("res://Scenes/GUI/MainMenu/mainMenu.tscn")
