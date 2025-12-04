extends Control
@onready var selected_name_label: Label = $UserNameSelected

const STARTING_OPTIONS = "res://Scenes/GUI/SinglePlayer/StartingOptions/startingOptions.tscn"
const CREDITS = "res://Scenes/GUI/CreditsMenu/creditsMenu.tscn"
const OPTIONS = "res://Scenes/GUI/OptionsMenu/optionsMenu.tscn"
const PROFILE = "res://Scenes/GUI/ProfileMenu/profileMenu.tscn"

var alert_profile_scene: PackedScene = preload("res://Scenes/GUI/Alerts/alertProfile.tscn")
var alert_profile_instance: Window  

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
	var user_selected = GlobalUser.current_user != ""
	match nombre_boton:
		"historyModeButton":
			if not user_selected:
				_show_alert_profile()
				return
			print("TextureButton JUGAR presionado")
		"singlePlayerButton":
			if not user_selected:
				_show_alert_profile()
				return
			FadeLayer.fade_to_scene(STARTING_OPTIONS)
		"lanButton":
			if not user_selected:
				_show_alert_profile()
				return
			print("TextureButton CREDITOS presionado")
		"quitButton":
			print("TextureButton SALIR presionado")
			get_tree().quit()
		"aboutUsButton":
			print("Botón About Us presionado, cambiando con fade...")
			FadeLayer.fade_to_scene(CREDITS)
		"optionsButton":
			if not user_selected:
				_show_alert_profile()
				return
			print("Botón Options presionado, cambiando con fade...")
			FadeLayer.fade_to_scene(OPTIONS)
		"profileButton":
			print("Botón Profile presionado, cambiando con fade...")
			FadeLayer.fade_to_scene(PROFILE)
		_:
			print("TextureButton desconocido:", nombre_boton)

func _show_alert_profile():
	if alert_profile_instance == null:
		alert_profile_instance = alert_profile_scene.instantiate()
		add_child(alert_profile_instance)
	alert_profile_instance.popup_centered()
