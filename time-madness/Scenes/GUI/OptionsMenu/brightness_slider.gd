extends HSlider

@onready var value_label: Label = $Label

# Ruta a la carpeta de perfiles
var profiles_folder: String = "user://profiles/"

func _ready():
	_load_value_from_user()
	update_label()
	self.value_changed.connect(Callable(self, "_on_value_changed"))

func _on_value_changed(value: float) -> void:
	update_label()

func update_label() -> void:
	value_label.text = str(round(value * 100) / 100.0)

# ------------------------------
func _load_value_from_user() -> void:
	var username: String = GlobalUser.current_user
	if username == "" or username == null:
		print("⚠️ No hay usuario global, no se cargará el valor del slider")
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
		if profile_dict["options"].has("brightness"):
			value = float(profile_dict["options"]["brightness"])
