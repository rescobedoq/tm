extends Node2D

@export var velocidad: float = 1.0
@export var amplitud: float = 500.0

var tiempo: float = 0.0
var posicion_inicial: Vector2

func _ready():
	posicion_inicial = position

func _process(delta):
	tiempo += delta
	position.y = posicion_inicial.y + sin(tiempo * velocidad / 100.0) * amplitud
