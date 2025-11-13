extends Control

# Referencias a los playerBox
@onready var user_box: playerBox = $UserPlayerBox
@onready var box2: playerBox = $PlayerBox2
@onready var box3: playerBox = $PlayerBox3
@onready var box4: playerBox = $PlayerBox4
@onready var box5: playerBox = $PlayerBox5
@onready var box6: playerBox = $PlayerBox6

@onready var back_button: TextureButton = $backButton
@onready var start_button: TextureButton = $startButton

# Guardaremos los playerBoxes en una lista para manejarlos fácilmente
var bot_boxes: Array[playerBox] = []

func _ready() -> void:
	# Botón de volver
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	# Botón de start
	if not start_button.is_connected("pressed", Callable(self, "_on_start_button_pressed")):
		start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

	# Mostrar nombre del usuario
	var username = GlobalUser.current_user
	var user_label: Label = user_box.get_node("Label")
	user_label.text = username

	# Ocultar la dificultad para el jugador real
	user_box.difficult_button.visible = false

	# Inicializar los demás playerBox
	bot_boxes = [box2, box3, box4, box5, box6]
	_initialize_bots()

func _initialize_bots() -> void:
	var index := 1
	for box in bot_boxes:
		var label: Label = box.get_node("Label")
		label.text = "Inactive"
		label.mouse_filter = Control.MOUSE_FILTER_STOP  # Necesario para recibir input

		# Desactivar OptionButtons
		_set_box_enabled(box, false)

		# Conectar eventos
		if not label.is_connected("gui_input", Callable(self, "_on_bot_label_input")):
			label.gui_input.connect(_on_bot_label_input.bind(box, index))

		if not label.is_connected("mouse_entered", Callable(self, "_on_label_hover_enter")):
			label.mouse_entered.connect(_on_label_hover_enter.bind(label))

		if not label.is_connected("mouse_exited", Callable(self, "_on_label_hover_exit")):
			label.mouse_exited.connect(_on_label_hover_exit.bind(label))

		index += 1

func _on_bot_label_input(event: InputEvent, box: playerBox, bot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var label: Label = box.get_node("Label")

		if label.text.begins_with("Bot"):
			label.text = "Inactive"
			_set_box_enabled(box, false)
		else:
			label.text = "Bot %d" % bot_index
			_set_box_enabled(box, true)

# --- Hover del label ---
func _on_label_hover_enter(label: Label) -> void:
	if label.text == "Inactive":
		label.text = "Activate"

func _on_label_hover_exit(label: Label) -> void:
	if label.text == "Activate":
		label.text = "Inactive"

# --- Habilitar/deshabilitar OptionButtons ---
func _set_box_enabled(box: playerBox, enabled: bool) -> void:
	box.race_button.disabled = not enabled
	box.difficult_button.disabled = not enabled
	box.team_button.disabled = not enabled

	if not enabled:
		box.race_button.select(-1)
		box.difficult_button.select(-1)
		box.team_button.select(-1)

# --- NUEVO: Acción del botón START ---
func _on_start_button_pressed() -> void:
	print("--- VALIDANDO JUGADORES ---")

	var active_boxes: Array[playerBox] = [user_box]
	for box in bot_boxes:
		var label: Label = box.get_node("Label")
		if label.text.begins_with("Bot"):
			active_boxes.append(box)

	var all_valid := true

	for box in active_boxes:
		var label: Label = box.get_node("Label")
		var name := label.text

		var race_index := box.race_button.get_selected_id()
		var diff_index := box.difficult_button.get_selected_id()
		var team_index := box.team_button.get_selected_id()

		var missing := []
		if race_index == -1:
			missing.append("race")
		if diff_index == -1 and box != user_box:
			missing.append("difficulty")
		if team_index == -1:
			missing.append("team")

		if missing.size() > 0:
			print("⚠️ Falta llenar campos en %s: %s" % [name, ", ".join(missing)])
			all_valid = false

	if not all_valid:
		print("❌ Algunos jugadores no tienen todos los campos completados.")
		return

	# Si todo está correcto, imprimir la información
	print("--- JUGADORES ACTIVOS ---")
	for box in active_boxes:
		var label: Label = box.get_node("Label")
		var name := label.text

		var race := box.race_button.get_item_text(box.race_button.get_selected_id())
		var diff := box.difficult_button.get_item_text(box.difficult_button.get_selected_id()) if not box.difficult_button.disabled else "N/A"
		var team := box.team_button.get_item_text(box.team_button.get_selected_id())

		print("Jugador: %s | Raza: %s | Dificultad: %s | Equipo: %s" % [name, race, diff, team])

	print("✅ Todos los jugadores activos están listos.")

func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	FadeLayer.fade_to_scene("res://Scenes/GUI/MainMenu/mainMenu.tscn")
