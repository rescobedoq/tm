extends Control

@onready var btn = $TextureButton
@onready var panel = $TextureRect

var menu_open := true
const MENU_WIDTH := 300

func _ready() -> void:
	await get_tree().process_frame  # Esperar a que size sea correcto

	# Posición inicial (menú visible a la derecha)
	panel.position.x = size.x - MENU_WIDTH
	btn.position.x = panel.position.x - btn.size.x  # Ajusta si quieres que quede pegado

	btn.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if menu_open:
		close_menu()
	else:
		open_menu()

func open_menu() -> void:
	var tween = create_tween()
	tween.tween_property(panel, "position:x", size.x - MENU_WIDTH, 0.25)
	tween.tween_property(btn, "position:x", size.x - MENU_WIDTH - btn.size.x, 0.25)
	menu_open = true

func close_menu() -> void:
	var tween = create_tween()
	tween.tween_property(panel, "position:x", size.x, 0.25)
	tween.tween_property(btn, "position:x", size.x - btn.size.x, 0.25)
	menu_open = false
