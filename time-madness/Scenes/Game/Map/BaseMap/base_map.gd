extends Node3D

# Referencias a nodos
@onready var player_controller = $PlayerController
@onready var unit1 = $MedievalSoldierControler
@onready var unit2 = $MedievalSoldierControler2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Registrar las unidades existentes en el PlayerController
	player_controller.add_unit(unit1)
	player_controller.add_unit(unit2)
	
	# Opcional: puedes asignar nombres a las unidades para pruebas
	unit1.name = "Soldado 1"
	unit2.name = "Soldado 2"

	print("Unidades del jugador registradas:", player_controller.units.size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
