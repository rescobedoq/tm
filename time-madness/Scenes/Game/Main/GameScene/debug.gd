extends CanvasLayer
class_name PlayerSwitcher

@onready var current_player_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentPlayerLabel
@onready var player1_button = $MarginContainer/VBoxContainer/Player1Button
@onready var player2_button = $MarginContainer/VBoxContainer/Player2Button
@onready var player3_button = $MarginContainer/VBoxContainer/Player3Button
@onready var player4_button = $MarginContainer/VBoxContainer/Player4Button
@onready var player5_button = $MarginContainer/VBoxContainer/Player5Button
@onready var player6_button = $MarginContainer/VBoxContainer/Player6Button

var player_buttons: Array = []
var is_initialized: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	player_buttons = [
		player1_button,
		player2_button,
		player3_button,
		player4_button,
		player5_button,
		player6_button
	]
	for button in [player1_button, player2_button, player3_button, player4_button, player5_button, player6_button]:
		if button:
			button.process_mode = Node.PROCESS_MODE_ALWAYS
	if current_player_label:
		current_player_label.process_mode = Node. PROCESS_MODE_ALWAYS
	# Conectar a la señal de controllers listos
	GameStarter.player_controllers_ready. connect(_on_controllers_ready)
	
	# Si ya hay controllers, inicializar inmediatamente
	if GameStarter.get_player_controllers().size() > 0:
		_initialize_buttons()
	
	print("🎮 PlayerSwitcher inicializado")

func _on_controllers_ready(controllers: Array) -> void:
	print("🎮 PlayerSwitcher: Controllers listos (%d)" % controllers.size())
	_initialize_buttons()

func _initialize_buttons() -> void:
	if is_initialized:
		return
	
	var controllers = GameStarter.get_player_controllers()
	
	if controllers.size() == 0:
		print("⚠️ PlayerSwitcher: No hay controllers disponibles")
		return
	
	print("🎮 PlayerSwitcher: Configurando %d botones..." % controllers. size())
	
	# Conectar botones y configurar visibilidad
	for i in range(player_buttons.size()):
		if i < controllers.size():
			var controller = controllers[i]
			var button = player_buttons[i]
			
			# Configurar texto del botón
			button.text = controller.player_name
			button. visible = true
			
			# Conectar señal
			button.pressed.connect(_on_player_button_pressed.bind(i))
			
			print("  ✅ Botón %d configurado: %s" % [i + 1, controller. player_name])
		else:
			# Ocultar botones sin jugador
			player_buttons[i].visible = false
	
	is_initialized = true
	_update_ui()
	
	print("✅ PlayerSwitcher: Inicialización completa")

func _update_ui() -> void:
	if not is_initialized:
		return
	
	var controllers = GameStarter.get_player_controllers()
	var active_controller = GameStarter.get_active_player_controller()
	
	# Actualizar label del jugador actual
	if active_controller:
		current_player_label.text = active_controller.player_name
	else:
		current_player_label.text = "Ninguno"
	
	# Actualizar estado de botones
	for i in range(player_buttons.size()):
		if i < controllers.size():
			var controller = controllers[i]
			var button = player_buttons[i]
			
			# Deshabilitar si es el jugador activo
			button.disabled = (controller == active_controller)
			
			# Cambiar color visual
			if button.disabled:
				button.add_theme_color_override("font_color", Color. GRAY)
			else:
				button.remove_theme_color_override("font_color")

func _on_player_button_pressed(player_index: int) -> void:
	print("\n🔄 Cambiando a jugador %d..." % (player_index + 1))
	
	var controllers = GameStarter.get_player_controllers()
	
	if player_index >= controllers.size():
		print("❌ Índice de jugador inválido")
		return
	
	var old_controller = GameStarter.get_active_player_controller()
	var new_controller = controllers[player_index]
	
	if old_controller == new_controller:
		print("⚠️ Ya estás controlando a %s" % new_controller.player_name)
		return
	
	# Desactivar el jugador actual
	if old_controller:
		_deactivate_player(old_controller)
	
	# Activar el nuevo jugador
	_activate_player(new_controller)
	
	# Actualizar UI
	_update_ui()
	
	print("✅ Cambio completado: %s → %s" % [
		old_controller.player_name if old_controller else "Ninguno",
		new_controller.player_name
	])


func _deactivate_player(controller) -> void:
	controller.is_active_player = false
	
	# 🔥 LLAMAR A LA FUNCIÓN DEL CONTROLLER
	if controller.has_method("_on_deactivated"):
		controller._on_deactivated()
	else:
		# Fallback si no existe la función (código antiguo)
		_deactivate_player_legacy(controller)
	
	print("  ❌ %s desactivado" % controller. player_name)

func _activate_player(controller) -> void:
	controller.is_active_player = true
	
	# 🔥 LLAMAR A LA FUNCIÓN DEL CONTROLLER
	if controller.has_method("_on_activated"):
		controller._on_activated()
	else:
		# Fallback si no existe la función (código antiguo)
		_activate_player_legacy(controller)
	
	print("  ✅ %s activado completamente" % controller.player_name)

# 🔥 Código antiguo como fallback
func _deactivate_player_legacy(controller) -> void:
	# 🔥 DESCONECTAR BOTONES
	if controller.has_method("_disconnect_ui_buttons"):
		controller._disconnect_ui_buttons()
	
	# 🔥 DESHABILITAR RtsController completamente
	var rts = controller.get_node_or_null("RtsController")
	if rts:
		rts. set_process(false)
		rts.set_physics_process(false)
		rts. set_process_input(false)
		rts.set_process_unhandled_input(false)
	
	# Ocultar UI
	var unit_hud = controller.get_node_or_null("UnitHud")
	var team_hud = controller.get_node_or_null("TeamHud")
	var player_hud = controller.get_node_or_null("PlayerHud")
	var info_hud = controller. get_node_or_null("InfoHud")
	var light = controller.get_node_or_null("DirectionalLight3D")
	
	if unit_hud: unit_hud. visible = false
	if team_hud: team_hud. visible = false
	if player_hud: player_hud. visible = false
	if info_hud: info_hud. visible = false
	if light: light.visible = false

func _activate_player_legacy(controller) -> void:
	# 🔥 HABILITAR RtsController PRIMERO
	var rts = controller.get_node_or_null("RtsController")
	if rts:
		rts.visible = true
		rts.set_process(true)
		rts. set_physics_process(true)
		rts.set_process_input(true)
		rts.set_process_unhandled_input(true)
		
		# 🔥 CONFIGURAR PARÁMETROS DE CÁMARA
		rts. movement_speed = controller.movement_speed
		rts.rotation_speed = controller.rotation_speed
		rts.zoom_speed = controller.zoom_speed
		rts.min_zoom = controller. min_zoom
		rts. max_zoom = controller.max_zoom
		rts.min_elevation_angle = controller.min_elevation_angle
		rts. max_elevation_angle = controller. max_elevation_angle
		rts.edge_margin = controller. edge_margin
		rts. allow_rotation = controller.allow_rotation
		rts.allow_zoom = controller.allow_zoom
		rts.allow_pan = controller.allow_pan
		rts.min_x = controller. min_x
		rts. max_x = controller.max_x
		rts.min_z = controller.min_z
		rts.max_z = controller.max_z
		
		print("  ✅ RtsController habilitado y configurado: %s" % controller. player_name)
	
	# 🔥 CONECTAR BOTONES DE UI
	if controller.has_method("_connect_ui_buttons"):
		controller._connect_ui_buttons()
	
	# 🔥 ACTIVAR CÁMARA
	var camera = controller. get_node_or_null("RtsController/Elevation/Camera3D")
	if camera:
		camera.make_current()
		print("  ✅ Cámara activada: %s" % controller.player_name)
	else:
		print("  ❌ No se encontró cámara para: %s" % controller.player_name)
	
	# Obtener GameManager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		game_manager = get_parent(). get_node_or_null("GameManager")
	
	# 🔥 HABILITAR DirectionalLight3D
	var light = controller.get_node_or_null("DirectionalLight3D")
	if light:
		light.visible = true
		print("  💡 DirectionalLight3D habilitado: %s" % controller.player_name)
	
	# Mostrar UI según el modo actual
	if GameStarter.is_battle_stage:
		# Modo batalla
		var unit_hud = controller.get_node_or_null("UnitHud")
		var team_hud = controller.get_node_or_null("TeamHud")
		var info_hud = controller.get_node_or_null("InfoHud")
		
		if unit_hud: unit_hud.visible = true
		if team_hud: team_hud.visible = true
		if info_hud: info_hud.visible = true
		
		print("  ✅ HUD de batalla visible: %s" % controller.player_name)
	else:
		# Modo base
		var unit_hud = controller.get_node_or_null("UnitHud")
		var team_hud = controller.get_node_or_null("TeamHud")
		var player_hud = controller.get_node_or_null("PlayerHud")
		var info_hud = controller.get_node_or_null("InfoHud")
		
		if unit_hud: unit_hud.visible = true
		if team_hud: team_hud.visible = true
		if player_hud: player_hud.visible = true
		if info_hud: info_hud.visible = true
		
		# Activar BaseMap para este jugador
		if game_manager:
			var game_scene = game_manager.get_parent()
			var base_map = game_scene.get_node_or_null("BaseMap")
			if base_map:
				base_map.visible = true
				controller.enable_node_3d_recursive(base_map)
				print("  ✅ BaseMap activado: %s" % controller.player_name)
		
		print("  ✅ HUD completo visible: %s" % controller.player_name)
