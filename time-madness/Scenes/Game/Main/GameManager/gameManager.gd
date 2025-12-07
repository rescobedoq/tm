extends Node
class_name GameManager

# === REFERENCIAS DE NODOS ===
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var battle_log_node = $Node

# Nodos de jugadores
@onready var player1 = $Node/Players/Player1
@onready var player2 = $Node/Players/Player2
@onready var player3 = $Node/Players/Player3
@onready var player4 = $Node/Players/Player4
@onready var player5 = $Node/Players/Player5
@onready var player6 = $Node/Players/Player6
var player_nodes: Array = []

# Nodos de colores (indicadores de stage)
@onready var c1 = $Node/Colors/c1
@onready var c2 = $Node/Colors/c2
@onready var c3 = $Node/Colors/c3
@onready var c4 = $Node/Colors/c4
@onready var c5 = $Node/Colors/c5
@onready var c6 = $Node/Colors/c6
@onready var c7 = $Node/Colors/c7
@onready var c8 = $Node/Colors/c8
@onready var c9 = $Node/Colors/c9
@onready var c10 = $Node/Colors/c10
var color_nodes: Array = []

# === ESTADO DEL JUEGO ===
enum GameState {
	INTRO_VIDEO,
	STAGE_PREPARATION,
	STAGE_PLAYING
}

var current_game_state: GameState = GameState.INTRO_VIDEO
var current_stage: int = 1

# === SISTEMA DE PARPADEO ===
var blink_timer: float = 0.0
var blink_interval: float = 0.5
var blink_state: bool = true

# === INICIALIZACIÓN ===
func _ready() -> void:
	player_nodes = [player1, player2, player3, player4, player5, player6]
	color_nodes = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
	
	battle_log_node.visible = false
	for color in color_nodes:
		color.visible = false
	
	GameStarter.stage_changed.connect(_on_stage_changed)
	GameStarter.stage_time_over.connect(_on_stage_time_over)
	
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller) and controller.get_parent() == null:
			add_child(controller)        
			_hide_all_player_ui(controller)

	_start_intro_video()

# === LOOP PRINCIPAL ===
func _process(delta: float) -> void:
	match current_game_state:
		GameState.INTRO_VIDEO:
			pass
			
		GameState.STAGE_PREPARATION:
			_update_color_blink(delta)
			
		GameState.STAGE_PLAYING:
			pass

# === INTRO VIDEO ===
func _start_intro_video() -> void:
	current_game_state = GameState.INTRO_VIDEO
	video_player.visible = true
	video_player.play()
	video_player.finished.connect(_on_video_finished)
	print("🎬 Reproduciendo video de introducción...")
	
	# 🔥 Ocultar TODO durante el video
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_all_player_ui(controller)

func _on_video_finished() -> void:
	video_player.visible = false
	print("✅ Video terminado")
	
	_setup_players()
	current_stage = GameStarter.get_current_stage()
	_update_stage_colors()
	_create_battle_map_castles()

	_start_stage_preparation()

# === CONFIGURACIÓN DE JUGADORES ===
func _setup_players() -> void:
	var players_data = GameStarter.configured_players
	print("\n" + "=".repeat(60))
	print("📋 CONFIGURANDO JUGADORES EN BATTLE LOG")
	print("=".repeat(60))
	
	for i in range(player_nodes.size()):
		if i < players_data.size():
			var player_data = players_data[i]
			var player_node = player_nodes[i]
			
			player_node.get_node("Name").text = player_data.player_name
			player_node. get_node("Faction").text = player_data.race
			player_node.get_node("ColorRect"). color = Teams.get_team_color(i)
			
			var status_node = player_node.get_node("Status")
			if status_node is Label:
				status_node.text = "-"
			
			player_node.visible = true
			
			var player_type = "🎮" if not player_data.is_bot else "🤖"
			print("  %s [%d] %s | Facción: %s | Equipo: %d" % 
				[player_type, i+1, player_data.player_name, player_data.race, player_data.team])
		else:
			player_nodes[i].visible = false
	
	print("=".repeat(60) + "\n")


# === GESTIÓN DE STAGES ===
func _start_stage_preparation() -> void:
	current_game_state = GameState.STAGE_PREPARATION
	
	print("\n" + "━".repeat(60))
	print("🛡️  PREPARACIÓN PARA STAGE %d" % current_stage)
	print("━". repeat(60))
	
	# 🔥 Ocultar TODO EL UI DE TODOS LOS JUGADORES
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_all_player_ui(controller)
	
	# Ocultar mapas
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance.disable_map()
	
	var game_scene = get_parent()
	var base_map = game_scene.get_node_or_null("BaseMap")
	if base_map:
		base_map.visible = false
	
	# Mostrar Battle Log
	battle_log_node.visible = true
	
	# Mostrar resumen del stage anterior
	if current_stage > 1:
		_show_stage_summary(current_stage - 1)
	
	print("⏳ Esperando 1 segundo antes de iniciar...")
	await get_tree().create_timer(1.0).timeout
	
	# Ocultar Battle Log
	battle_log_node.visible = false
	
	_start_stage_playing()

func _start_stage_playing() -> void:
	current_game_state = GameState.STAGE_PLAYING
	battle_log_node.visible = false
	
	print("\n" + "⚔". repeat(30))
	print("⚔️  INICIANDO STAGE %d" % current_stage)
	print("⚔".repeat(30))
	
	# 🔥 ALTERNAR ENTRE BASE STAGE Y BATTLE STAGE
	if GameStarter.is_battle_stage:
		_show_battle_stage()
	else:
		_show_base_stage()
	
	# 🔥 INICIAR EL TIMER
	GameStarter.start_stage_timer()
	print("🎮 ¡Stage en progreso!")

# 🔥 MOSTRAR BATTLE STAGE (stages pares)
func _show_battle_stage() -> void:
	print("⚔️ Stage PAR → BATTLE STAGE")

	# Emitir señal de battle mode
	GameStarter.battle_mode_started.emit()
	
	# 🔥 Para TODOS los jugadores: Ocultar TODO
	for controller in GameStarter. get_player_controllers():
		if not is_instance_valid(controller):
			continue
		
		# 🔥 OCULTAR TODO EL UI (incluyendo activos)
		_hide_all_player_ui(controller)
		
		# Desactivar BaseMap
		var game_scene = get_parent()
		var base_map = game_scene.get_node_or_null("BaseMap")
		if base_map:
			controller.disable_node_3d_recursive(base_map)
			base_map.visible = false
	
	# 🔥 TRANSFERIR UNIDADES DE ATAQUE AL BATTLE MAP
	print("\n🚀 Iniciando transferencia de unidades al Battle Map...")
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			controller.transfer_attack_units_to_battle_map()
			await get_tree().process_frame  # Esperar entre cada jugador
	
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			controller.set_battle_mode_layers(true)  # 🔥 ACTIVAR BATTLE LAYERS
			await get_tree().process_frame
		
	# 🔥 Solo para el jugador ACTIVO: mostrar HUD de batalla
	var active_controller = GameStarter.get_active_player_controller()
	if active_controller and is_instance_valid(active_controller):
		# 🔥 HABILITAR RtsController
		var rts = active_controller.get_node_or_null("RtsController")
		if rts:
			rts.visible = true
			rts.set_process(true)
			rts.set_physics_process(true)
			rts.set_process_input(true)
			rts. set_process_unhandled_input(true)
			print("  ✅ RtsController habilitado: %s" % active_controller. player_name)
		
		var unit_hud = active_controller.get_node_or_null("UnitHud")
		var team_hud = active_controller. get_node_or_null("TeamHud")
		var info_hud = active_controller. get_node_or_null("InfoHud")
		
		if unit_hud: unit_hud.visible = true
		if team_hud: team_hud.visible = true
		if info_hud: info_hud.visible = true
		
		# 🔥 OCULTAR PlayerHud en batalla
		var player_hud = active_controller.get_node_or_null("PlayerHud")
		if player_hud:
			player_hud.visible = false
			print("  ❌ PlayerHud OCULTO en batalla: %s" % active_controller. player_name)
		
		# 🔥 HABILITAR DirectionalLight3D
		var light = active_controller.get_node_or_null("DirectionalLight3D")
		if light:
			light.visible = true
			print("  💡 DirectionalLight3D habilitado: %s" % active_controller.player_name)
		
		# 🔥 HABILITAR LA CÁMARA
		var camera = active_controller.get_node_or_null("RtsController/Elevation/Camera3D")
		if camera:
			camera.make_current()
			print("  ✅ Cámara activada para batalla: %s" % active_controller.player_name)
		
		print("  ✅ HUD de batalla visible para: %s" % active_controller.player_name)
	
	# 🔥 Habilitar el BattleMap completamente
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("enable_map"):
			GameStarter. battle_map_instance.enable_map()
		print("✅ Battle Map HABILITADO")

# 🔥 MOSTRAR BASE STAGE (stages impares)
func _show_base_stage() -> void:
	GameStarter.battle_mode_ended.emit()
	print("🏠 Stage IMPAR → BASE STAGE")
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			controller.set_battle_mode_layers(false)  # 🔥 DESACTIVAR BATTLE LAYERS
	
	# 🔥 Deshabilitar Map1 completamente
	if GameStarter. battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance.disable_map()
		print("  ❌ Battle Map DESHABILITADO")
	
	# 🔔 Las unidades que fueron transferidas a Battle Map NO vuelven
	print("🔔 Las unidades que fueron transferidas a Battle Map NO serán retornadas al BaseMap.")
	
	# 🔥 Solo para el jugador ACTIVO
	var active_controller = GameStarter.get_active_player_controller()
	if active_controller and is_instance_valid(active_controller):
		# 🔥 Obtener BaseMap desde GameScene
		var game_scene = get_parent()
		var base_map = game_scene.get_node_or_null("BaseMap")
		
		if base_map:
			base_map.visible = true
			active_controller.enable_node_3d_recursive(base_map)
			print("  ✅ BaseMap activado: %s" % active_controller.player_name)
			
			# 🔥 REACTIVAR AttackArea
			var attack_area = base_map. get_node_or_null("AttackArea3D")
			if attack_area and attack_area.has_method("activate"):
				attack_area.activate()
				print("  ✅ AttackArea reactivada")
		
		# 🔥 HABILITAR RtsController
		var rts = active_controller.get_node_or_null("RtsController")
		if rts:
			rts.visible = true
			rts.set_process(true)
			rts.set_physics_process(true)
			rts.set_process_input(true)
			rts.set_process_unhandled_input(true)
			print("  ✅ RtsController habilitado: %s" % active_controller.player_name)
		
		# Mostrar PlayerHud
		var player_hud = active_controller.get_node_or_null("PlayerHud")
		if player_hud:
			player_hud.visible = true
			print("  ✅ PlayerHud visible: %s" % active_controller.player_name)
		
		# Mostrar el resto del HUD
		var unit_hud = active_controller. get_node_or_null("UnitHud")
		var team_hud = active_controller.get_node_or_null("TeamHud")
		var info_hud = active_controller.get_node_or_null("InfoHud")
		
		if unit_hud: unit_hud.visible = true
		if team_hud: team_hud.visible = true
		if info_hud: info_hud.visible = true
		
		# 🔥 HABILITAR DirectionalLight3D
		var light = active_controller. get_node_or_null("DirectionalLight3D")
		if light:
			light.visible = true
			print("  💡 DirectionalLight3D habilitado: %s" % active_controller.player_name)
		
		# 🔥 HABILITAR LA CÁMARA
		var camera = active_controller.get_node_or_null("RtsController/Elevation/Camera3D")
		if camera:
			camera.make_current()
			print("  ✅ Cámara activada para: %s" % active_controller. player_name)
		
		print("  ✅ HUD completo visible para: %s" % active_controller.player_name)

	# 🔥 Ocultar UI de los demás jugadores
	for controller in GameStarter.get_player_controllers():
		if controller != active_controller and is_instance_valid(controller):
			_hide_all_player_ui(controller)

# 🔥 OCULTAR TODO EL UI DE UN JUGADOR
func _hide_all_player_ui(controller) -> void:
	if not is_instance_valid(controller):
		return
	
	# 🔥 Deshabilitar RtsController
	var rts = controller.get_node_or_null("RtsController")
	if rts:
		rts.visible = false
		rts.set_process(false)
		rts.set_physics_process(false)
		rts.set_process_input(false)
		rts.set_process_unhandled_input(false)
	
	var unit_hud = controller.get_node_or_null("UnitHud")
	var team_hud = controller.get_node_or_null("TeamHud")
	var player_hud = controller.get_node_or_null("PlayerHud")
	var info_hud = controller.get_node_or_null("InfoHud")
	
	# 🔥 NUEVO: Ocultar DirectionalLight3D
	var light = controller.get_node_or_null("DirectionalLight3D")
	
	if unit_hud: unit_hud.visible = false
	if team_hud: team_hud.visible = false
	if player_hud: player_hud.visible = false
	if info_hud: info_hud.visible = false
	if light: light.visible = false

# === SEÑALES DE GAMESTARTER ===
func _on_stage_changed(new_stage: int) -> void:
	current_stage = new_stage
	_update_stage_colors()
	print("🎨 Indicadores visuales actualizados al stage: %d" % current_stage)

func _on_stage_time_over(finished_stage: int) -> void:
	print("\n⏰ TIEMPO DEL STAGE %d AGOTADO" % finished_stage)
	
	# 🔥 CAPTURAR ESTADO DE UNIDADES DE ATAQUE ANTES DE DESHABILITAR
	var game_scene = get_parent()
	var base_map = game_scene.get_node_or_null("BaseMap")
	
	if base_map:
		# 🔥 Desactivar AttackArea para que no mueva unidades cuando se deshabilite
		var attack_area = base_map.get_node_or_null("AttackArea3D")
		if attack_area and attack_area.has_method("deactivate"):
			attack_area.deactivate()
			print("🔥 AttackArea desactivada para capturar unidades")
	
	# 🔥 PRIMERO: Ocultar TODO el HUD de TODOS los jugadores
	print("🔥 Ocultando HUD de todos los jugadores...")
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_all_player_ui(controller)
			print("  ❌ HUD oculto para: %s" % controller.player_name)
	
	# 🔥 SEGUNDO: Ocultar mapas
	print("🔥 Ocultando mapas...")
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance. disable_map()
	
	if base_map:
		base_map.visible = false
		
		# Deshabilitar BaseMap para TODOS los jugadores
		for controller in GameStarter.get_player_controllers():
			if is_instance_valid(controller):
				controller. disable_node_3d_recursive(base_map)
	
	# 🔥 TERCERO: Mostrar resumen
	_show_stage_summary(finished_stage)
	
	# 🔥 CUARTO: Ir a preparación del siguiente stage
	_start_stage_preparation()

# === RESUMEN DEL STAGE ===
func _show_stage_summary(stage_number: int) -> void:
	print("\n📊 RESUMEN DEL STAGE %d:" % stage_number)
	print("=".repeat(60))
	
	for controller in GameStarter.get_player_controllers():
		if not is_instance_valid(controller):
			continue
		
		var attack_count = controller.attack_units.size() if "attack_units" in controller else 0
		var defense_count = controller.defense_units.size() if "defense_units" in controller else 0
		var battle_count = controller.battle_units.size() if "battle_units" in controller else 0
		
		print("  %s:" % controller.player_name)
		print("    🗡️  Ataque: %d" % attack_count)
		print("    🛡️  Defensa: %d" % defense_count)
		print("    ⚔️  Batalla: %d" % battle_count)
		
		if "battle_units" in controller and battle_count > 0:
			var unit_names = []
			for u in controller.battle_units:
				if is_instance_valid(u):
					unit_names.append(u.name)
			if unit_names. size() > 0:
				print("      Unidades en batalla: %s" % ", ".join(unit_names))
	
	print("=".repeat(60))

# === SISTEMA DE COLORES ===
func _update_stage_colors() -> void:
	for i in range(color_nodes.size()):
		if i < current_stage - 1:
			color_nodes[i].visible = true
		elif i == current_stage - 1:
			pass
		else:
			color_nodes[i].visible = false

func _update_color_blink(delta: float) -> void:
	blink_timer += delta
	if blink_timer >= blink_interval:
		blink_timer = 0.0
		blink_state = not blink_state
		
		var current_color_index = current_stage - 1
		if current_color_index >= 0 and current_color_index < color_nodes.size():
			color_nodes[current_color_index].visible = blink_state
			
			
# 🔥 FUNCIÓN: Crear castillos en Battle Map para cada jugador con colores
func _create_battle_map_castles() -> void:
	print("\n🏰 Creando castillos en Battle Map...")
	
	if GameStarter.battle_map_instance == null:
		print("❌ Battle Map no existe en GameStarter")
		return
	
	var battle_map = GameStarter. battle_map_instance
	print("✅ Battle Map encontrado: %s" % battle_map. name)
	
	var player_bases = battle_map.get_node_or_null("PlayerBases")
	if player_bases == null:
		print("❌ No se encontró PlayerBases en Battle Map")
		print("   Hijos de Battle Map: %s" % battle_map.get_children())
		return
	
	print("✅ PlayerBases encontrado")
	print("   Markers disponibles: %s" % player_bases.get_children())
	
	const CASTLE_SCENE = preload("res://Scenes/Game/buildings/medievalCastle/medievalCastle.tscn")
	const LIFE_BAR_SCENE = preload("res://Scenes/Utils/PlayerLifeBar/LifeBar.tscn")
	const Y_OFFSET = 21.0
	
	var controllers = GameStarter.get_player_controllers()
	var players_data = GameStarter.configured_players
	print("📊 Total de jugadores: %d" % controllers.size())
	for i in range(controllers.size()):
		var controller = controllers[i]
		var marker_name = "player%d" % (i + 1)
		
		print("\n🔍 Buscando marker: %s" % marker_name)
		var marker = player_bases. get_node_or_null(marker_name)
		
		if marker == null:
			print("  ❌ No se encontró marker: %s" % marker_name)
			continue
		
		print("  ✅ Marker encontrado en: %v" % marker. global_position)
		
		# 🔥 BUSCAR Y ASIGNAR EL ÁREA DEL JUGADOR
		var area_name = "Player%dArea3D" % (i + 1)
		
		# Buscar en varios lugares posibles
		var player_area = battle_map.get_node_or_null("PlayerAreaBase/" + area_name)
		if player_area == null:
			player_area = battle_map. get_node_or_null("Node3D/" + area_name)
		if player_area == null:
			player_area = battle_map. get_node_or_null(area_name)
		
		if player_area and player_area is Area3D:
			player_area.set_meta("player_controller", controller)
			print("  ✅ Área '%s' asignada a %s" % [area_name, controller.player_name])
		else:
			print("  ⚠️ No se encontró área: %s" % area_name)
		
		# Instanciar castillo
		var castle = CASTLE_SCENE.instantiate()
		castle.name = "BattleCastle_Player%d" % (i + 1)
		
		# Posicionar en el marker con offset en Y
		var spawn_pos = marker.global_position
		spawn_pos.y = Y_OFFSET
		
		print("  📍 Posición del castillo: %v" % spawn_pos)
		
		# Agregar al Battle Map
		battle_map.add_child(castle)
		GameStarter.all_battle_builds.append(castle)		
		await get_tree().process_frame
		
		# Configurar posición después de agregar
		castle.global_position = spawn_pos
		
		# 🔥 INSTANCIAR LIFE BAR EN LA MISMA POSICIÓN
		var life_bar = LIFE_BAR_SCENE. instantiate()
		life_bar.name = "LifeBar_Player%d" % (i + 1)
		battle_map.add_child(life_bar)
		
		await get_tree().process_frame
		
		life_bar.global_position = spawn_pos
		print("  ❤️ LifeBar creado en: %v" % spawn_pos)
		
		# 🔥🔥🔥 GUARDAR REFERENCIA AL LIFEBAR EN EL CONTROLLER 🔥🔥🔥
		controller.battle_life_bar = life_bar
		print("  ✅ LifeBar asignado a %s" % controller.player_name)
		
		# 🔥 APLICAR COLOR DEL EQUIPO
		if i < players_data.size():
			var player_data = players_data[i]
			var team_color = Teams.get_team_color(player_data.team)
			_apply_color_to_castle(castle, team_color)
			print("  🎨 Color aplicado: %s (Equipo %d)" % [team_color, player_data.team])
		
		print("  ✅ Castillo '%s' creado para %s" % [castle.name, controller.player_name])
	
	print("\n🏰 Proceso de creación de castillos finalizado\n")
# 🔥 NUEVA FUNCIÓN: Aplicar color a un castillo específico
func _apply_color_to_castle(castle: Node, color: Color) -> void:
	# Aplicar color recursivamente solo a los hijos del castillo
	_apply_color_to_meshes(castle, color)

# 🔥 FUNCIÓN: Aplicar tinte de color a MeshInstance3D (recursivo)
func _apply_color_to_meshes(node: Node, color: Color) -> void:
	# Si el nodo es un MeshInstance3D, aplicar tinte
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		
		# 🔥 CREAR UN TINTE SUAVE (mezcla con blanco para suavizar)
		var tint_color = color.lerp(Color.WHITE, 0.6)  # 40% color + 60% blanco
		tint_color.a = 1.0  # Sin transparencia
		
		# 🔥 OBTENER MATERIAL ORIGINAL O CREAR UNO NUEVO
		var surface_count = mesh_instance.mesh.get_surface_count() if mesh_instance. mesh else 0
		
		for i in range(surface_count):
			var original_material = mesh_instance.get_surface_override_material(i)
			
			# Si no hay material override, obtener el del mesh
			if original_material == null:
				original_material = mesh_instance.mesh.surface_get_material(i)
			
			# Duplicar el material para no afectar otros objetos
			var new_material: StandardMaterial3D
			
			if original_material and original_material is StandardMaterial3D:
				new_material = original_material. duplicate()
			else:
				new_material = StandardMaterial3D.new()
			
			# 🔥 APLICAR TINTE multiplicando el color base
			if new_material.albedo_texture:
				# Si tiene textura, modular el color
				new_material.albedo_color = tint_color
			else:
				# Si no tiene textura, mezclar colores
				var original_color = new_material.albedo_color
				new_material.albedo_color = original_color * tint_color
			
			mesh_instance.set_surface_override_material(i, new_material)
		
		print("    🖌️ Tinte aplicado a mesh: %s" % node.name)
	
	# Aplicar recursivamente a todos los hijos
	for child in node.get_children():
		_apply_color_to_meshes(child, color)


# 🔥 AGREGAR AL GameManager. gd

# === DETECCIÓN DE VICTORIA ===
func check_victory_conditions() -> void:
	print("\n🏆 Verificando condiciones de victoria...")
	
	var alive_players: Array = []
	var alive_teams: Array = []
	
	# 🔥 Recopilar jugadores vivos y sus equipos
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller) and not controller.is_defeated:
			alive_players.append(controller)
			
			# Obtener el equipo del jugador desde configured_players
			var player_data = _get_player_data_for_controller(controller)
			if player_data and player_data.team not in alive_teams:
				alive_teams.append(player_data.team)
			
			print("  ✅ Vivo: %s (Equipo: %d)" % [controller.player_name, player_data.team if player_data else -1])
	
	print("📊 Jugadores vivos: %d | Equipos vivos: %d" % [alive_players.size(), alive_teams.size()])
	
	# 🔥 CASO 1: Solo queda 1 equipo → VICTORIA
	if alive_teams.size() == 1:
		var winning_team = alive_teams[0]
		print("🏆 ¡EQUIPO %d HA GANADO!" % winning_team)
		_on_team_victory(winning_team, alive_players)
		return
	
	# 🔥 CASO 2: No quedan jugadores vivos → EMPATE (raro)
	if alive_players.size() == 0:
		print("⚖️ EMPATE: Todos los jugadores fueron derrotados")
		_on_game_draw()
		return
	
	# 🔥 CASO 3: Aún hay varios equipos → Continuar jugando
	print("⚔️ Aún hay %d equipos en competencia.  El juego continúa." % alive_teams.size())

# 🔥 NUEVA FUNCIÓN: Obtener PlayerData de un controller
func _get_player_data_for_controller(controller) -> PlayerData:  # 🔥 SIN TIPO ESPECÍFICO
	var players_data = GameStarter.configured_players
	var controllers = GameStarter.get_player_controllers()
	
	# Buscar el índice del controller
	var index = controllers.find(controller)
	if index >= 0 and index < players_data.size():
		return players_data[index]
	
	return null

# 🔥 NUEVA FUNCIÓN: Victoria de un equipo
func _on_team_victory(winning_team: int, winning_players: Array) -> void:
	print("\n" + "🏆". repeat(30))
	print("🏆  VICTORIA DEL EQUIPO %d" % winning_team)
	print("🏆".repeat(30))
	
	# Pausar el juego
	get_tree().paused = true
	
	# Mostrar pantalla según si el jugador activo ganó o perdió
	var active_controller = GameStarter.get_active_player_controller()
	
	if active_controller in winning_players:
		print("✅ El jugador activo (%s) GANÓ" % active_controller.player_name)
		_show_victory_screen_for_player(active_controller)
	else:
		print("❌ El jugador activo (%s) PERDIÓ" % active_controller.player_name)
		# Ya debería tener la pantalla de derrota mostrada desde _on_defeat()
		# Pero por si acaso:
		if active_controller and active_controller.has_method("_show_lose_screen"):
			active_controller._show_lose_screen()

# 🔥 NUEVA FUNCIÓN: Empate
func _on_game_draw() -> void:
	print("\n" + "⚖️".repeat(30))
	print("⚖️  EMPATE")
	print("⚖️".repeat(30))
	
	get_tree().paused = true
	
	# Mostrar pantalla de empate (por ahora usar derrota)
	var active_controller = GameStarter. get_active_player_controller()
	if active_controller and active_controller.has_method("_show_lose_screen"):
		active_controller._show_lose_screen()

# 🔥 MODIFICAR: Guardar referencia
func _show_victory_screen_for_player(controller) -> void:  # 🔥 SIN TIPO ESPECÍFICO
	print("🏆 Mostrando pantalla de victoria para: %s" % controller.player_name)
	
	# 🔥 Solo mostrar pantalla si es PlayerController (humano)
	if controller.has_method("_show_victory_screen") and not controller.is_bot:
		controller._show_victory_screen()
	elif not controller.is_bot:
		# Fallback solo para humanos
		var win_scene = load("res://Scenes/Game/Main/WinScene/WinScene.tscn")
		if win_scene == null:
			print("❌ No se pudo cargar WinScene.tscn")
			return
		
		var win_instance = win_scene.instantiate()
		controller.add_child(win_instance)
		win_instance.z_index = 100
		
		print("✅ Pantalla de victoria mostrada")
	else:
		print("🤖 Bot ganador, no se muestra pantalla de victoria")
