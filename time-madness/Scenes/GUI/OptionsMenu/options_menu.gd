extends Node

@onready var back_button: TextureButton = $backButton
@onready var brightness_slider: HSlider = $brightnessSlider
@onready var mouse_slider: HSlider = $mouseSensibilitySlider
@onready var options_button: OptionButton = $OptionsButton
@onready var font_check_group: Node = $fontCheckGroup

var profiles_folder := "user://profiles/"

func _ready():
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	# Conectar sliders
	brightness_slider.value_changed.connect(_on_option_changed)
	mouse_slider.value_changed.connect(_on_option_changed)

	# Conectar OptionButton
	options_button.item_selected.connect(_on_option_changed)

	# Conectar CheckBoxes del grupo
	for child in font_check_group.get_children():
		if child is CheckBox:
			child.toggled.connect(_on_option_changed)

	# Animación de entrada
	if Engine.has_singleton("FadeLayer"):
		FadeLayer.anim_player.play("fade_in")
	else:
		print("⚠️ Advertencia: FadeLayer no encontrado (¿autoload configurado?)")

func _on_back_button_pressed():
	FadeLayer.fade_to_scene("res://Scenes/GUI/MainMenu/mainMenu.tscn")

func _on_option_changed(arg = null) -> void:
	print_current_settings()
	_save_user_settings()

func print_current_settings() -> void:
	var brightness := brightness_slider.value
	var mouse_sens := mouse_slider.value
	var selected_option := options_button.get_item_text(options_button.selected)

	var selected_font := "Ninguno"
	for child in font_check_group.get_children():
		if child is CheckBox and child.button_pressed:
			selected_font = child.name
			break

	print("\n--- CONFIGURACIÓN ACTUAL ---")
	print("Brillo:", brightness)
	print("Sensibilidad del mouse:", mouse_sens)
	print("Opción seleccionada:", selected_option)
	print("Fuente seleccionada:", selected_font)
	print("----------------------------")


# ===================== Guardado automático =====================
func _save_user_settings():
	var username: String = GlobalUser.current_user
	if username == "" or username == null:
		print("⚠️ No hay usuario global seleccionado para guardar la configuración")
		return

	var file_path: String = "%s%s.json" % [profiles_folder, username]
	if not FileAccess.file_exists(file_path):
		print("⚠️ No se encontró el archivo JSON del usuario:", username)
		return

	# Leer JSON existente
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ No se pudo abrir el archivo JSON del usuario:", username)
		return

	var data_text: String = file.get_as_text()
	file.close()

	# Parsear JSON correctamente
	var json_parser := JSON.new()
	var err: int = json_parser.parse(data_text)
	if err != OK:
		print("❌ Error al parsear el JSON del usuario:", username)
		return

	var profile_dict: Dictionary = json_parser.get_data() as Dictionary
	if typeof(profile_dict) != TYPE_DICTIONARY:
		print("❌ El JSON del usuario no es un diccionario válido:", username)
		return

	# Asegurar la clave "options"
	if not profile_dict.has("options") or typeof(profile_dict["options"]) != TYPE_DICTIONARY:
		profile_dict["options"] = {}

	var options_dict: Dictionary = profile_dict["options"] as Dictionary
	options_dict["brightness"] = brightness_slider.value
	options_dict["mouse_sensitivity"] = mouse_slider.value
	options_dict["font_size"] = _get_selected_font_checked()
	options_dict["language"] = options_button.get_item_text(options_button.selected)
	profile_dict["options"] = options_dict

	# Guardar JSON de nuevo
	var file_write: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file_write:
		print("❌ No se pudo guardar el archivo JSON del usuario:", username)
		return

	file_write.store_string(JSON.stringify(profile_dict, "\t"))
	file_write.close()
	print("✅ Configuración guardada automáticamente para:", username)


func _get_selected_font_checked() -> String:
	for child in font_check_group.get_children():
		if child is CheckBox and child.button_pressed:
			return child.name
	return "Medium"
