extends Node3D
class_name PlayerController

# ==============================
# Nombre del jugador
# ==============================
@export var player_name: String = "Jugador"
@export var is_active_player: bool = true
@export var difficult_bot: bool = true
@export var faction: String = "default"

# ===== HUD =====================
@onready var hud_portrait: TextureRect = $"UnitHud/Portrait"
@onready var hud_attack: Label = $"UnitHud/Attack"
@onready var hud_defense: Label = $"UnitHud/Defense"
@onready var hud_velocity: Label = $"UnitHud/Velocity"
@onready var hud_health: TextureProgressBar = $"UnitHud/healthBar"
@onready var hud_energy: TextureProgressBar = $"UnitHud/energyBar"
@onready var hud_name: Label = $"UnitHud/UnitType"

@onready var attackButton: TextureButton = $"UnitHud/attackButton"
@onready var stopButton: TextureButton = $"UnitHud/stopButton"
@onready var keepPosButton: TextureButton = $"UnitHud/keepPosButton"
@onready var moveButton: TextureButton = $"UnitHud/moveButton"

@onready var spell1: TextureButton = $"UnitHud/spell1"
@onready var spell2: TextureButton = $"UnitHud/spell2"
@onready var spell3: TextureButton = $"UnitHud/spell3"
@onready var spell4: TextureButton = $"UnitHud/spell4"
@onready var spell5: TextureButton = $"UnitHud/spell5"
@onready var spell6: TextureButton = $"UnitHud/spell6"
@onready var spell7: TextureButton = $"UnitHud/spell7"


# ===== TeamHUD =====================
@onready var upKeepLabel: Label = $"TeamHud/maintenance"
@onready var resourcesLabel: Label = $"TeamHud/prime"
@onready var goldLabel: Label = $"TeamHud/money"
@onready var hour: Label = $"TeamHud/hour"


@onready var menu_hud: Control = $"PlayerHud";

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

# ===== Unidades y Edificios =====
var units: Array = []
var buildings: Array = []  
var selected_unit: Entity = null
var selected_building: Building = null 
var attack_units: Array = []
var defense_units: Array = []

# Cursor de selección de terreno
var select_cursor_instance: Node2D = null
var is_selecting_terrain: bool = false

var is_placing_building: bool = false
var build_placeholder: Node3D = null

var is_battle_mode: bool = false



# Cámara para raycast
@onready var camera: Camera3D = $RtsController/Elevation/Camera3D

func format_hms(seconds: int) -> String:
	var m = (seconds % 3600) / 60
	var s = seconds % 60

	return "%02d:%02d" % [m, s]


# ==============================
# Añadir unidades
# ==============================
func add_unit(unit: Entity) -> void:
	if unit == null:
		return
	if unit not in units:
		units.append(unit)
		unit.player_owner = self
		if unit not in defense_units:
			defense_units.append(unit)
		
		_update_units_labels()
		print("Unidad agregada a ", player_name, ": ", unit.name)

# ==============================
# 🔥 NUEVO: Añadir edificios
# ==============================
func add_building(building: CharacterBody3D) -> void:
	if building == null:
		return
	if building not in buildings:
		buildings.append(building)
		building.player_owner = self 
		print("✅ Edificio agregado a ", player_name, ": ", building.name)
		print("   Total de edificios: ", buildings.size())
		
		
		
func update_team_hud() -> void:
	if upKeepLabel:
		upKeepLabel.text = str(upkeep) + " / " + str(maxUpKeep)
	if resourcesLabel:
		resourcesLabel.text = str(resources)
	if goldLabel:
		goldLabel.text = str(gold)



# ==============================
# Manejo de input (clicks)
# ==============================
func _unhandled_input(event):
	if not is_active_player: 
		return 
	
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	print("CLICK!!!!")
	
	if camera == null:
		print("ERROR: No hay cámara asignada en PlayerController")
		return

	var mouse_pos = event.position
# =====================================
#     MODO DE COLOCAR EDIFICIO
# =====================================
	if is_placing_building and build_placeholder:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not build_placeholder.is_valid_placement:
				print("❌ No se puede construir aquí: muy cerca de otro edificio")
				return
			
			print(">>> Edificio colocado en: ", build_placeholder.global_position)

			# Crear edificio real
			var final_build_selected = build_placeholder.get_build()
			if final_build_selected:
				final_build_selected.global_position = build_placeholder.global_position
				
				# ✅ AGREGAR PRIMERO AL ÁRBOL
				get_tree().current_scene.add_child(final_build_selected)
				
				# ✅ LUEGO CONFIGURAR (esperar un frame si es necesario)
				await get_tree().process_frame
			if final_build_selected:
						final_build_selected.global_position = build_placeholder.global_position
						
						get_tree().current_scene.add_child(final_build_selected)
						
						await get_tree().process_frame
						
						# 🔥 YA NO NECESITAS CONFIGURAR AQUÍ
						# Building._setup_building() ya lo hace automáticamente
						
						# Solo agregar al array
						add_building(final_build_selected)
			
			# Quitar placeholder
			build_placeholder.queue_free()
			build_placeholder = null
			is_placing_building = false

			return
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
		# 🔥 Modo selección de unidades Y EDIFICIOS
		# ------------------------------
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		# 🔥 ESTRATEGIA 1: Intentar seleccionar UNIDADES (Layer 2)
		var params_units = PhysicsRayQueryParameters3D.new()
		params_units.from = from
		params_units.to = to
		params_units.collision_mask = 1 << 1  # Layer 2 -> Unidades

		var result_units = get_world_3d().direct_space_state.intersect_ray(params_units)
		
		if result_units and result_units.collider is Entity:
			var entity = result_units.collider as Entity
			if entity.player_owner == self:
				select_unit(entity)
			else:
				deselect_current_unit()
			return  # Encontró una unidad, terminar aquí
		
		# 🔥 ESTRATEGIA 2: Si no hay unidad, intentar seleccionar EDIFICIOS (Layer 4)
		var params_buildings = PhysicsRayQueryParameters3D.new()
		params_buildings.from = from
		params_buildings.to = to
		params_buildings.collision_mask = 1 << 3  # Layer 4 -> Edificios

		var result_buildings = get_world_3d().direct_space_state.intersect_ray(params_buildings)
		
		if result_buildings and result_buildings.collider is Building:
			var building = result_buildings.collider as Building
			# Verificar si es nuestro edificio
			if building in buildings:
				select_building(building)  # 🔥 NUEVA FUNCIÓN
			else:
				deselect_current_unit()
			return
		
		# Si no encontró ni unidad ni edificio, deseleccionar
		deselect_current_unit()
	
# ==============================
# Seleccionar / deseleccionar
# ==============================
func select_unit(entity: Entity) -> void:
	if entity == null:
		return
	if selected_unit != null and selected_unit != entity:
		selected_unit.deselect()

	# Deseleccionar edificio si había uno
	selected_building = null
	_clear_abilities()
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

func select_building(building: Building) -> void:
	if building == null:
		return
	
	# Deseleccionar unidad si había una
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null
	
	selected_building = building
	print("🏰 Edificio seleccionado:", building.name)
	
	# Cargar retrato del edificio
	var portrait_path = building.get_building_portrait()
	if portrait_path != "" and hud_portrait:
		var texture = load(portrait_path)
		if texture:
			hud_portrait.texture = texture
			print("✅ Retrato cargado:", portrait_path)
		else:
			print("❌ No se pudo cargar el retrato:", portrait_path)
			hud_portrait.texture = null
	else:
		if hud_portrait:
			hud_portrait.texture = null
	
	# 🔥 Cargar iconos de habilidades en los botones
	var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]
	
	# Limpiar todos los botones primero
	for button in spell_buttons:
		if button:
			button.texture_normal = null
			button.visible = false
			button.disabled = true
	
	# Cargar las habilidades del edificio
	var abilities = building.abilities
	for i in range(min(abilities.size(), spell_buttons.size())):
		var ability = abilities[i]
		var button = spell_buttons[i]
		
		if button and ability:
			var icon_texture = load(ability.icon)
			if icon_texture:
				button.texture_normal = icon_texture
				button.visible = true
				button.disabled = false
				button.tooltip_text = ability.name + "\n" + ability.description
				print("✅ Habilidad cargada: ", ability.name)
				# 🔥 Conectar el botón a una función del HUD
				# 🔥 Desconectar señales previas
				for connection in button.pressed.get_connections():
					button.pressed.disconnect(connection["callable"])
				
				# 🔥 Conectar con lambda
				button.pressed.connect(func(): _on_ability_pressed(building, ability))

			else:
				print("❌ No se pudo cargar el icono: ", ability.icon)
	
	# Limpiar el resto del HUD (opcional, por ahora)
	hud_attack.text = "Attack: -"
	hud_defense.text = "Defense: -"
	hud_velocity.text = "Speed: -"
	hud_health.max_value = 10000
	hud_health.value = 0
	hud_energy.max_value = 10000
	hud_energy.value = 0
	hud_name.text = building.get_class()  # Nombre del edificio

func _on_ability_pressed(building, ability):
	print("Ejecutando habilidad:", ability.name, " del edificio: ", building)

	if building.has_method("use_ability"):
		building.use_ability(ability)
	else:
		print("⚠️ El edificio no tiene el método use_ability()")

func deselect_current_unit() -> void:
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null
	
	# También deseleccionar edificio
	selected_building = null
	_clear_abilities()
	
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


func _clear_abilities() -> void:
	var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]
	
	for button in spell_buttons:
		if button:
			button.texture_normal = null
			button.visible = false
			button.disabled = true
			button.tooltip_text = ""


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
	if not is_active_player: 
		return
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


func _on_second_tick(time_left: int):
	hour.text = format_hms(time_left)
	# Producción por trabajador
	var gold_generated := workers * 1    
	var resources_generated := workers * 0.5 
	
	# Sumar al jugador
	gold += gold_generated
	resources += resources_generated
	
	# Actualizar HUD
	_update_gold_label()
	_update_resources_label()
	
	# Solo para debug
	print("⏱ Tick: +" + str(gold_generated) + " oro, +" + str(resources_generated) + " recursos")

func _update_gold_label():
	goldLabel.text = str(gold)

func _update_resources_label():
	resourcesLabel.text = str(resources)



# ==============================
# _ready: inicializar RTS
# ==============================
@onready var castle_controller = $BaseMap/MedievalCastleController
var workers: int = 0
@onready var workers_label = $InfoHud/workers   
@onready var attackUnits_label = $InfoHud/unitsAttack   
@onready var defenseUnits_label = $InfoHud/unitsDefense   



func add_worker():
	workers += 1
	_update_workers_label()
	
func _update_workers_label():
	workers_label.text = "Workers: " + str(workers)
	


func _ready() -> void:
	# Conectar señal del GameManager
	GameStarter.connect("second_tick", _on_second_tick)
	add_building(castle_controller)
	var rts = $RtsController
	if is_active_player:
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
		camera.make_current() 
		moveButton.pressed.connect(_on_move_button_pressed)
		update_team_hud() 
		_update_units_labels()
		_update_workers_label()
	else:
		camera.current = false
		rts.set_process(false)

	disable_node_3d_recursive($BaseMap)
var building_to_build: String = ""

func _start_build_mode(building_name: String) -> void:
	building_to_build = building_name
	
	var controller_scene = load("res://Scenes/Game/buildings/medievalBuild/medievalBuild_controller.tscn")
	if controller_scene == null:
		return

	build_placeholder = controller_scene.instantiate()
	build_placeholder.set_physics_process(false)

	get_tree().current_scene.add_child(build_placeholder)
	
	await get_tree().process_frame
	
	if build_placeholder.has_method("set_building_type"):
		build_placeholder.set_building_type(building_name)

	is_placing_building = true

















func _on_player_hud_barracks_pressed() -> void:
	_start_build_mode("barracks")
	pass


func _on_player_hud_dragon_pressed() -> void:
	_start_build_mode("dragon")
	pass


func _on_player_hud_farm_pressed() -> void:
	_start_build_mode("farm")
	pass

func _on_player_hud_harbor_pressed() -> void:
	_start_build_mode("harbor")
	pass


func _on_player_hud_magic_pressed() -> void:
	_start_build_mode("magic")
	pass


func _on_player_hud_shrine_pressed() -> void:
	_start_build_mode("shrine")
	pass


func _on_player_hud_smithy_pressed() -> void:
	_start_build_mode("smithy")
	pass 


func _on_player_hud_tower_pressed() -> void:
	_start_build_mode("tower")
	pass
	

func move_unit_to_attack(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	# Remover de defensa si está ahí
	if unit in defense_units:
		defense_units. erase(unit)
	
	# Agregar a ataque si no está
	if unit not in attack_units:
		attack_units.append(unit)
	
	_update_units_labels()
	print("🗡️ Unidad movida a ATAQUE:", unit.name)

func move_unit_to_defense(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	# Remover de ataque si está ahí
	if unit in attack_units:
		attack_units.erase(unit)
	
	# Agregar a defensa si no está
	if unit not in defense_units:
		defense_units.append(unit)
	
	_update_units_labels()
	print("🛡️ Unidad movida a DEFENSA:", unit.name)

func _update_units_labels() -> void:
	if attackUnits_label:
		attackUnits_label.text = "Attack units: " + str(attack_units. size())
	if defenseUnits_label:
		defenseUnits_label.text = "Defense units: " + str(defense_units.size())
		
		
func disable_node_3d_recursive(node: Node) -> void:
	if node == null:
		return

	# =========================
	# Nodo 3D: no renderizar
	# =========================
	if node is Node3D:
		node.visible = false

	# =========================
	# Detener procesos
	# =========================
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)

	# =========================
	# Desactivar colisiones / áreas
	# =========================
	if node is CollisionShape3D:
		node.disabled = true
	elif node is Area3D:
		node.monitoring = false

	# =========================
	# Recursión sobre hijos
	# =========================
	for child in node.get_children():
		disable_node_3d_recursive(child)


func enable_node_3d_recursive(node: Node) -> void:
	if node == null:
		return

	# =========================
	# Nodo 3D: visible
	# =========================
	if node is Node3D:
		node.visible = true

	# =========================
	# Reactivar procesos
	# =========================
	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)

	# =========================
	# Reactivar colisiones / áreas
	# =========================
	if node is CollisionShape3D:
		node.disabled = false
	elif node is Area3D:
		node.monitoring = true

	# =========================
	# Recursión sobre hijos
	# =========================
	for child in node.get_children():
		enable_node_3d_recursive(child)
