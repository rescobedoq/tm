extends Node

@onready var mediumFontCheckBox: CheckBox = $medium
@onready var smallFontCheckBox: CheckBox = $small
@onready var largeFontCheckBox: CheckBox = $large

var checkboxes: Array[CheckBox]

# Carpeta de perfiles
var profiles_folder: String = "user://profiles/"

func _ready():
	checkboxes = [mediumFontCheckBox, smallFontCheckBox, largeFontCheckBox]

	# Conectar señales
	for cb in checkboxes:
		cb.toggled.connect(_on_checkbox_toggled.bind(cb))

	# Marcar el CheckBox que viene del JSON del usuario
	_load_font_from_user()


func _on_checkbox_toggled(pressed: bool, sender: CheckBox) -> void:
	if not pressed:
		return
	for cb in checkboxes:
		if cb != sender:
			if cb.pressed:
				cb.set_pressed(false)


# ------------------------------
# Cargar el font_size del usuario y marcar el CheckBox correspondiente
func _load_font_from_user() -> void:
	var username: String = GlobalUser.current_user
	if username == "" or username == null:
		print("⚠️ No hay usuario global, no se cargará la fuente")
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
		var font_size: String = profile_dict["options"].get("font_size", "Medium")
		
		# Marcar el CheckBox correcto
		match font_size.to_lower():
			"small":
				smallFontCheckBox.set_pressed(true)
			"medium":
				mediumFontCheckBox.set_pressed(true)
			"large":
				largeFontCheckBox.set_pressed(true)
			_:
				mediumFontCheckBox.set_pressed(true)  # valor por defecto
