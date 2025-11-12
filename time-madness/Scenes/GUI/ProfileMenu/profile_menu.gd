extends Control

@onready var back_button = $backButton
@onready var name_line_edit = $NameLineEdit
@onready var create_button = $createButton
@onready var profiles_list: VBoxContainer = $ScrollContainer/ProfilesList

@onready var delete_button: TextureButton = $deleteProfileButton
@onready var profile_sprite: Sprite2D = $ProfileName
@onready var selected_name_label: Label = $ProfileName/UserNameSelected
@onready var quit_profile_button: TextureButton = $quitProfileButton 

var profiles_folder: String = "user://profiles/"

func _ready():
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	if not create_button.is_connected("pressed", Callable(self, "_on_create_button_pressed")):
		create_button.connect("pressed", Callable(self, "_on_create_button_pressed"))
	if not delete_button.is_connected("pressed", Callable(self, "_on_delete_button_pressed")):
		delete_button.connect("pressed", Callable(self, "_on_delete_button_pressed"))
	if not quit_profile_button.is_connected("pressed", Callable(self, "_on_quit_profile_button_pressed")):
		quit_profile_button.connect("pressed", Callable(self, "_on_quit_profile_button_pressed"))  # 👈 nueva conexión

	if Engine.has_singleton("FadeLayer"):
		FadeLayer.anim_player.play("fade_in")
	else:
		print("Advertencia: FadeLayer no encontrado")

	ensure_profiles_folder_exists()
	list_profiles()
	_update_selected_user_ui()


func _add_profile_button(username: String):
	var button := Button.new()
	button.text = username
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.custom_minimum_size = Vector2(0, 40)
	button.connect("pressed", Callable(self, "_on_profile_selected").bind(username))
	profiles_list.add_child(button)


func _on_profile_selected(username: String):
	GlobalUser.set_user(username)
	print("👤 Perfil seleccionado:", username)
	_update_selected_user_ui()

func list_profiles():
	var dir := DirAccess.open(profiles_folder)
	if dir == null:
		print("No se pudo abrir la carpeta de perfiles.")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".json"):
			var file_path := "%s%s" % [profiles_folder, file_name]

			var file := FileAccess.open(file_path, FileAccess.READ)
			if file:
				var data := file.get_as_text()
				file.close()

				var json := JSON.new()
				var err := json.parse(data)

				if err == OK:
					var profile_dict: Dictionary = json.get_data() 
					if profile_dict.has("username"):
						var username: String = profile_dict["username"]
						print("Perfil encontrado:", username)
						_add_profile_button(username)
					else:
						print("Archivo sin campo 'username':", file_path)
				else:
					print("Error al parsear JSON en:", file_path)
			else:
				print("No se pudo abrir archivo:", file_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	print("--- Fin de la lista ---")



func _on_back_button_pressed():
	FadeLayer.fade_to_scene("res://Scenes/GUI/MainMenu/mainMenu.tscn")

func ensure_profiles_folder_exists():
	var absolute_path = ProjectSettings.globalize_path(profiles_folder)
	var dir: DirAccess = DirAccess.open(profiles_folder)
	if dir != null:
		print("La carpeta de perfiles ya existe.")
	else:
		# Crear directamente desde user://
		var user_dir: DirAccess = DirAccess.open("user://")
		if user_dir:
			var err = user_dir.make_dir_recursive("user://profiles")
			if err == OK:
				print("Carpeta de perfiles creada correctamente.")
			else:
				push_error("No se pudo crear la carpeta de perfiles. Código: %d" % err)
		else:
			push_error("ERROR: No se pudo abrir user://")

func _on_create_button_pressed():
	var name: String = name_line_edit.text.strip_edges()

	if name == "":
		print("ERROR: Nombre vacío")
		return

	ensure_profiles_folder_exists()

	var original_name = name
	var counter = 1
	var file_path = "%s%s.json" % [profiles_folder, name]
	while FileAccess.file_exists(file_path):
		name = "%s_%d" % [original_name, counter]
		file_path = "%s%s.json" % [profiles_folder, name]
		counter += 1

	var new_profile = PlayerProfile.new()
	new_profile.username = name

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(new_profile.to_dict()))
		file.close()
		print("✅ Perfil creado correctamente:", name)
		
		_clear_profiles_list()
		list_profiles()
	else:
		print("ERROR CRÍTICO: No se pudo abrir el archivo para escritura:", file_path)


func _clear_profiles_list():
	for child in profiles_list.get_children():
		child.queue_free()


func _update_selected_user_ui():
	if GlobalUser.current_user != "":
		selected_name_label.text = GlobalUser.current_user
		delete_button.visible = true
	else:
		selected_name_label.text = "Ningún perfil seleccionado"
		delete_button.visible = false

# 🗑️ Eliminar perfil seleccionado
func _on_delete_button_pressed():
	var username := GlobalUser.get_user()
	if username == "":
		print("⚠️ No hay usuario seleccionado para eliminar.")
		return

	var file_path := "%s%s.json" % [profiles_folder, username]
	var absolute_path := ProjectSettings.globalize_path(file_path)

	if FileAccess.file_exists(file_path):
		var err := DirAccess.remove_absolute(absolute_path)
		if err == OK:
			print("🗑️ Perfil eliminado:", username)
			GlobalUser.set_user("")  # limpiar usuario global
			_clear_profiles_list()
			list_profiles()
			_update_selected_user_ui()
		else:
			push_error("❌ No se pudo eliminar el archivo del perfil. Código: %d" % err)
	else:	
		print("⚠️ El archivo del perfil no existe:", file_path)
		GlobalUser.set_user("")
		_update_selected_user_ui()
		
func _on_quit_profile_button_pressed():
	if GlobalUser.current_user != "":
		print("👋 Cerrando sesión de:", GlobalUser.current_user)
	GlobalUser.set_user("")
	_update_selected_user_ui()
