extends Control

# Referencias a los playerBox

@onready var user_box: playerBox = $UserPlayerBox
@onready var box2: playerBox = $PlayerBox2
@onready var box3: playerBox = $PlayerBox3
@onready var box4: playerBox = $PlayerBox4
@onready var box5: playerBox = $PlayerBox5
@onready var box6: playerBox = $PlayerBox6

func _ready() -> void:
	var username = GlobalUser.current_user

	var label = user_box.get_node("Label") as Label
	label.text = username

	# Ocultar el OptionButton de dificultad solo para el usuario actual
	user_box.difficult_button.visible = false

func _process(delta: float) -> void:
	pass
