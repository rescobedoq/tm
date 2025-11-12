extends Control

@onready var back_button = $backButton
@onready var name_line_edit = $NameLineEdit
@onready var create_button = $createButton

var profiles_folder: String = "user://profiles/"

func _ready():
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	if not create_button.is_connected("pressed", Callable(self, "_on_create_button_pressed")):
		create_button.connect("pressed", Callable(self, "_on_create_button_pressed"))

	if Engine.has_singleton("FadeLayer"):
		FadeLayer.anim_player.play("fade_in")
	else:
		print("Advertencia: FadeLayer no encontrado")

	ensure_profiles_folder_exists()
	list_profiles()

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
						print("Perfil encontrado:", profile_dict["username"])
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
	else:
		print("ERROR CRÍTICO: No se pudo abrir el archivo para escritura:", file_path)
