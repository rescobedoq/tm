extends Control

func _ready():
	for boton in get_children():
		if boton is TextureButton:
			boton.connect("pressed", Callable(self, "_on_boton_presionado").bind(boton.name))

func _on_boton_presionado(nombre_boton):
	match nombre_boton:
		"historyModeButton":
			print("TextureButton JUGAR presionado")

		"singlePlayerButton":
			print("TextureButton OPCIONES presionado")

		"lanButton":
			print("TextureButton CREDITOS presionado")

		"quitButton":
			print("TextureButton SALIR presionado")

		"aboutUsButton":
			get_tree().change_scene_to_file("res://Scenes/GUI/CreditsMenu/creditsMenu.tscn")

		"optionsButton":
			get_tree().change_scene_to_file("res://Scenes/GUI/OptionsMenu/optionsMenu.tscn")

		"profileButton":
			get_tree().change_scene_to_file("res://Scenes/GUI/ProfileMenu/profileMenu.tscn")

		_:
			print("TextureButton desconocido:", nombre_boton)
			
			
			
