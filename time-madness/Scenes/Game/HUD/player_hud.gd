extends Control

signal tower_pressed
signal smithy_pressed
signal magic_pressed
signal dragon_pressed
signal harbor_pressed
signal shrine_pressed
signal barracks_pressed
signal farm_pressed




@onready var btn = $TextureButton
@onready var panel = $TextureRect

@onready var towerButton = $TextureRect/Control/towerButton
@onready var smithyButton = $TextureRect/Control/smithyButton
@onready var magicButton = $TextureRect/Control/magicButton
@onready var dragonButton = $TextureRect/Control/dragonButton
@onready var harborButton = $TextureRect/Control/harborButton
@onready var shrineButton = $TextureRect/Control/shrineButton
@onready var barracksButton = $TextureRect/Control/barracksButton
@onready var farmButton = $TextureRect/Control/farmButton

@onready var resourceNot = $ResourceNot
@onready var energyNot = $EnergyNot

var resource_not_origin := Vector2.ZERO
var energy_not_origin := Vector2.ZERO



var menu_open := true
const MENU_WIDTH := 400

func _on_tower_pressed():
	emit_signal("tower_pressed")

func _on_smithy_pressed():
	emit_signal("smithy_pressed")

func _on_magic_pressed():
	emit_signal("magic_pressed")

func _on_dragon_pressed():
	emit_signal("dragon_pressed")

func _on_harbor_pressed():
	emit_signal("harbor_pressed")

func _on_shrine_pressed():
	emit_signal("shrine_pressed")

func _on_barracks_pressed():
	emit_signal("barracks_pressed")

func _on_farm_pressed():
	emit_signal("farm_pressed")


func _ready() -> void:
	await get_tree().process_frame

	resource_not_origin = resourceNot.position
	energy_not_origin = energyNot.position
	panel.position.x = size.x - MENU_WIDTH
	btn.position.x = panel.position.x - btn.size.x 

	btn.pressed.connect(_on_button_pressed)

	# Conectar botones del menú a sus funciones
	towerButton.pressed.connect(_on_tower_pressed)
	smithyButton.pressed.connect(_on_smithy_pressed)
	magicButton.pressed.connect(_on_magic_pressed)
	dragonButton.pressed.connect(_on_dragon_pressed)
	harborButton.pressed.connect(_on_harbor_pressed)
	shrineButton.pressed.connect(_on_shrine_pressed)
	barracksButton.pressed.connect(_on_barracks_pressed)
	farmButton.pressed.connect(_on_farm_pressed)

	
func _on_resource_not():
	pass

func _on_energy_not():
	pass


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
func _show_resource_not() -> void:
	if not resourceNot:
		print("❌ ERROR: resourceNot no existe")
		return
	
	print("🚨 Mostrando alerta de recursos insuficientes")
	
	var tween = create_tween()
	var right_pos = resource_not_origin + Vector2(300, 0)  # Solo horizontal (derecha)

	resourceNot. visible = true
	resourceNot.modulate.a = 1.0
	resourceNot.position = resource_not_origin  # 🔥 Resetear posición inicial

	tween.tween_property(resourceNot, "position", right_pos, 0.3)
	tween.tween_interval(2.0)
	tween.tween_property(resourceNot, "position", resource_not_origin, 0.3)
	tween.tween_callback(func(): resourceNot.visible = false)


func _show_energy_not() -> void:
	if not energyNot:
		print("❌ ERROR: energyNot no existe")
		return
	
	print("⚡ Mostrando alerta de energía insuficiente")
	
	var tween = create_tween()
	var right_pos = energy_not_origin + Vector2(300, 0)  # Solo horizontal (derecha)

	energyNot.visible = true
	energyNot.modulate.a = 1.0
	energyNot.position = energy_not_origin  # 🔥 Resetear posición inicial

	tween.tween_property(energyNot, "position", right_pos, 0.3)
	tween.tween_interval(2.0)
	tween. tween_property(energyNot, "position", energy_not_origin, 0.3)
	tween.tween_callback(func(): energyNot.visible = false)
