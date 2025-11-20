extends Node3D
class_name PlayerController

# ------------------------------
# Nombre del jugador
# ------------------------------
@export var player_name: String = "Jugador"

@onready var hud_portrait: TextureRect = $"../UnitHud/Portrait"
@onready var hud_attack: Label = $"../UnitHud/Attack"
@onready var hud_defense: Label = $"../UnitHud/Defense"
@onready var hud_velocity: Label = $"../UnitHud/Velocity"
@onready var hud_health: TextureProgressBar = $"../UnitHud/healthBar"
@onready var hud_energy: TextureProgressBar = $"../UnitHud/energyBar"
@onready var hud_name: Label = $"../UnitHud/UnitType"

@onready var attackButton: TextureButton = $"../UnitHud/attackButton"
@onready var stopButton: TextureButton = $"../UnitHud/stopButton"
@onready var keepPosButton: TextureButton = $"../UnitHud/keepPosButton"
@onready var moveButton: TextureButton = $"../UnitHud/moveButton"


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

# Variables para manejar el cursor.
var select_cursor_instance: Node2D = null
var is_selecting_terrain: bool = false


# ------------------------------
# Cámara del jugador para raycasts
# ------------------------------
@onready var camera: Camera3D = $RtsController/Elevation/Camera3D
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
		
		

# En PlayerController.gd
func _unhandled_input(event):

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(">>> Click izquierdo detectado")
			
		if camera == null:
			print("ERROR: No hay cámara asignada en PlayerController")
			return

		# Obtener ray
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		print("Ray desde cámara:", from, " -> ", to)

		# Crear parámetros del raycast
		var params = PhysicsRayQueryParameters3D.create(from, to)
		
		# Ejecutar raycast
		var result = get_world_3d().direct_space_state.intersect_ray(params)
		
		if result:
			print("Collider detectado:", result.collider)
			
			if result.collider is Entity:
				var entity = result.collider as Entity
				print("Collider es una Entity:", entity.name)
				
				if entity.player_owner == self:
					print("Unidad pertenece a este jugador, seleccionando...")
					select_unit(entity)
				else:
					print("Unidad NO pertenece a este jugador, deseleccionando actual")
					deselect_current_unit()
			else:
				print("Collider NO es una Entity, deseleccionando actual")
				deselect_current_unit()
		else:
			print("No se detectó ningún collider, deseleccionando actual")
			deselect_current_unit()


func select_unit(entity: Entity) -> void:
	if entity == null:
		return

	# Deseleccionar unidad anterior
	if selected_unit != null and selected_unit != entity:
		selected_unit.deselect()

	# Marcar la nueva unidad
	selected_unit = entity
	selected_unit.select()

	print("Unidad seleccionada: ", selected_unit.name)

	# ---- IMPRIME Y ACTUALIZA PORTRAIT ----
	if selected_unit.portrait:
		print("El portrait es:", selected_unit.portrait)

		if hud_portrait:
			hud_portrait.texture = selected_unit.portrait
	else:
		print("Esta unidad NO tiene portrait asignado.")

		if hud_portrait:
			hud_portrait.texture = null


	# ---- CASTING SEGÚN TIPO ----
	if entity is Unit:
		print("SE HA SELECCIONADO UNA UNIDAD!!!!")
		var u := entity as Unit  
		hud_attack.text = "Attack: " + str(u.attack_damage)
		hud_defense.text = "Defense: " + str(u.defense)
		hud_velocity.text = "Speed: " + str(u.move_speed)
		hud_health.max_value = u.max_health
		hud_energy.max_value = u.max_magic
		hud_name.text = u.unit_type
		hud_health.value = u.current_health
		hud_energy.value = u.current_magic
		
func deselect_current_unit() -> void:
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null

		# limpiar portrait del HUD
		if hud_portrait:
			hud_portrait.texture = null
			
		hud_attack.text = "Attack: -"
		hud_defense.text = "Defense: -"
		hud_velocity.text = "Speed: -"
		hud_health.max_value = 10000
		hud_energy.max_value = 10000
		hud_name.text = ""

		hud_health.value = 0
		hud_energy.value = 0


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
	
	#Senales de los botones
	# Conectar señal del botón
	moveButton.pressed.connect(_on_move_button_pressed)
	
func _on_move_button_pressed() -> void:
	if is_selecting_terrain:
		return # Ya esta en modo seleccion

	var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
	if select_scene == null:
		print("ERROR: No se pudo cargar SelectTerrain.tscn")
		return
	
	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)
	
	is_selecting_terrain = true
	print("Modo selección de terreno activado")
	
	# Opcional: ocultar cursor normal
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _process(delta: float) -> void:
	if is_selecting_terrain and select_cursor_instance:
		var mouse_pos = get_viewport().get_mouse_position()
		select_cursor_instance.position = mouse_pos
		
		# Avanzar animación
		var animated_sprite = select_cursor_instance.get_node("AnimatedSprite2D")
		if animated_sprite:
			if not animated_sprite.is_playing():
				animated_sprite.play("default")
