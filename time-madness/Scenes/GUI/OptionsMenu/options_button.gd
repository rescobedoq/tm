extends OptionButton

var profiles_folder: String = "user://profiles/"

func _ready():
	_load_language_from_user()

func _load_language_from_user() -> void:
	var username: String = GlobalUser.current_user
	if username == "" or username == null:
		print("⚠️ No hay usuario global, no se cargará el idioma")
		return

	var file_path: String = "%s%s.json" % [profiles_folder, username]
	if not FileAccess.file_exists(file_path):
		print("⚠️ No se encontró el archivo JSON del usuario:", username)
		return

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ No se pudo abrir el archivo JSON del usuario:", username)
		return

	var data_text: String = file.get_as_text()
	file.close()

	var json_parser := JSON.new()
	if json_parser.parse(data_text) != OK:
		print("❌ Error al parsear el JSON del usuario:", username)
		return

	var profile_dict: Dictionary = json_parser.get_data() as Dictionary
	if profile_dict.has("options") and profile_dict["options"] is Dictionary:
		var language: String = profile_dict["options"].get("language", "en")
		
		# Mapear el idioma a los IDs del OptionButton
		match language.to_lower():
			"en", "english":
				selected = 0
			"sp", "spanish":
				selected = 1
			"fr", "french":
				selected = 2
			"por", "portuguese":
				selected = 3
			_:
				selected = 0  # valor por defecto
