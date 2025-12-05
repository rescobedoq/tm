extends Node3D
class_name PlayerController

# ==============================
# 🎮 COMANDOS (COMMAND PATTERN)
# ==============================

class MoveCommand extends UnitCommand:
	var controller: PlayerController
	
	func _init(p_controller: PlayerController):
		controller = p_controller
	
	func execute() -> void:
		if controller.selected_units.is_empty():
			return
		if controller.is_selecting_terrain:
			return
		
		controller._cleanup_cursor_only()
		controller._cancel_all_selection_modes()
		
		var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
		if not select_scene:
			return
		
		controller._spawn_cursor(select_scene)
		controller.is_selecting_terrain = true
		print("🔄 [MoveCommand] Modo movimiento activado (%d unidades)" % controller.selected_units.size())

class AttackCommand extends UnitCommand:
	var controller: PlayerController
	
	func _init(p_controller: PlayerController):
		controller = p_controller
	
	func execute() -> void:
		if controller.selected_units.is_empty():
			return
		if controller.is_selecting_objective:
			return
		
		controller._cleanup_cursor_only()
		controller._cancel_all_selection_modes()
		
		var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
		if not select_scene:
			return
		
		controller._spawn_cursor(select_scene)
		controller.is_selecting_objective = true
		print("⚔️ [AttackCommand] Modo ataque activado (%d unidades)" % controller. selected_units.size())

class StopCommand extends UnitCommand:
	var controller: PlayerController
	
	func _init(p_controller: PlayerController):
		controller = p_controller
	
	func execute() -> void:
		if controller.selected_units. is_empty():
			return
		
		for unit in controller.selected_units:
			if is_instance_valid(unit) and unit.is_alive:
				unit.stop()
		
		print("🛑 [StopCommand] %d unidades detenidas" % controller.selected_units.size())

class PatrolCommand extends UnitCommand:
	var controller: PlayerController
	
	func _init(p_controller: PlayerController):
		controller = p_controller
	
	func execute() -> void:
		if controller.selected_units.is_empty():
			return
		if controller.is_selecting_patrol_target:
			return
		
		controller._cleanup_cursor_only()
		controller._cancel_all_selection_modes()
		
		var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
		if not select_scene:
			return
		
		controller._spawn_cursor(select_scene)
		controller.is_selecting_patrol_target = true
		print("🔄 [PatrolCommand] Patrulla activada (%d unidades)" % controller.selected_units.size())

# ==============================
# 🎮 CONFIGURACIÓN DEL JUGADOR
# ==============================
@export var player_name: String = "Jugador"
@export var player_index: int = 0
@export var is_active_player: bool = true
@export var difficult_bot: bool = true
@export var faction: String = "default"

# ==============================
# 💰 RECURSOS
# ==============================
@export var gold: int = 500
@export var resources: int = 500
@export var upkeep: int = 0
@export var maxUpKeep: int = 10
var workers: int = 0

# ==============================
# 🎯 SELECCIÓN MÚLTIPLE
# ==============================
var selected_units: Array[Unit] = []
var is_box_selecting: bool = false
var selection_box: SelectionBox = null
var box_selection_start: Vector2 = Vector2. ZERO
var is_dragging_selection: bool = false
const MIN_DRAG_DISTANCE: float = 100

# ==============================
# ❤️ SISTEMA DE VIDAS (BATTLE)
# ==============================
var max_lives: int = 6
var current_lives: int = 6
var is_defeated: bool = false
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
const INVULNERABILITY_DURATION: float = 2.0
var battle_life_bar = null

# ==============================
# ⌨️ SISTEMA DE COMANDOS
# ==============================
var command_invoker: UnitCommandInvoker = UnitCommandInvoker.new()

# ==============================
# 🎯 UNIDADES Y EDIFICIOS
# ==============================
var units: Array[Entity] = []
var buildings: Array[Building] = []
var attack_units: Array[Entity] = []
var defense_units: Array[Entity] = []
var battle_units: Array[Entity] = []
var selected_unit: Entity = null
var selected_building: Building = null

# ==============================
# 🎬 MODOS Y ESTADOS
# ==============================
var is_battle_mode: bool = false
var is_placing_building: bool = false
var is_selecting_terrain: bool = false
var is_selecting_objective: bool = false
var is_selecting_ability_target: bool = false
var is_selecting_ability_terrain: bool = false
var is_selecting_ability_ally: bool = false
var is_selecting_patrol_target: bool = false

# ==============================
# 🖱️ CURSORES Y SELECCIÓN
# ==============================
var select_cursor_instance: Node2D = null
var build_placeholder: Node3D = null
var building_to_build: String = ""
var ability_source_unit: Unit = null
var ability_id_pending: String = ""
var ability_terrain_max_range: float = 0.0

# ==============================
# 🎥 CONFIGURACIÓN DE CÁMARA
# ==============================
@export_range(0, 1000) var movement_speed: float = 256
@export_range(0, 1000) var rotation_speed: float = 5
@export_range(0, 1000, 0.1) var zoom_speed: float = 50
@export_range(0, 1000) var min_zoom: float = 8
@export_range(0, 1000) var max_zoom: float = 512
@export_range(0, 90) var min_elevation_angle: float = 0
@export_range(0, 90) var max_elevation_angle: float = 360
@export var edge_margin: float = 50
@export var allow_rotation: bool = true
@export var allow_zoom: bool = true
@export var allow_pan: bool = true
@export var min_x: float = -1000
@export var max_x: float = 5000
@export var min_z: float = -5000
@export var max_z: float = 1000

# ==============================
# 🎥 ESTADO DE CÁMARA
# ==============================
var saved_camera_position: Vector3 = Vector3.ZERO
var saved_camera_zoom: float = 50.0
var saved_camera_rotation: float = 0.0

# ==============================
# 🖼️ REFERENCIAS UI
# ==============================
@onready var camera: Camera3D = $RtsController/Elevation/Camera3D
@onready var hud_portrait: TextureRect = $UnitHud/Portrait
@onready var hud_attack: Label = $UnitHud/Attack
@onready var hud_defense: Label = $UnitHud/Defense
@onready var hud_velocity: Label = $UnitHud/Velocity
@onready var hud_health: TextureProgressBar = $UnitHud/healthBar
@onready var hud_energy: TextureProgressBar = $UnitHud/energyBar
@onready var hud_name: Label = $UnitHud/UnitType
@onready var attackButton: TextureButton = $UnitHud/attackButton
@onready var stopButton: TextureButton = $UnitHud/stopButton
@onready var keepPosButton: TextureButton = $UnitHud/keepPosButton
@onready var moveButton: TextureButton = $UnitHud/moveButton
@onready var spell1: TextureButton = $UnitHud/spell1
@onready var spell2: TextureButton = $UnitHud/spell2
@onready var spell3: TextureButton = $UnitHud/spell3
@onready var spell4: TextureButton = $UnitHud/spell4
@onready var spell5: TextureButton = $UnitHud/spell5
@onready var spell6: TextureButton = $UnitHud/spell6
@onready var spell7: TextureButton = $UnitHud/spell7
@onready var upKeepLabel: Label = $TeamHud/maintenance
@onready var resourcesLabel: Label = $TeamHud/prime
@onready var goldLabel: Label = $TeamHud/money
@onready var hour: Label = $TeamHud/hour
@onready var menu_hud: Control = $PlayerHud
@onready var workers_label: Label = $InfoHud/workers
@onready var attackUnits_label: Label = $InfoHud/unitsAttack
@onready var defenseUnits_label: Label = $InfoHud/unitsDefense

signal resource_not
signal energy_not

var lose_screen_instance: Control = null
var win_screen_instance: Control = null

# ==============================
# 🔄 INICIALIZACIÓN
# ==============================
func _ready() -> void:
	_hide_all_ui()
	_setup_signals()
	_setup_camera()
	if menu_hud and menu_hud.has_signal("resource_not"):
		resource_not.connect(menu_hud._show_resource_not)
	_setup_input_actions()
	_create_selection_box()

func _create_selection_box() -> void:
	selection_box = SelectionBox.new()
	selection_box.name = "SelectionBox"
	selection_box.set_anchors_preset(Control. PRESET_FULL_RECT)
	selection_box.visible = false
	selection_box. mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_box.z_index = 100
	add_child(selection_box)

func _setup_input_actions() -> void:
	_ensure_input_action("unit_move", KEY_Z)
	_ensure_input_action("unit_attack", KEY_X)
	_ensure_input_action("unit_stop", KEY_C)
	_ensure_input_action("unit_patrol", KEY_V)

func _ensure_input_action(action_name: String, key: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		var event = InputEventKey.new()
		event. keycode = key
		InputMap.action_add_event(action_name, event)
		print("✅ Hotkey creada: %s = %s" % [action_name, OS.get_keycode_string(key)])

func _setup_signals() -> void:
	GameStarter.battle_mode_started.connect(_on_battle_mode_started)
	GameStarter.battle_mode_ended.connect(_on_battle_mode_ended)
	GameStarter.second_tick.connect(_on_second_tick)

func _setup_camera() -> void:
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
		_connect_ui_buttons()
		update_team_hud()
		_update_units_labels()
		_update_workers_label()
	else:
		camera.current = false
		rts.set_process(false)
		rts.set_physics_process(false)
		rts.set_process_input(false)
		rts.set_process_unhandled_input(false)
		rts.visible = false

# ==============================
# 🔄 PROCESS
# ==============================
func _process(delta: float) -> void:
	if is_defeated:
		return
	
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0:
			is_invulnerable = false
			invulnerability_timer = 0
	
	if not is_active_player:
		return
	
	_update_cursor_position()
	_update_build_placeholder_position()

func _update_cursor_position() -> void:
	if (is_selecting_terrain or is_selecting_objective or is_selecting_ability_target or 
		is_selecting_ability_terrain or is_selecting_ability_ally or is_selecting_patrol_target) and select_cursor_instance:
		var mouse_pos = get_viewport(). get_mouse_position()
		select_cursor_instance.position = mouse_pos
		var animated_sprite = select_cursor_instance.get_node("AnimatedSprite2D")
		if animated_sprite and not animated_sprite.is_playing():
			animated_sprite.play("default")

func _update_build_placeholder_position() -> void:
	if not is_placing_building or build_placeholder == null:
		return
	var mouse_pos = get_viewport(). get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var plane_y := 0.0
	var t = (plane_y - from.y) / dir.y
	var target_pos = from + dir * t
	build_placeholder.global_position = target_pos + Vector3(0, 2, 0)

# ==============================
# ⌨️ INPUT DE HOTKEYS
# ==============================
func _input(event: InputEvent) -> void:
	if is_defeated or not is_active_player:
		return
	
	if event is InputEventKey:
		if not event.is_pressed() or event.is_echo():
			return
		
		if event.is_action_pressed("unit_move"):
			var cmd = MoveCommand.new(self)
			command_invoker.execute_command(cmd)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("unit_attack"):
			var cmd = AttackCommand.new(self)
			command_invoker. execute_command(cmd)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("unit_stop"):
			var cmd = StopCommand.new(self)
			command_invoker.execute_command(cmd)
			get_viewport().set_input_as_handled()
		elif event. is_action_pressed("unit_patrol"):
			var cmd = PatrolCommand.new(self)
			command_invoker.execute_command(cmd)
			get_viewport().set_input_as_handled()

# ==============================
# 🖱️ INPUT HANDLING
# ==============================
func _unhandled_input(event):
	if is_defeated or not is_active_player:
		return
	
	if camera == null:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_left_click_pressed(event.position)
		else:
			_handle_left_click_released(event.position)
		return
	
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event.position)
		return
func _handle_left_click_pressed(mouse_pos: Vector2) -> void:
	# Procesar según el modo activo
	if is_placing_building:
		_handle_building_placement()
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_ability_terrain:
		_handle_ability_terrain_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_ability_target:
		_handle_ability_target_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_ability_ally:
		_handle_ability_ally_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_objective:
		_handle_attack_target_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_patrol_target:
		_handle_patrol_target_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	elif is_selecting_terrain:
		_handle_terrain_movement_selection(mouse_pos)
		return  # 🔥 AGREGAR RETURN
	else:
		# Solo iniciar selección de caja si estamos en modo libre
		box_selection_start = mouse_pos
		is_dragging_selection = false

func _handle_left_click_released(mouse_pos: Vector2) -> void:
	# 🔥 SI ESTAMOS EN MODO ACCIÓN, LIMPIAR Y SALIR
	if is_selecting_terrain or is_selecting_objective or is_selecting_patrol_target:
		is_selecting_terrain = false
		is_selecting_objective = false
		is_selecting_patrol_target = false
		return  # 🔥 SALIR SIN EJECUTAR _handle_entity_selection()
	
	if is_box_selecting and selection_box:
		var selection_rect = selection_box. end_selection()
		is_box_selecting = false
		_select_units_in_box(selection_rect)
		return
	
	if not is_dragging_selection and _is_in_free_selection_mode():
		_handle_entity_selection(mouse_pos)
func _handle_mouse_motion(mouse_pos: Vector2) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _is_in_free_selection_mode():
		var drag_distance = box_selection_start.distance_to(mouse_pos)
		
		if drag_distance > MIN_DRAG_DISTANCE:
			is_dragging_selection = true
			
			if not is_box_selecting:
				is_box_selecting = true
				selection_box.start_selection(box_selection_start)
			
			selection_box.update_selection(mouse_pos)

func _is_in_free_selection_mode() -> bool:
	return not (is_placing_building or is_selecting_terrain or is_selecting_objective or
				is_selecting_patrol_target or is_selecting_ability_terrain or
				is_selecting_ability_target or is_selecting_ability_ally)

func _handle_building_placement() -> void:
	if not build_placeholder. is_valid_placement:
		return
	
	var final_build = build_placeholder.get_build()
	if not final_build:
		return
	
	final_build.global_position = build_placeholder.global_position
	_scale_building(final_build, build_placeholder.building_type)
	
	var parent_node = get_battle_map() if is_battle_mode else get_base_map()
	if parent_node == null:
		return
	parent_node.add_child(final_build)
	await get_tree().process_frame
	add_building(final_build)
	
	if final_build.building_type == "farm":
		maxUpKeep += 5
	
	var cost = BuildingCosts.get_cost(final_build.building_type)
	if cost and cost. size() > 0:
		gold -= cost.gold
		resources -= cost.resources
		update_team_hud()
	
	build_placeholder. queue_free()
	build_placeholder = null
	is_placing_building = false

func _scale_building(building: Node3D, type: String) -> void:
	var scales = {
		"barracks": Vector3(30, 30, 30),
		"dragon": Vector3(25, 25, 25),
		"farm": Vector3(15, 15, 15),
		"harbor": Vector3(20, 20, 20),
		"magic": Vector3(25, 25, 25),
		"shrine": Vector3(22, 22, 22),
		"smithy": Vector3(18, 18, 18),
		"tower": Vector3(25, 25, 25)
	}
	building.scale = scales.get(type, Vector3(10, 10, 10))

func _handle_ability_terrain_selection(mouse_pos: Vector2) -> void:
	var target_pos = _get_terrain_position(mouse_pos)
	
	if ability_terrain_max_range > 0 and ability_source_unit:
		var distance = ability_source_unit.global_position.distance_to(target_pos)
		if distance > ability_terrain_max_range:
			_cleanup_ability_selection()
			return
	
	if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
		ability_source_unit.on_ability_target_selected(ability_id_pending, target_pos)
	
	_cleanup_ability_selection()

func _handle_ability_target_selection(mouse_pos: Vector2) -> void:
	var result = _raycast_entities(mouse_pos, true)
	
	if result and result.collider is Entity:
		var target = result.collider as Entity
		if target.player_owner != self:
			if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
				ability_source_unit.on_ability_target_selected(ability_id_pending, target)
	
	_cleanup_ability_selection()

func _handle_ability_ally_selection(mouse_pos: Vector2) -> void:
	var result = _raycast_entities(mouse_pos, false)
	
	if result and result.collider is Entity:
		var target = result.collider as Entity
		if target.player_owner == self:
			if ability_source_unit and ability_source_unit.has_method("on_ability_target_selected"):
				ability_source_unit.on_ability_target_selected(ability_id_pending, target)
	
	_cleanup_ability_selection()

func _handle_attack_target_selection(mouse_pos: Vector2) -> void:
	var result = _raycast_entities(mouse_pos, true)
	
	if result and result.collider is Entity:
		var target = result.collider as Entity
		if target.player_owner != self:
			for unit in selected_units:
				if is_instance_valid(unit) and unit. is_alive:
					unit.attack_target(target)
			print("⚔️ %d unidades atacando a %s" % [selected_units.size(), target.name])
	
	is_selecting_objective = false
	_cleanup_cursor_only()

func _handle_terrain_movement_selection(mouse_pos: Vector2) -> void:
	var target_pos = _get_terrain_position(mouse_pos)
	
	for unit in selected_units:
		if is_instance_valid(unit) and unit.is_alive:
			unit.move_to(target_pos)
	
	print("📍 Moviendo %d unidades a: %v" % [selected_units.size(), target_pos])
	
	_cleanup_cursor_only()

func _handle_patrol_target_selection(mouse_pos: Vector2) -> void:
	var target_pos = _get_terrain_position(mouse_pos)
	
	for unit in selected_units:
		if is_instance_valid(unit) and unit.is_alive:
			unit.start_patrol(target_pos)
	
	print("🔄 %d unidades patrullando hacia: %v" % [selected_units.size(), target_pos])
	
	is_selecting_patrol_target = false
	_cleanup_cursor_only()

func _handle_entity_selection(mouse_pos: Vector2) -> void:
	var result_unit = _raycast_entities(mouse_pos, false)
	if result_unit and result_unit. collider is Entity:
		var entity = result_unit.collider as Entity
		if entity.player_owner == self:
			select_unit(entity)
			return
	
	if not is_battle_mode:
		var result_building = _raycast_entities(mouse_pos, false)
		if result_building and result_building.collider is Building:
			var building = result_building.collider as Building
			if building in buildings:
				select_building(building)
				return
	
	deselect_current_unit()

# ==============================
# 🎯 UTILIDADES DE RAYCAST
# ==============================
func _raycast_entities(mouse_pos: Vector2, detect_enemies: bool) -> Dictionary:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 2000
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	
	if selected_unit:
		params.exclude = [selected_unit. get_rid()]
	
	if is_battle_mode:
		params.collision_mask = 1 << 8
	else:
		if detect_enemies:
			var enemy_mask = 0
			for i in range(6):
				if i != player_index:
					enemy_mask |= 1 << (2 + i)
			params.collision_mask = enemy_mask
		else:
			params.collision_mask = 1 << (2 + player_index)
	
	return get_world_3d().direct_space_state.intersect_ray(params)

func _get_terrain_position(mouse_pos: Vector2) -> Vector3:
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var plane_y = 0.0
	if dir.y == 0:
		return from
	var t = (plane_y - from.y) / dir.y
	return from + dir * t

# ==============================
# 🎯 SELECCIÓN DE UNIDADES
# ==============================
func select_unit(entity: Entity) -> void:
	if entity == null:
		return
		
	_deselect_all_units()
	
	if selected_unit != null and selected_unit != entity:
		selected_unit.deselect()
		_disconnect_unit_signals(selected_unit)
	
	selected_building = null
	_clear_abilities()
	selected_unit = entity
	
	if selected_unit is Unit:
		var u = selected_unit as Unit
		u.connect("health_changed", Callable(self, "_on_unit_health_changed"))
		u.connect("energy_changed", Callable(self, "_on_unit_energy_changed"))
		selected_units.clear()
		selected_units.append(u)
	
	selected_unit.select()
	_update_unit_hud(entity)

func _on_unit_health_changed(current_health: float, max_health: float) -> void:
	if hud_health:
		hud_health.max_value = max_health
		hud_health.value = current_health

func _on_unit_energy_changed(current_magic: float, max_magic: float) -> void:
	if hud_energy:
		hud_energy. max_value = max_magic
		hud_energy.value = current_magic

func _disconnect_unit_signals(unit: Unit) -> void:
	var health_callable = Callable(self, "_on_unit_health_changed")
	if unit.is_connected("health_changed", health_callable):
		unit.disconnect("health_changed", health_callable)
	
	var energy_callable = Callable(self, "_on_unit_energy_changed")
	if unit.is_connected("energy_changed", energy_callable):
		unit.disconnect("energy_changed", energy_callable)

func _update_unit_hud(entity: Entity) -> void:
	if entity.portrait and hud_portrait:
		hud_portrait.texture = entity.portrait
	else:
		hud_portrait. texture = null
	
	if entity is Unit:
		var u = entity as Unit
		hud_attack.text = "Attack: " + str(u.attack_damage)
		hud_defense. text = "Defense: " + str(u.defense)
		hud_velocity.text = "Speed: " + str(u.move_speed)
		hud_health.max_value = u.max_health
		hud_health.value = u.current_health
		hud_energy.max_value = u.max_magic
		hud_energy.value = u.current_magic
		hud_name.text = u.unit_type
		_load_unit_abilities(u)

func _load_unit_abilities(unit: Unit) -> void:
	var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]
	_clear_spell_buttons(spell_buttons)
	
	if unit.abilities and unit.abilities.size() > 0:
		for i in range(min(unit.abilities.size(), spell_buttons.size())):
			_setup_ability_button(spell_buttons[i], unit.abilities[i], func(): _on_unit_ability_pressed(unit, unit.abilities[i]))

func select_building(building: Building) -> void:
	if building == null:
		return
	
	if selected_unit != null:
		selected_unit.deselect()
		selected_unit = null
	
	selected_building = building
	_update_building_hud(building)

func _update_building_hud(building: Building) -> void:
	var portrait_path = building.get_building_portrait()
	if portrait_path != "" and hud_portrait:
		var texture = load(portrait_path)
		hud_portrait.texture = texture if texture else null
	
	var spell_buttons = [spell1, spell2, spell3, spell4, spell5, spell6, spell7]
	_clear_spell_buttons(spell_buttons)
	
	for i in range(min(building. abilities.size(), spell_buttons. size())):
		_setup_ability_button(spell_buttons[i], building.abilities[i], func(): _on_ability_pressed(building, building.abilities[i]))
	
	_reset_hud_stats()

func _setup_ability_button(button: TextureButton, ability, callback: Callable) -> void:
	if button and ability:
		var icon_texture = load(ability.icon)
		if icon_texture:
			button. texture_normal = icon_texture
			button.visible = true
			button.disabled = false
			button.tooltip_text = ability.name + "\n" + ability.description
			for connection in button.pressed.get_connections():
				button.pressed.disconnect(connection["callable"])
			button.pressed. connect(callback)

func _clear_spell_buttons(buttons: Array) -> void:
	for button in buttons:
		if button:
			button.texture_normal = null
			button.visible = false
			button.disabled = true
			button.tooltip_text = ""

func _reset_hud_stats() -> void:
	hud_attack. text = "Attack: -"
	hud_defense. text = "Defense: -"
	hud_velocity.text = "Speed: -"
	hud_health.max_value = 10000
	hud_health.value = 0
	hud_energy.max_value = 10000
	hud_energy.value = 0
	hud_name. text = selected_building.get_class() if selected_building else ""

func deselect_current_unit() -> void:
	print("🔥🔥🔥 DESELECT_CURRENT_UNIT LLAMADO DESDE:")
	print_stack()  # 🔥 ESTO TE DIRÁ EXACTAMENTE QUIÉN LO LLAMA
	_deselect_all_units()
	
	if selected_unit != null:
		_disconnect_unit_signals(selected_unit)
		selected_unit. deselect()
		selected_unit = null
	
	selected_building = null
	_clear_abilities()
	
	if hud_portrait:
		hud_portrait.texture = null
	_reset_hud_stats()
	hud_name.text = ""

func _clear_abilities() -> void:
	_clear_spell_buttons([spell1, spell2, spell3, spell4, spell5, spell6, spell7])

# ==============================
# 🎮 CALLBACKS DE HABILIDADES
# ==============================
func _on_unit_ability_pressed(unit: Unit, ability) -> void:
	if unit.has_method("use_ability"):
		unit.use_ability(ability)

func _on_ability_pressed(building, ability) -> void:
	if building.has_method("use_ability"):
		building.use_ability(ability)

func _show_energy_not() -> void:
	menu_hud._show_energy_not()

# ==============================
# 🏗️ SISTEMA DE CONSTRUCCIÓN
# ==============================
func _start_build_mode(building_name: String) -> void:
	building_to_build = building_name
	
	var cost = BuildingCosts.get_cost(building_to_build)
	
	if not cost or cost.size() == 0:
		return
	
	if gold < cost.gold or resources < cost.resources:
		menu_hud._show_resource_not()
		return
	
	var controller_scene = load("res://Scenes/Game/buildings/medievalBuild/medievalBuild_controller.tscn")
	if controller_scene == null:
		return
	
	build_placeholder = controller_scene.instantiate()
	build_placeholder. set_physics_process(false)
	
	var parent_node = get_battle_map() if is_battle_mode else get_base_map()
	if parent_node == null:
		return
	
	parent_node.add_child(build_placeholder)
	await get_tree().process_frame
	
	if build_placeholder.has_method("setup_for_player"):
		build_placeholder.setup_for_player(self)
	
	if build_placeholder.has_method("set_building_type"):
		build_placeholder.set_building_type(building_name)
	
	is_placing_building = true

func _on_player_hud_barracks_pressed() -> void: _start_build_mode("barracks")
func _on_player_hud_dragon_pressed() -> void: _start_build_mode("dragon")
func _on_player_hud_farm_pressed() -> void: _start_build_mode("farm")
func _on_player_hud_harbor_pressed() -> void: _start_build_mode("harbor")
func _on_player_hud_magic_pressed() -> void: _start_build_mode("magic")
func _on_player_hud_shrine_pressed() -> void: _start_build_mode("shrine")
func _on_player_hud_smithy_pressed() -> void: _start_build_mode("smithy")
func _on_player_hud_tower_pressed() -> void: _start_build_mode("tower")

# ==============================
# 📦 GESTIÓN DE UNIDADES Y EDIFICIOS
# ==============================
func add_unit(unit: Entity) -> void:
	if unit == null or unit in units:
		return
	
	units.append(unit)
	unit.player_owner = self
	
	if unit. has_method("setup_player_collision_layers"):
		unit.setup_player_collision_layers(player_index)
	
	if unit not in defense_units:
		defense_units.append(unit)
	
	_update_units_labels()

func add_building(building: CharacterBody3D) -> void:
	if building == null or building in buildings:
		return
	
	buildings.append(building)
	building.player_owner = self
	
	if building. has_method("setup_player_collision_layers"):
		building. setup_player_collision_layers(player_index)

func move_unit_to_attack(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	defense_units.erase(unit)
	if unit not in attack_units:
		attack_units.append(unit)
	_update_units_labels()

func move_unit_to_defense(unit: Entity) -> void:
	if unit == null or unit not in units:
		return
	
	attack_units.erase(unit)
	if unit not in defense_units:
		defense_units.append(unit)
	_update_units_labels()

func _on_unit_died(unit: Entity) -> void:
	units.erase(unit)
	attack_units.erase(unit)
	defense_units.erase(unit)
	battle_units.erase(unit)
	_update_units_labels()
	
	if selected_unit == unit:
		deselect_current_unit()

# ==============================
# 💰 RECURSOS Y HUD
# ==============================
func update_team_hud() -> void:
	if upKeepLabel:
		upKeepLabel. text = str(upkeep) + " / " + str(maxUpKeep)
	if resourcesLabel:
		resourcesLabel.text = str(resources)
	if goldLabel:
		goldLabel.text = str(gold)

func _update_units_labels() -> void:
	if attackUnits_label:
		attackUnits_label.text = "Attack units: " + str(attack_units.size())
	if defenseUnits_label:
		defenseUnits_label.text = "Defense units: " + str(defense_units.size())
	if workers_label:
		workers_label.text = "Workers: " + str(workers)

func _update_workers_label() -> void:
	if workers_label:
		workers_label.text = "Workers: " + str(workers)

func add_worker() -> void:
	var cost = UnitCosts.get_cost("worker")
	if gold < cost.gold or resources < cost. resources or (upkeep + cost.upkeep > maxUpKeep):
		menu_hud._show_resource_not()
		return
	workers += 1
	gold -= cost.gold
	upkeep += cost.upkeep
	_update_workers_label()

func _on_second_tick(time_left: int) -> void:
	if hour:
		hour. text = format_hms(time_left)
	gold += workers * 1
	resources += workers * 0.5
	update_team_hud()

func format_hms(seconds: int) -> String:
	var m = (seconds % 3600) / 60
	var s = seconds % 60
	return "%02d:%02d" % [m, s]

# ==============================
# 🎯 BOTONES DE ACCIÓN
# ==============================
func _on_move_button_pressed() -> void:
	var cmd = MoveCommand.new(self)
	command_invoker.execute_command(cmd)

func _on_attack_button_pressed() -> void:
	var cmd = AttackCommand.new(self)
	command_invoker.execute_command(cmd)

func _on_keep_pos_button_pressed() -> void:
	var cmd = PatrolCommand.new(self)
	command_invoker.execute_command(cmd)

func _on_stop_button_pressed() -> void:
	var cmd = StopCommand.new(self)
	command_invoker.execute_command(cmd)

func _start_ability_target_selection(source_unit: Unit, ability_id: String) -> void:
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	
	var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
	if not select_scene:
		return
	
	_spawn_cursor(select_scene)
	is_selecting_ability_target = true

func _start_ability_terrain_selection(source_unit: Unit, ability_id: String, max_range: float = 0.0) -> void:
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	ability_terrain_max_range = max_range
	
	var select_scene = load("res://Scenes/Utils/Select/SelectTerrain.tscn")
	if not select_scene:
		return
	
	_spawn_cursor(select_scene)
	is_selecting_ability_terrain = true

func _start_ability_ally_selection(source_unit: Unit, ability_id: String) -> void:
	ability_source_unit = source_unit
	ability_id_pending = ability_id
	
	var select_scene = load("res://Scenes/Utils/Target/TargetObjetive.tscn")
	if not select_scene:
		return
	
	_spawn_cursor(select_scene)
	is_selecting_ability_ally = true

func _spawn_cursor(scene: PackedScene) -> void:
	select_cursor_instance = scene.instantiate()
	var parent_node = get_battle_map() if is_battle_mode else get_base_map()
	if parent_node:
		parent_node.add_child(select_cursor_instance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ==============================
# 🧹 LIMPIEZA
# ==============================
func _cleanup_cursor_only() -> void:
	if select_cursor_instance and is_instance_valid(select_cursor_instance):
		select_cursor_instance.queue_free()
		select_cursor_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _cancel_all_selection_modes() -> void:
	is_selecting_terrain = false
	is_selecting_objective = false
	is_selecting_patrol_target = false
	is_selecting_ability_terrain = false
	is_selecting_ability_target = false
	is_selecting_ability_ally = false
	is_placing_building = false

func _cleanup_ability_selection() -> void:
	is_selecting_ability_terrain = false
	is_selecting_ability_target = false
	is_selecting_ability_ally = false
	ability_source_unit = null
	ability_id_pending = ""
	ability_terrain_max_range = 0.0
	_cleanup_cursor_only()

func _cleanup_cursor() -> void:
	if select_cursor_instance and is_instance_valid(select_cursor_instance):
		select_cursor_instance. queue_free()
		select_cursor_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _cleanup_cursors() -> void:
	_cleanup_cursor()
	
	if selection_box and is_box_selecting:
		selection_box.cancel_selection()
		is_box_selecting = false
	
	if build_placeholder and is_instance_valid(build_placeholder):
		build_placeholder.queue_free()
		build_placeholder = null
	
	if selected_unit:
		selected_unit.deselect()
		selected_unit = null
	
	selected_building = null
	_clear_abilities()
	
	_cancel_all_selection_modes()
	_cleanup_ability_selection()

# ==============================
# ⚔️ BATTLE MAP
# ==============================
func _on_battle_mode_started() -> void:
	is_battle_mode = true
	_cleanup_cursors()

func _on_battle_mode_ended() -> void:
	is_battle_mode = false
	_cleanup_cursors()

func get_base_map() -> Node:
	var game_manager = get_parent()
	if not game_manager:
		return null
	var game_scene = game_manager.get_parent()
	if not game_scene:
		return null
	return game_scene.get_node_or_null("BaseMap")

func get_battle_map() -> Node:
	var game_manager = get_parent()
	if not game_manager:
		return null
	var game_scene = game_manager.get_parent()
	if not game_scene:
		return null
	return game_scene.get_node_or_null("Map1")

func transfer_attack_units_to_battle_map() -> void:
	var battle_map = GameStarter.battle_map_instance
	if not battle_map or attack_units.size() == 0:
		return
	
	var ground_area = battle_map.get_node_or_null("Node3D/Player%dArea3D" % (player_index + 1))
	var water_area = battle_map.get_node_or_null("Node3D/Player%dWArea3D" % (player_index + 1))
	
	if not ground_area or not water_area:
		return
	
	var ground_collision = ground_area.get_node_or_null("CollisionShape3D")
	var water_collision = water_area.get_node_or_null("CollisionShape3D")
	
	if not ground_collision or not water_collision:
		return
	
	var units_to_transfer = attack_units.duplicate()
	
	for unit in units_to_transfer:
		if not is_instance_valid(unit) or not unit.is_alive:
			continue
		
		attack_units.erase(unit)
		defense_units.erase(unit)
		units.erase(unit)
		
		if unit not in battle_units:
			battle_units.append(unit)
		
		var spawn_collision = water_collision if unit.unit_category == "aquatic" else ground_collision
		var spawn_pos = _get_random_position_in_area(spawn_collision)
		
		var old_parent = unit.get_parent()
		if old_parent:
			old_parent.remove_child(unit)
		
		battle_map.add_child(unit)
		unit.collision_layer = 1 << 8
		unit.collision_mask = (1 << 0) | (1 << 8)
		if unit.unit_category == "aquatic":
			unit.collision_mask |= 1 << 1
		
		unit.global_position = spawn_pos
		unit.visible = true
		unit.set_physics_process(true)
		unit.set_process(true)
	
	await get_tree().process_frame
	attack_units. clear()
	_update_units_labels()

func _get_random_position_in_area(collision_shape: CollisionShape3D) -> Vector3:
	var shape = collision_shape.shape
	var center = collision_shape.global_position
	if shape is BoxShape3D:
		var half_x = shape.size.x / 2.0
		var half_z = shape.size.z / 2.0
		return Vector3(
			center.x + randf_range(-half_x, half_x),
			center. y,
			center.z + randf_range(-half_z, half_z)
		)
	return center

func return_units_from_battle_map() -> void:
	var copy = battle_units.duplicate()
	for u in copy:
		if not is_instance_valid(u) or (u is Unit and not u.is_alive):
			battle_units.erase(u)
	_update_units_labels()

func set_battle_mode_layers(enable: bool) -> void:
	if enable:
		for unit in battle_units:
			if not is_instance_valid(unit):
				continue
			unit. collision_layer = 1 << 8
			unit.collision_mask = (1 << 0) | (1 << 8)
			if unit.unit_category == "aquatic":
				unit.collision_mask |= 1 << 1
	else:
		for unit in units:
			if not is_instance_valid(unit):
				continue
			if unit.has_method("setup_player_collision_layers"):
				unit.setup_player_collision_layers(player_index)

# ==============================
# 💀 SISTEMA DE VIDAS Y DERROTA
# ==============================
func lose_life() -> void:
	if is_defeated or is_invulnerable:
		return
	
	current_lives -= 1
	current_lives = max(0, current_lives)
	
	if battle_life_bar and is_instance_valid(battle_life_bar) and battle_life_bar.has_method("lose_life"):
		battle_life_bar.lose_life()
	
	is_invulnerable = true
	invulnerability_timer = INVULNERABILITY_DURATION
	
	if current_lives <= 0:
		_on_defeat()

func _on_defeat() -> void:
	if is_defeated:
		return
	
	is_defeated = true
	
	_hide_all_entities()
	_destroy_battle_castle()
	_disable_all_controls()
	
	if is_active_player:
		_show_lose_screen()
	
	var game_manager = get_parent()
	if game_manager and game_manager.has_method("check_victory_conditions"):
		await get_tree().process_frame
		game_manager.check_victory_conditions()

func _hide_all_entities() -> void:
	for unit in battle_units + units + defense_units + attack_units:
		if is_instance_valid(unit):
			unit.visible = false
			unit.set_physics_process(false)
			unit.set_process(false)
	
	for building in buildings:
		if is_instance_valid(building):
			building.visible = false
			building.set_physics_process(false)
			building.set_process(false)

func _disable_all_controls() -> void:
	var rts = $RtsController
	if rts:
		rts.set_process(false)
		rts.set_physics_process(false)
		rts.set_process_input(false)
	
	if has_method("_disconnect_ui_buttons"):
		_disconnect_ui_buttons()
	
	set_process_input(false)
	_hide_all_ui()

func _destroy_battle_castle() -> void:
	var battle_map = GameStarter.battle_map_instance
	if not battle_map:
		return
	
	var castle_name = "BattleCastle_Player%d" % (player_index + 1)
	var castle = battle_map.get_node_or_null(castle_name)
	if castle and is_instance_valid(castle):
		castle.queue_free()
	
	if battle_life_bar and is_instance_valid(battle_life_bar):
		battle_life_bar.queue_free()
		battle_life_bar = null

# ==============================
# 🎮 ACTIVACIÓN/DESACTIVACIÓN
# ==============================
func _on_activated() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	var has_won = _check_if_won(game_manager)
	
	if is_defeated:
		_show_lose_screen()
		return
	
	if has_won:
		_show_victory_screen()
		return
	
	_activate_controls()
	_restore_camera_state()
	
	if is_active_player:
		_show_appropriate_ui()
	else:
		if $TeamHud:
			$TeamHud.visible = true
		if $InfoHud:
			$InfoHud.visible = true

func _check_if_won(game_manager) -> bool:
	if not game_manager or not game_manager.has_method("_get_player_data_for_controller"):
		return false
	
	var player_data = game_manager._get_player_data_for_controller(self)
	if not player_data:
		return false
	
	var alive_teams = []
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller) and not controller.is_defeated:
			var other_data = game_manager._get_player_data_for_controller(controller)
			if other_data and other_data.team not in alive_teams:
				alive_teams.append(other_data.team)
	
	return alive_teams.size() == 1 and player_data.team in alive_teams

func _activate_controls() -> void:
	var rts = $RtsController
	if rts:
		rts.visible = true
		rts.set_process(true)
		rts.set_physics_process(true)
		rts.set_process_input(true)
		rts.set_process_unhandled_input(true)
		
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
	
	if is_active_player and has_method("_connect_ui_buttons"):
		_connect_ui_buttons()
	
	if camera:
		camera.make_current()
	
	if $DirectionalLight3D:
		$DirectionalLight3D.visible = true

func _show_appropriate_ui() -> void:
	if is_battle_mode:
		$UnitHud.visible = true
		$TeamHud.visible = true
		$InfoHud.visible = true
	else:
		$UnitHud.visible = true
		$TeamHud.visible = true
		$PlayerHud.visible = true
		$InfoHud.visible = true

func _on_deactivated() -> void:
	_save_camera_state()
	_hide_lose_screen()
	_hide_victory_screen()
	
	if is_defeated:
		return
	
	if is_active_player and has_method("_disconnect_ui_buttons"):
		_disconnect_ui_buttons()
	
	var rts = $RtsController
	if rts:
		rts.set_process(false)
		rts.set_physics_process(false)
		rts.set_process_input(false)
		rts.set_process_unhandled_input(false)
	
	_hide_all_ui()

# ==============================
# 🖼️ PANTALLAS DE VICTORIA/DERROTA
# ==============================
func _show_lose_screen() -> void:
	if lose_screen_instance and is_instance_valid(lose_screen_instance):
		lose_screen_instance.visible = true
		return
	
	var lose_scene = load("res://Scenes/Game/Main/LoseScene/LoseScene.tscn")
	if not lose_scene:
		return
	
	lose_screen_instance = lose_scene.instantiate()
	add_child(lose_screen_instance)
	lose_screen_instance.z_index = 100

func _hide_lose_screen() -> void:
	if lose_screen_instance and is_instance_valid(lose_screen_instance):
		lose_screen_instance.visible = false

func _show_victory_screen() -> void:
	_hide_all_ui()
	
	var win_scene = load("res://Scenes/Game/Main/WinScene/WinScene.tscn")
	if not win_scene:
		return
	
	win_screen_instance = win_scene.instantiate()
	add_child(win_screen_instance)
	win_screen_instance.z_index = 100

func _hide_victory_screen() -> void:
	if win_screen_instance and is_instance_valid(win_screen_instance):
		win_screen_instance.visible = false

func _hide_all_ui() -> void:
	if $UnitHud:
		$UnitHud.visible = false
	if $TeamHud:
		$TeamHud.visible = false
	if $PlayerHud:
		$PlayerHud.visible = false
	if $InfoHud:
		$InfoHud.visible = false
	if $DirectionalLight3D:
		$DirectionalLight3D.visible = false
	var rts = $RtsController
	if rts:
		rts.visible = false

# ==============================
# 🔌 CONEXIÓN DE BOTONES
# ==============================
func _connect_ui_buttons() -> void:
	if moveButton. pressed. is_connected(_on_move_button_pressed):
		moveButton. pressed.disconnect(_on_move_button_pressed)
	if attackButton.pressed.is_connected(_on_attack_button_pressed):
		attackButton.pressed.disconnect(_on_attack_button_pressed)
	if keepPosButton.pressed.is_connected(_on_keep_pos_button_pressed):
		keepPosButton.pressed.disconnect(_on_keep_pos_button_pressed)
	if stopButton.pressed.is_connected(_on_stop_button_pressed):
		stopButton.pressed.disconnect(_on_stop_button_pressed)
	
	moveButton.pressed.connect(_on_move_button_pressed)
	attackButton.pressed.connect(_on_attack_button_pressed)
	keepPosButton.pressed. connect(_on_keep_pos_button_pressed)
	stopButton.pressed.connect(_on_stop_button_pressed)

func _disconnect_ui_buttons() -> void:
	if moveButton.pressed. is_connected(_on_move_button_pressed):
		moveButton.pressed.disconnect(_on_move_button_pressed)
	if attackButton.pressed.is_connected(_on_attack_button_pressed):
		attackButton.pressed.disconnect(_on_attack_button_pressed)
	if keepPosButton.pressed. is_connected(_on_keep_pos_button_pressed):
		keepPosButton.pressed.disconnect(_on_keep_pos_button_pressed)
	if stopButton.pressed.is_connected(_on_stop_button_pressed):
		stopButton.pressed.disconnect(_on_stop_button_pressed)

# ==============================
# 🔧 UTILIDADES NODE3D
# ==============================
func disable_node_3d_recursive(node: Node) -> void:
	if not node:
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
	if not node:
		return
	if node is Node3D:
		node.visible = true
	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)
	if node is CollisionShape3D:
		node.disabled = false
	elif node is Area3D:
		node.monitoring = true
	for child in node.get_children():
		enable_node_3d_recursive(child)

# ==============================
# 💾 GUARDAR/RESTAURAR ESTADO DE CÁMARA
# ==============================
func _save_camera_state() -> void:
	var rts = $RtsController
	if not rts:
		return
	
	saved_camera_position = rts. global_position
	
	if camera:
		var elevation = rts.get_node_or_null("Elevation")
		if elevation:
			saved_camera_zoom = camera.position.length()
			saved_camera_rotation = elevation.rotation. x

func _restore_camera_state() -> void:
	var rts = $RtsController
	if not rts:
		return
	
	if saved_camera_position != Vector3.ZERO:
		rts.global_position = saved_camera_position
	
	if camera:
		var elevation = rts.get_node_or_null("Elevation")
		if elevation and saved_camera_zoom > 0:
			var direction = camera.position. normalized()
			camera.position = direction * saved_camera_zoom
			elevation.rotation.x = saved_camera_rotation

# ==============================
# 🎯 SELECCIÓN MÚLTIPLE - FUNCIONES
# ==============================
func _select_units_in_box(screen_rect: Rect2) -> void:
	if screen_rect.size.x < 1 or screen_rect.size.y < 1:
		return
	
	_deselect_all_units()
	
	var units_to_check = battle_units if is_battle_mode else units
	
	for unit in units_to_check:
		if not is_instance_valid(unit) or not unit.is_alive:
			continue
		
		if unit.player_owner != self:
			continue
		
		var screen_pos = camera.unproject_position(unit.global_position)
		
		if screen_rect.has_point(screen_pos):
			_add_unit_to_selection(unit)
	
	print("✅ Unidades seleccionadas: %d (Modo: %s)" % [selected_units. size(), "BATTLE" if is_battle_mode else "BASE"])
	
	# 🔥 SI HAY MÁS DE UNA UNIDAD, LIMPIAR HUD
	if selected_units. size() > 1:
		_clear_selection_ui()
	elif selected_units.size() == 1:
		# Si solo hay una, mostrar su HUD
		_update_unit_hud(selected_units[0])
	else:
		_clear_selection_ui()

func _add_unit_to_selection(unit: Entity) -> void:
	if unit is Unit and unit not in selected_units:
		selected_units.append(unit)
		unit.select()

func _deselect_all_units() -> void:
	for unit in selected_units:
		if is_instance_valid(unit):
			unit.deselect()
	
	selected_units.clear()
	selected_unit = null

func _clear_selection_ui() -> void:
	if hud_portrait:
		hud_portrait. texture = null
	_reset_hud_stats()
	hud_name.text = ""
	_clear_abilities()
