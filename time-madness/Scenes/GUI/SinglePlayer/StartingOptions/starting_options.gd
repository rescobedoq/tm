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

var bot_boxes: Array[playerBox] = []

func _ready() -> void:
	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	var username = GlobalUser.current_user
	var user_label: Label = user_box.get_node("Label")
	user_label.text = username

	user_box.difficult_button.visible = false

	bot_boxes = [box2, box3, box4, box5, box6]
	_initialize_bots()

func _initialize_bots() -> void:
	var index := 1
	for box in bot_boxes:
		var label: Label = box.get_node("Label")
		label.text = "Inactive"
		label.mouse_filter = Control.MOUSE_FILTER_STOP  
		_set_box_enabled(box, false)

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

func _on_label_hover_enter(label: Label) -> void:
	if label.text == "Inactive":
		label.text = "Activate"

func _on_label_hover_exit(label: Label) -> void:
	if label.text == "Activate":
		label.text = "Inactive"

func _set_box_enabled(box: playerBox, enabled: bool) -> void:
	box.race_button.disabled = not enabled
	box.difficult_button.disabled = not enabled
	box.team_button.disabled = not enabled

	if not enabled:
		box.race_button.select(-1)
		box.difficult_button.select(-1)
		box.team_button.select(-1)

func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	FadeLayer.fade_to_scene("res://Scenes/GUI/MainMenu/mainMenu.tscn")
