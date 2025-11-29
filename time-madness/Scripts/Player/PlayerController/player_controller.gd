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

@onready var menu_hud: Control = $"PlayerHud"

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

# 🔥 Cursor de selección de objetivo (ATAQUE)
var is_selecting_objective: bool = false

# 🔥 NUEVAS VARIABLES PARA HABILIDADES
var is_selecting_ability_target: bool = false
var ability_source_unit: Unit = null
var ability_id_pending: String = ""

var is_placing_building: bool = false
var build_placeholder: Node3D = null

var is_battle_mode: bool = false

# Cámara para raycast
@onready var camera: Camera3D = $RtsController/Elevation/Camera3D

# 🔥 Iniciar selección de objetivo para habilidad
func _start_ability_target_selection(source_unit: Unit, ability_id: String) -> void:
	if source_unit == null:
		print("⚠️ source_unit es null")
		return
	
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	
	# Cargar cursor de selección
	var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar TargetObjetive.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_ability_target = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("🎯 Modo selección de objetivo para habilidad activado: %s" % ability_id)


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
	
	if camera == null:
		print("ERROR: No hay cámara asignada en PlayerController")
		return

	var mouse_pos = event.position

	# =====================================
	#     MODO DE COLOCAR EDIFICIO
	# =====================================
	if is_placing_building and build_placeholder:
		if not build_placeholder.is_valid_placement:
			print("❌ No se puede construir aquí: muy cerca de otro edificio")
			return
		
		print(">>> Edificio colocado en: ", build_placeholder.global_position)

		var final_build_selected = build_placeholder.get_build()
		if final_build_selected:
			final_build_selected.global_position = build_placeholder.global_position
			get_tree().current_scene.add_child(final_build_selected)
			await get_tree().process_frame
			add_building(final_build_selected)
		
		build_placeholder. queue_free()
		build_placeholder = null
		is_placing_building = false
		return
	# =====================================
	# 🔥 MODO DE SELECCIÓN DE TERRENO PARA HABILIDAD
	# =====================================
	if is_selecting_ability_terrain:
		print(">>> Entramos en MODO SELECCIÓN DE TERRENO PARA HABILIDAD")
		
		mouse_pos = get_viewport().get_mouse_position()
		
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		var plane_y = 0.0
		var target_pos: Vector3

		if dir.y == 0:
			target_pos = from
		else:
			var t = (plane_y - from.y) / dir.y
			target_pos = from + dir * t
		
		print("🎯 Terreno seleccionado para habilidad: %v" % target_pos)
		
		# 🔥 Verificar rango si está especificado
		if ability_terrain_max_range > 0 and ability_source_unit:
			var distance = ability_source_unit.global_position.distance_to(target_pos)
			if distance > ability_terrain_max_range:
				print("❌ Posición demasiado lejos (%.1f / %.1f)" % [distance, ability_terrain_max_range])
				# No ejecutar, solo limpiar
				is_selecting_ability_terrain = false
				ability_source_unit = null
				ability_id_pending = ""
				ability_terrain_max_range = 0.0
				
				if select_cursor_instance:
					select_cursor_instance.queue_free()
					select_cursor_instance = null
				
				return
		
		# Notificar a la unidad con la posición
		if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
			ability_source_unit.on_ability_target_selected(ability_id_pending, target_pos)
		
		# Limpiar estado
		is_selecting_ability_terrain = false
		ability_source_unit = null
		ability_id_pending = ""
		ability_terrain_max_range = 0.0
		
		if select_cursor_instance:
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		return
			# =====================================
	# 🔥 MODO DE SELECCIÓN DE OBJETIVO PARA HABILIDAD
	# =====================================
	if is_selecting_ability_target:
		print(">>> Entramos en MODO SELECCIÓN DE OBJETIVO PARA HABILIDAD")
		
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		params.collision_mask = 1 << 1  # Layer 2 -> Unidades

		var result = get_world_3d().direct_space_state.intersect_ray(params)
		
		if result and result.collider is Entity:
			var target_entity = result.collider as Entity
			
			# Verificar que NO sea nuestra unidad
			if target_entity. player_owner != self:
				print("🎯 OBJETIVO SELECCIONADO PARA HABILIDAD -> ", target_entity.name)
				
				# 🔥 Notificar a la unidad con el objetivo
				if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
					ability_source_unit.on_ability_target_selected(ability_id_pending, target_entity)
			else:
				print("⚠️ No puedes usar habilidades en tus propias unidades")
		else:
			print("❌ No se detectó ningún objetivo válido")
		
		# Limpiar estado
		is_selecting_ability_target = false
		ability_source_unit = null
		ability_id_pending = ""
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if select_cursor_instance:
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		return

	# =====================================
	# 🔥 MODO DE SELECCIÓN DE ALIADO PARA HABILIDAD
	# =====================================
	if is_selecting_ability_ally:
		print(">>> Entramos en MODO SELECCIÓN DE ALIADO PARA HABILIDAD")
		
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		params.collision_mask = 1 << 1  # Layer 2 -> Unidades

		var result = get_world_3d().direct_space_state.intersect_ray(params)
		
		if result and result.collider is Entity:
			var target_entity = result.collider as Entity
			
			# 🔥 Verificar que SEA nuestra unidad (aliado)
			if target_entity.player_owner == self:
				print("🎯 ALIADO SELECCIONADO -> ", target_entity.name)
				
				# Notificar a la unidad con el objetivo
				if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
					ability_source_unit.on_ability_target_selected(ability_id_pending, target_entity)
			else:
				print("⚠️ Solo puedes seleccionar aliados para esta habilidad")
		else:
			print("❌ No se detectó ningún aliado")
		
		# Limpiar estado
		is_selecting_ability_ally = false
		ability_source_unit = null
		ability_id_pending = ""
		
		if select_cursor_instance:
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		return
	# =====================================
	# 🔥 MODO DE SELECCIÓN DE OBJETIVO (ATAQUE)
	# =====================================
	if is_selecting_objective:
		print(">>> Entramos en MODO SELECCIÓN DE OBJETIVO")
		
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		# 🔥 Detectar UNIDADES ENEMIGAS (Layer 2)
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		params.collision_mask = 1 << 1  # Layer 2 -> Unidades

		var result = get_world_3d().direct_space_state.intersect_ray(params)
		
		if result and result.collider is Entity:
			var target_entity = result.collider as Entity
			
			# 🔥 Verificar que NO sea nuestra unidad
			if target_entity.player_owner != self:
				print("🎯 ENEMIGO DETECTADO -> ", target_entity.name)
				
				# 🔥 Ordenar ataque a la unidad seleccionada
				if selected_unit and selected_unit is Unit:
					var attacking_unit = selected_unit as Unit
					attacking_unit.attack_target(target_entity)
					print("⚔️ %s persiguiendo a %s" % [attacking_unit.name, target_entity.name])
			else:
				print("⚠️ No puedes atacar a tus propias unidades")
		else:
			print("❌ No se detectó ningún enemigo")
		
		# Limpiar cursor
		is_selecting_objective = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if select_cursor_instance:
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		return

	# =====================================
	# MODO DE SELECCIÓN DE TERRENO
	# =====================================
	if is_selecting_terrain:
		print(">>> Entramos en MODO SELECCIÓN DE TERRENO")
		
		mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		var plane_y = 0.0
		var target_pos: Vector3

		if dir.y == 0:
			target_pos = from
		else:
			var t = (plane_y - from.y) / dir.y
			target_pos = from + dir * t
		
		if selected_unit:
			selected_unit.move_to(target_pos)
			print("Moviendo unidad a:", target_pos)
		
		is_selecting_terrain = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if select_cursor_instance:
			select_cursor_instance.queue_free()
			select_cursor_instance = null
		
		return

	# =====================================
	# Modo selección de unidades Y EDIFICIOS
	# =====================================
	else:
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 2000

		# ESTRATEGIA 1: Intentar seleccionar UNIDADES (Layer 2)
		var params_units = PhysicsRayQueryParameters3D.new()
		params_units.from = from
		params_units.to = to
		params_units.collision_mask = 1 << 1

		var result_units = get_world_3d().direct_space_state.intersect_ray(params_units)
		
		if result_units and result_units.collider is Entity:
			var entity = result_units.collider as Entity
			if entity.player_owner == self:
				select_unit(entity)
			else:
				deselect_current_unit()
			return
		
		# ESTRATEGIA 2: Si no hay unidad, intentar seleccionar EDIFICIOS (Layer 4)
		var params_buildings = PhysicsRayQueryParameters3D.new()
		params_buildings.from = from
		params_buildings.to = to
		params_buildings. collision_mask = 1 << 3

		var result_buildings = get_world_3d().direct_space_state.intersect_ray(params_buildings)
		
		if result_buildings and result_buildings.collider is Building:
			var building = result_buildings.collider as Building
			if building in buildings:
				select_building(building)
			else:
				deselect_current_unit()
			return
		
		deselect_current_unit()

# ==============================
# Seleccionar / deseleccionar
# ==============================
func select_unit(entity: Entity) -> void:
	if entity == null:
		return

	# Si había otra unidad seleccionada, deseleccionarla
	if selected_unit != null and selected_unit != entity:
		selected_unit.deselect()

	# Limpia selección de edificio
	selected_building = null
	_clear_abilities()

	selected_unit = entity
	selected_unit.select()
	print("Unidad seleccionada:", entity.name)

	# Portrait
	if selected_unit.portrait and hud_portrait:
		hud_portrait.texture = selected_unit.portrait
	else:
		hud_portrait.texture = null

	# ===============================
	# 📌 Si es unidad, cargar HUD y habilidades
	# ===============================
	if entity is Unit:
		var u := entity as Unit

		# 📊 Estadísticas
		hud_attack.text = "Attack: " + str(u.attack_damage)
		hud_defense.text = "Defense: " + str(u.defense)
		hud_velocity.text = "Speed: " + str(u.move_speed)
		hud_health.max_value = u.max_health
		hud_health.value = u.current_health
		hud_energy.max_value = u.max_magic
		hud_energy.value = u.current_magic
		hud_name.text = u.unit_type

		# ===============================
		# 🔥 Cargar habilidades de UNIDAD
		# ===============================
		var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]

		# Limpiar botones antes
		for button in spell_buttons:
			if button:
				button.texture_normal = null
				button.visible = false
				button.disabled = true
				button.tooltip_text = ""

		# Verificar habilidades
		if u.abilities and u.abilities.size() > 0:
			for i in range(min(u.abilities.size(), spell_buttons.size())):
				var ability = u.abilities[i]
				var button = spell_buttons[i]

				if button and ability:
					var icon_texture = load(ability.icon)
					if icon_texture:
						button.texture_normal = icon_texture
						button.visible = true
						button.disabled = false
						button.tooltip_text = ability.name + "\n" + ability.description

						# Eliminar conexiones anteriores
						for connection in button.pressed.get_connections():
							button.pressed.disconnect(connection["callable"])

						# Conectar nueva habilidad
						button.pressed.connect(func():
							_on_unit_ability_pressed(u, ability))


func select_building(building: Building) -> void:
	if building == null:
		return
	
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null
	
	selected_building = building
	print("🏰 Edificio seleccionado:", building.name)
	
	var portrait_path = building.get_building_portrait()
	if portrait_path != "" and hud_portrait:
		var texture = load(portrait_path)
		if texture:
			hud_portrait.texture = texture
		else:
			hud_portrait.texture = null
	else:
		if hud_portrait:
			hud_portrait.texture = null
	
	var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]
	
	for button in spell_buttons:
		if button:
			button.texture_normal = null
			button.visible = false
			button.disabled = true
	
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
				
				for connection in button.pressed.get_connections():
					button.pressed.disconnect(connection["callable"])
				
				button.pressed.connect(func(): _on_ability_pressed(building, ability))
	
	hud_attack.text = "Attack: -"
	hud_defense. text = "Defense: -"
	hud_velocity.text = "Speed: -"
	hud_health.max_value = 10000
	hud_health.value = 0
	hud_energy.max_value = 10000
	hud_energy.value = 0
	hud_name. text = building.get_class()

func _on_unit_ability_pressed(unit: Unit, ability):
	print("🔥 Activando habilidad de unidad:", ability.name)

	if unit.has_method("use_ability"):
		unit.use_ability(ability)
	else:
		print("⚠️ La unidad no implementa use_ability()")


func _on_ability_pressed(building, ability):
	print("Ejecutando habilidad:", ability.name, " del edificio: ", building)

	if building.has_method("use_ability"):
		building.use_ability(ability)
	else:
		print("⚠️ El edificio no tiene el método use_ability()")

func deselect_current_unit() -> void:
	if selected_unit != null:
		selected_unit. deselect()
		selected_unit = null
	
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
		return

	var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar SelectTerrain.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_terrain = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Modo selección de terreno activado")

# ==============================
# 🔥 Botón atacar
# ==============================
func _on_attack_button_pressed() -> void:
	if is_selecting_objective:
		return

	if selected_unit == null or not selected_unit is Unit:
		print("⚠️ Debes seleccionar una unidad primero")
		return

	var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar TargetObjetive.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_objective = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("🎯 Modo selección de objetivo activado")

# ==============================
# Cursor de selección
# ==============================
func _process(delta: float) -> void:
	if not is_active_player: 
		return
	
	# 🔥 Cursor para todas las selecciones
	if (is_selecting_terrain or is_selecting_objective or is_selecting_ability_target or is_selecting_ability_terrain or is_selecting_ability_ally) and select_cursor_instance:
		var mouse_pos = get_viewport().get_mouse_position()
		select_cursor_instance.position = mouse_pos

		var animated_sprite = select_cursor_instance.get_node("AnimatedSprite2D")
		if animated_sprite and not animated_sprite.is_playing():
			animated_sprite.play("default")

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

	var offset_y := 2
	build_placeholder.global_position = target_pos + Vector3(0, offset_y, 0)

func _on_second_tick(time_left: int):
	hour. text = format_hms(time_left)
	var gold_generated := workers * 1    
	var resources_generated := workers * 0.5 
	
	gold += gold_generated
	resources += resources_generated
	
	_update_gold_label()
	_update_resources_label()

func _update_gold_label():
	goldLabel.text = str(gold)

func _update_resources_label():
	resourcesLabel.text = str(resources)

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
	GameStarter.connect("second_tick", _on_second_tick)
	add_building(castle_controller)
	var rts = $RtsController
	if is_active_player:
		rts. movement_speed = movement_speed
		rts.rotation_speed = rotation_speed
		rts.zoom_speed = zoom_speed
		rts.min_zoom = min_zoom
		rts.max_zoom = max_zoom
		rts.min_elevation_angle = min_elevation_angle
		rts.max_elevation_angle = max_elevation_angle
		rts.edge_margin = edge_margin
		rts. allow_rotation = allow_rotation
		rts.allow_zoom = allow_zoom
		rts.allow_pan = allow_pan
		rts.min_x = min_x
		rts.max_x = max_x
		rts.min_z = min_z
		rts.max_z = max_z
		camera. make_current() 
		moveButton.pressed.connect(_on_move_button_pressed)
		attackButton.pressed.connect(_on_attack_button_pressed)

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

func _on_player_hud_dragon_pressed() -> void:
	_start_build_mode("dragon")

func _on_player_hud_farm_pressed() -> void:
	_start_build_mode("farm")

func _on_player_hud_harbor_pressed() -> void:
	_start_build_mode("harbor")

func _on_player_hud_magic_pressed() -> void:
	_start_build_mode("magic")

func _on_player_hud_shrine_pressed() -> void:
	_start_build_mode("shrine")

func _on_player_hud_smithy_pressed() -> void:
	_start_build_mode("smithy")

func _on_player_hud_tower_pressed() -> void:
	_start_build_mode("tower")

func move_unit_to_attack(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	if unit in defense_units:
		defense_units.erase(unit)
	
	if unit not in attack_units:
		attack_units.append(unit)
	
	_update_units_labels()
	print("🗡️ Unidad movida a ATAQUE:", unit.name)

func move_unit_to_defense(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	if unit in attack_units:
		attack_units.erase(unit)
	
	if unit not in defense_units:
		defense_units.append(unit)
	
	_update_units_labels()
	print("🛡️ Unidad movida a DEFENSA:", unit. name)

func _update_units_labels() -> void:
	if attackUnits_label:
		attackUnits_label.text = "Attack units: " + str(attack_units.size())
	if defenseUnits_label:
		defenseUnits_label.text = "Defense units: " + str(defense_units.size())

func disable_node_3d_recursive(node: Node) -> void:
	if node == null:
		return

	if node is Node3D:
		node.visible = false

	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)

	if node is CollisionShape3D:
		node.disabled = true
	elif node is Area3D:
		node.monitoring = false

	for child in node.get_children():
		disable_node_3d_recursive(child)

func enable_node_3d_recursive(node: Node) -> void:
	if node == null:
		return

	if node is Node3D:
		node.visible = true

	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)

	if node is CollisionShape3D:
		node. disabled = false
	elif node is Area3D:
		node. monitoring = true

	for child in node.get_children():
		enable_node_3d_recursive(child)
		
		
		# ==============================
# 💀 Callback cuando una unidad muere
# ==============================
func _on_unit_died(unit: Entity) -> void:
	print("💀 Unidad muerta detectada: %s" % unit. name)
	
	# Remover de arrays
	if unit in units:
		units.erase(unit)
	if unit in attack_units:
		attack_units.erase(unit)
	if unit in defense_units:
		defense_units.erase(unit)
	
	# Actualizar HUD
	_update_units_labels()
	
	# Si era la unidad seleccionada, deseleccionar
	if selected_unit == unit:
		deselect_current_unit()
	
	print("📊 Unidades restantes: %d" % units.size())


# 🔥 Nueva variable
var is_selecting_ability_terrain: bool = false
var ability_terrain_max_range: float = 0.0

# 🔥 Nueva función para seleccionar terreno
func _start_ability_terrain_selection(source_unit: Unit, ability_id: String, max_range: float = 0.0) -> void:
	if source_unit == null:
		print("⚠️ source_unit es null")
		return
	
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	ability_terrain_max_range = max_range
	
	# Cargar cursor de selección de terreno
	var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar SelectTerrain.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_ability_terrain = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("🎯 Modo selección de terreno para habilidad activado: %s" % ability_id)
	
# 🔥 Nueva variable
var is_selecting_ability_ally: bool = false

# 🔥 Nueva función para seleccionar ALIADOS
func _start_ability_ally_selection(source_unit: Unit, ability_id: String) -> void:
	if source_unit == null:
		print("⚠️ source_unit es null")
		return
	
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	
	# Cargar cursor de selección
	var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
	if select_scene == null:
		print("ERROR: no se pudo cargar TargetObjetive.tscn")
		return

	select_cursor_instance = select_scene.instantiate()
	get_tree().current_scene.add_child(select_cursor_instance)

	is_selecting_ability_ally = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("🎯 Modo selección de aliado para habilidad activado: %s" % ability_id)
