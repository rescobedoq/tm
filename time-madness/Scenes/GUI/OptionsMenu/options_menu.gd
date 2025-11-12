extends Control

func _ready():
	$backButton.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/GUI/MainMenu/mainMenu.tscn")
