extends Node
class_name PlayerController

# ------------------------------
# Nombre del jugador
# ------------------------------
@export var player_name: String = "Jugador"

# ------------------------------
# Opciones de la camara.
# ------------------------------
@export_range(0, 1000) var movement_speed: float = 64
@export_range(0, 1000) var rotation_speed: float = 5
@export_range(0, 1000, 0.1) var zoom_speed: float = 50
@export_range(0, 1000) var min_zoom: float = 32
@export_range(0, 1000) var max_zoom: float = 256
@export_range(0, 90) var min_elevation_angle: float = 10
@export_range(0, 90) var max_elevation_angle: float = 90
@export var edge_margin: float = 50
@export var allow_rotation: bool = true
@export var allow_zoom: bool = true
@export var allow_pan: bool = true

@export var min_x: float = 0
@export var max_x: float = 250
@export var min_z: float = -250
@export var max_z: float = 0


# ------------------------------
# Recursos
# ------------------------------
@export var gold: int = 500       # Oro inicial
@export var upkeep: int = 0       # Manutención (por unidad o edificio)

# ------------------------------
# Unidades del jugador
# ------------------------------
var units: Array = []             # Lista de unidades que pertenecen al jugador
var selected_unit: Entity = null  # Unidad actualmente seleccionada

# ------------------------------
# Cámara del jugador para raycasts
# ------------------------------
var camera: Camera3D = null

# ------------------------------
# Gestión de unidades del jugador
# ------------------------------

# Registra una unidad en el jugador
func add_unit(unit: Entity) -> void:
	if unit == null:
		return
	
	# Evita duplicados
	if unit not in units:
		units.append(unit)
		# Asigna automáticamente al jugador
		unit.player_owner = self
		print("Unidad agregada a ", player_name, ": ", unit.name)
func _ready() -> void:
	var rts = $RtsController
	rts.movement_speed = movement_speed
	rts.rotation_speed = rotation_speed
	rts.zoom_speed = zoom_speed
	rts.min_zoom = min_zoom
	rts.max_zoom = max_zoom
	rts.min_elevation_angle = min_elevation_angle
	rts.max_elevation_angle = max_elevation_angle
	rts.edge_margin = edge_margin
	rts.allow_rotation = allow_rotation
	rts.allow_zoom = allow_zoom
	rts.allow_pan = allow_pan
	rts.min_x = min_x
	rts.max_x = max_x
	rts.min_z = min_z
	rts.max_z = max_z
