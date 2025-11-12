extends Control
@onready var selected_name_label: Label = $UserNameSelected

func _ready():
	for boton in get_children():
		if boton is TextureButton:
			boton.connect("pressed", Callable(self, "_on_boton_presionado").bind(boton.name))
	_update_selected_user_ui()

func _update_selected_user_ui():
	if GlobalUser.current_user != "":
		selected_name_label.text = GlobalUser.current_user
	else:
		selected_name_label.text = "-"
		
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
			print("Botón About Us presionado, cambiando con fade...")
			FadeLayer.fade_to_scene("res://Scenes/GUI/CreditsMenu/creditsMenu.tscn")

		"optionsButton":
			print("Botón Options presionado, cambiando con fade...")
			FadeLayer.fade_to_scene("res://Scenes/GUI/OptionsMenu/optionsMenu.tscn")

		"profileButton":
			print("Botón Profile presionado, cambiando con fade...")
			FadeLayer.fade_to_scene("res://Scenes/GUI/ProfileMenu/profileMenu.tscn")

		_:
			print("TextureButton desconocido:", nombre_boton)
