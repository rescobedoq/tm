extends Node3D
class_name PlayerController

# ==============================
# Nombre del jugador
# ==============================
@export var player_name: String = "Jugador"

# ===== HUD =====================
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


# ===== TeamHUD =====================
@onready var upKeepLabel: Label = $"../TeamHud/maintenance"
@onready var resourcesLabel: Label = $"../TeamHud/prime"
@onready var goldLabel: Label = $"../TeamHud/money"

@onready var menu_hud: Control = $"../PlayerHud";

# ===== Configuración de cámara =====
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

# ===== Recursos =====
@export var gold: int = 500
@export var resources: int = 500
@export var upkeep: int = 0
@export var maxUpKeep: int = 10

# ===== Unidades =====
var units: Array = []
var selected_unit: Entity = null

# Cursor de selección de terreno
var select_cursor_instance: Node2D = null
var is_selecting_terrain: bool = false

var is_placing_building: bool = false
var build_placeholder: Node3D = null


# Cámara para raycast
@onready var camera: Camera3D = $RtsController/Elevation/Camera3D

# ==============================
# Añadir unidades
# ==============================
func add_unit(unit: Entity) -> void:
	if unit == null:
		return
	if unit not in units:
		units.append(unit)
		unit.player_owner = self
		print("Unidad agregada a ", player_name, ": ", unit.name)
		
		
		
func update_team_hud() -> void:
	print("SE LLAMO!")
	if upKeepLabel:
		print("waos1")
		upKeepLabel.text = str(upkeep) + " / " + str(maxUpKeep)
	if resourcesLabel:
		print("waos2")
		resourcesLabel.text = str(resources)
	if goldLabel:
		print("waos3")
		goldLabel.text = str(gold)



# ==============================
# Manejo de input (clicks)
# ==============================
func _unhandled_input(event):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	print("CLICK!!!!")
	
	if camera == null:
		print("ERROR: No hay cámara asignada en PlayerController")
		return

	var mouse_pos = event.position
	# ------------------------------
# MODO DE SELECCIÓN DE TERRENO
# ------------------------------
	if is_selecting_terrain:
		print(">>> Entramos en MODO SELECCIÓN DE TERRENO")
		
		# Obtener posición del mouse en viewport
		mouse_pos = get_viewport().get_mouse_position()
		print("Mouse position en viewport:", mouse_pos)
		
		# Obtener rayo desde cámara
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		print("Ray desde cámara (origen):", from, " - dirección:", dir)
		
		# Intersectar con plano horizontal del terreno (Y=0)
		var plane_y = 0.0  # altura del terreno
		var target_pos: Vector3  # declarar aquí para todo el scope

		if dir.y == 0:
			print("Dirección del raycast paralela al plano, no se puede calcular intersección")
			target_pos = from
		else:
			var t = (plane_y - from.y) / dir.y
			target_pos = from + dir * t

		
		print("Posición objetivo en plano del terreno:", target_pos)
		
		# Mover la unidad si hay una seleccionada
		if selected_unit:
			print("Unidad seleccionada:", selected_unit.name)
			selected_unit.move_to(target_pos)
			print("Moviendo unidad a:", target_pos)
		else:
			print("No hay unidad seleccionada, no se mueve nada")
		
		# Restaurar estado del cursor
		is_selecting_terrain = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if select_cursor_instance:
			print("Eliminando cursor de selección")
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		print(">>> Fin del modo selección de terreno")
		return  # Evita seleccionar unidades mientras estamos en modo terreno


	else:
		# ------------------------------
		# Modo selección de unidades
		# ------------------------------
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		params.collision_mask = 1 << 1  # Layer 2 -> Unidades

		var result = get_world_3d().direct_space_state.intersect_ray(params)
		if result and result.collider is Entity:
			var entity = result.collider as Entity
			if entity.player_owner == self:
				select_unit(entity)
			else:
				deselect_current_unit()
		else:
			deselect_current_unit()

# ==============================
# Seleccionar / deseleccionar
# ==============================
func select_unit(entity: Entity) -> void:
	if entity == null:
		return
	if selected_unit != null and selected_unit != entity:
		selected_unit.deselect()

	selected_unit = entity
	selected_unit.select()
	print("Unidad seleccionada:", entity.name)

	# Actualizar HUD
	if selected_unit.portrait and hud_portrait:
		hud_portrait.texture = selected_unit.portrait
	else:
		hud_portrait.texture = null

	if entity is Unit:
		var u := entity as Unit
		hud_attack.text = "Attack: " + str(u.attack_damage)
		hud_defense.text = "Defense: " + str(u.defense)
		hud_velocity.text = "Speed: " + str(u.move_speed)
		hud_health.max_value = u.max_health
		hud_health.value = u.current_health
		hud_energy.max_value = u.max_magic
		hud_energy.value = u.current_magic
		hud_name.text = u.unit_type

func deselect_current_unit() -> void:
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null

	if hud_portrait:
		hud_portrait.texture = null
	hud_attack.text = "Attack: -"
	hud_defense.text = "Defense: -"
	hud_velocity.text = "Speed: -"
	hud_health.max_value = 10000
	hud_health.value = 0
	hud_energy.max_value = 10000
	hud_energy.value = 0
	hud_name.text = ""

# ==============================
# Botón mover
# ==============================

func _on_move_button_pressed() -> void:
	if is_selecting_terrain:
		return  # Ya está en modo selección

	var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar SelectTerrain.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_terrain = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Usamos cursor visible
	print("Modo selección de terreno activado")

# ==============================
# Cursor de selección
# ==============================
func _process(delta: float) -> void:
	if is_selecting_terrain and select_cursor_instance:
		var mouse_pos = get_viewport().get_mouse_position()
		select_cursor_instance.position = mouse_pos

		var animated_sprite = select_cursor_instance.get_node("AnimatedSprite2D")
		if animated_sprite and not animated_sprite.is_playing():
			animated_sprite.play("default")

	# ----------- CURSOR DE CONSTRUCCIÓN
	if is_placing_building and build_placeholder:
		_update_build_placeholder_position()

func _update_build_placeholder_position() -> void:
	if not is_placing_building or build_placeholder == null:
		return

	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var plane_y := 0.0
	var t = (plane_y - from.y) / dir.y
	var target_pos = from + dir * t

	# ----------------------------
	# OFFSET PARA ELEVAR EL MODELO
	# ----------------------------
	var offset_y := 2
	build_placeholder.global_position = target_pos + Vector3(0, offset_y, 0)




# ==============================
# _ready: inicializar RTS
# ==============================
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
	update_team_hud() 
	moveButton.pressed.connect(_on_move_button_pressed)
	
var building_to_build: String = ""

func _start_build_mode(building_name: String) -> void:
	building_to_build = building_name
	
	var controller_scene = load("res://Scenes/Game/buildings/medievalBuild/medievalBuild_controller.tscn")
	if controller_scene == null:
		print("ERROR: no se pudo cargar medievalBuild_controller")
		return

	build_placeholder = controller_scene.instantiate()

	#notificarle al controller qué edificio va a ser
	if build_placeholder.has_method("set_building_type"):
		build_placeholder.set_building_type(building_name)

	# desactivar colisiones y lógica mientras es fantasma
	build_placeholder.collision_layer = 0
	build_placeholder.collision_mask = 0
	build_placeholder.set_physics_process(false)

	get_tree().current_scene.add_child(build_placeholder)

	is_placing_building = true
	print("Modo construcción activado para:", building_name)



func _on_player_hud_barracks_pressed() -> void:
	_start_build_mode("barracks")
	print("Barracks!")
	pass




func _on_player_hud_dragon_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_farm_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_harbor_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_magic_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_shrine_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_smithy_pressed() -> void:
	pass # Replace with function body.


func _on_player_hud_tower_pressed() -> void:
	pass # Replace with function body.
