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

# Nodos de colores
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
	
	battle_log_node. visible = false
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
	current_game_state = GameState. STAGE_PREPARATION
	
	print("\n" + "━".repeat(60))
	print("🛡️  PREPARACIÓN PARA STAGE %d" % current_stage)
	print("━". repeat(60))
	
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_all_player_ui(controller)
	
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance.disable_map()
	
	var game_scene = get_parent()
	var base_map = game_scene. get_node_or_null("BaseMap")
	if base_map:
		base_map.visible = false
	
	battle_log_node.visible = true
	
	if current_stage > 1:
		_show_stage_summary(current_stage - 1)
	
	print("⏳ Esperando 1 segundo antes de iniciar...")
	await get_tree().create_timer(1.0).timeout
	
	battle_log_node.visible = false
	
	_start_stage_playing()

func _start_stage_playing() -> void:
	current_game_state = GameState.STAGE_PLAYING
	battle_log_node.visible = false
	
	print("\n" + "⚔". repeat(30))
	print("⚔️  INICIANDO STAGE %d" % current_stage)
	print("⚔".repeat(30))
	
	if GameStarter.is_battle_stage:
		_show_battle_stage()
	else:
		_show_base_stage()
	
	GameStarter.start_stage_timer()
	print("🎮 ¡Stage en progreso!")

func _show_battle_stage() -> void:
	print("⚔️ Stage PAR → BATTLE STAGE")

	GameStarter.battle_mode_started.emit()
	
	for controller in GameStarter.get_player_controllers():
		if not is_instance_valid(controller):
			continue
		
		_hide_all_player_ui(controller)
		
		var game_scene = get_parent()
		var base_map = game_scene.get_node_or_null("BaseMap")
		if base_map:
			controller.disable_node_3d_recursive(base_map)
			base_map.visible = false
	
	print("\n🚀 Iniciando transferencia de unidades al Battle Map...")
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			controller.transfer_attack_units_to_battle_map()
			await get_tree().process_frame
	
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			controller.set_battle_mode_layers(true)
			await get_tree().process_frame
		
	var active_controller = GameStarter.get_active_player_controller()
	if active_controller and is_instance_valid(active_controller):
		var rts = active_controller.get_node_or_null("RtsController")
		if rts:
			rts.visible = true
			rts.set_process(true)
			rts.set_physics_process(true)
			rts.set_process_input(true)
			rts. set_process_unhandled_input(true)
			print("  ✅ RtsController habilitado: %s" % active_controller.player_name)
		
		var unit_hud = active_controller. get_node_or_null("UnitHud")
		var team_hud = active_controller.get_node_or_null("TeamHud")
		var info_hud = active_controller.get_node_or_null("InfoHud")
		
		if unit_hud: unit_hud.visible = true
		if team_hud: team_hud.visible = true
		if info_hud: info_hud.visible = true
		
		var player_hud = active_controller.get_node_or_null("PlayerHud")
		if player_hud:
			player_hud.visible = false
			print("  ❌ PlayerHud OCULTO en batalla: %s" % active_controller. player_name)
		
		var light = active_controller.get_node_or_null("DirectionalLight3D")
		if light:
			light.visible = true
			print("  💡 DirectionalLight3D habilitado: %s" % active_controller.player_name)
		
		var camera = active_controller.get_node_or_null("RtsController/Elevation/Camera3D")
		if camera:
			camera.make_current()
			print("  ✅ Cámara activada para batalla: %s" % active_controller.player_name)
		
		print("  ✅ HUD de batalla visible para: %s" % active_controller.player_name)
	
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("enable_map"):
			GameStarter.battle_map_instance.enable_map()
		print("✅ Battle Map HABILITADO")

func _show_base_stage() -> void:
	GameStarter.battle_mode_ended.emit()
	print("🏠 Stage IMPAR → BASE STAGE")
	
	for controller in GameStarter. get_player_controllers():
		if is_instance_valid(controller):
			controller.set_battle_mode_layers(false)
	
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance.disable_map()
		print("  ❌ Battle Map DESHABILITADO")
	
	print("🔔 Las unidades que fueron transferidas a Battle Map NO serán retornadas al BaseMap.")
	
	var active_controller = GameStarter. get_active_player_controller()
	
	if not active_controller or not is_instance_valid(active_controller):
		print("❌ ERROR: No se encontró active_controller")
		return
	
	print("✅ Active controller encontrado: %s" % active_controller.player_name)
	
	var game_scene = get_parent()
	var base_map = game_scene.get_node_or_null("BaseMap")
	
	if base_map:
		base_map.visible = true
		active_controller.enable_node_3d_recursive(base_map)
		print("  ✅ BaseMap activado y visible: %s" % active_controller. player_name)
		
		var attack_area = base_map.get_node_or_null("AttackArea3D")
		if attack_area and attack_area.has_method("activate"):
			attack_area.activate()
			print("  ✅ AttackArea reactivada")
	else:
		print("  ❌ ERROR: No se encontró BaseMap en GameScene")
		return
	
	var rts = active_controller.get_node_or_null("RtsController")
	if rts:
		rts.visible = true
		rts.set_process(true)
		rts. set_physics_process(true)
		rts.set_process_input(true)
		rts.set_process_unhandled_input(true)
		print("  ✅ RtsController habilitado: %s" % active_controller.player_name)
	
	var player_hud = active_controller. get_node_or_null("PlayerHud")
	if player_hud:
		player_hud.visible = true
		print("  ✅ PlayerHud visible: %s" % active_controller.player_name)
	
	var unit_hud = active_controller. get_node_or_null("UnitHud")
	var team_hud = active_controller.get_node_or_null("TeamHud")
	var info_hud = active_controller.get_node_or_null("InfoHud")
	
	if unit_hud: unit_hud.visible = true
	if team_hud: team_hud.visible = true
	if info_hud: info_hud.visible = true
	
	var light = active_controller.get_node_or_null("DirectionalLight3D")
	if light:
		light.visible = true
		print("  💡 DirectionalLight3D habilitado: %s" % active_controller.player_name)
	
	var camera = active_controller.get_node_or_null("RtsController/Elevation/Camera3D")
	if camera:
		camera.make_current()
		print("  ✅ Cámara activada para: %s" % active_controller. player_name)
	
	print("  ✅ HUD completo visible para: %s" % active_controller.player_name)

	for controller in GameStarter.get_player_controllers():
		if controller != active_controller and is_instance_valid(controller):
			_hide_all_player_ui(controller)

func _hide_all_player_ui(controller) -> void:
	if not is_instance_valid(controller):
		return
	
	var rts = controller.get_node_or_null("RtsController")
	if rts:
		rts.visible = false
		rts.set_process(false)
		rts.set_physics_process(false)
		rts.set_process_input(false)
		rts. set_process_unhandled_input(false)
	
	var unit_hud = controller.get_node_or_null("UnitHud")
	var team_hud = controller.get_node_or_null("TeamHud")
	var player_hud = controller.get_node_or_null("PlayerHud")
	var info_hud = controller.get_node_or_null("InfoHud")
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
	
	var game_scene = get_parent()
	var base_map = game_scene.get_node_or_null("BaseMap")
	
	if base_map:
		var attack_area = base_map. get_node_or_null("AttackArea3D")
		if attack_area and attack_area.has_method("deactivate"):
			attack_area.deactivate()
			print("🔥 AttackArea desactivada para capturar unidades")
	
	print("🔥 Ocultando HUD de todos los jugadores...")
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_all_player_ui(controller)
			print("  ❌ HUD oculto para: %s" % controller.player_name)
	
	print("🔥 Ocultando mapas...")
	if GameStarter.battle_map_instance != null:
		if GameStarter.battle_map_instance.has_method("disable_map"):
			GameStarter.battle_map_instance.disable_map()
	
	if base_map:
		base_map.visible = false
		
		for controller in GameStarter.get_player_controllers():
			if is_instance_valid(controller):
				controller.disable_node_3d_recursive(base_map)
	
	_show_stage_summary(finished_stage)
	
	_start_stage_preparation()

# === RESUMEN DEL STAGE ===
func _show_stage_summary(stage_number: int) -> void:
	print("\n📊 RESUMEN DEL STAGE %d:" % stage_number)
	print("=".repeat(60))
	
	for controller in GameStarter. get_player_controllers():
		if not is_instance_valid(controller):
			continue
		
		var attack_count = controller.attack_units.size() if "attack_units" in controller else 0
		var defense_count = controller.defense_units.size() if "defense_units" in controller else 0
		var battle_count = controller.battle_units.size() if "battle_units" in controller else 0
		
		print("  %s:" % controller.player_name)
		print("    🗡️  Ataque: %d" % attack_count)
		print("    🛡️  Defensa: %d" % defense_count)
		print("    ⚔️  Batalla: %d" % battle_count)
	
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

# === CASTILLOS EN BATTLE MAP ===
func _create_battle_map_castles() -> void:
	print("\n🏰 Creando castillos en Battle Map...")
	
	if GameStarter.battle_map_instance == null:
		print("❌ Battle Map no existe en GameStarter")
		return
	
	var battle_map = GameStarter.battle_map_instance
	print("✅ Battle Map encontrado: %s" % battle_map.name)
	
	var player_bases = battle_map.get_node_or_null("PlayerBases")
	if player_bases == null:
		print("❌ No se encontró PlayerBases en Battle Map")
		return
	
	print("✅ PlayerBases encontrado")
	
	const CASTLE_SCENE = preload("res://Scenes/Game/buildings/medievalCastle/medievalCastle.tscn")
	const LIFE_BAR_SCENE = preload("res://Scenes/Utils/PlayerLifeBar/LifeBar.tscn")
	const Y_OFFSET = 21.0
	
	var controllers = GameStarter.get_player_controllers()
	var players_data = GameStarter.configured_players
	
	for i in range(controllers.size()):
		var controller = controllers[i]
		var marker_name = "player%d" % (i + 1)
		
		var marker = player_bases.get_node_or_null(marker_name)
		
		if marker == null:
			print("  ❌ No se encontró marker: %s" % marker_name)
			continue
		
		var area_name = "Player%dArea3D" % (i + 1)
		var player_area = battle_map.get_node_or_null("PlayerAreaBase/" + area_name)
		if player_area == null:
			player_area = battle_map.get_node_or_null("Node3D/" + area_name)
		if player_area == null:
			player_area = battle_map.get_node_or_null(area_name)
		
		if player_area and player_area is Area3D:
			player_area.set_meta("player_controller", controller)
			print("  ✅ Área '%s' asignada a %s" % [area_name, controller.player_name])
		
		var castle = CASTLE_SCENE.instantiate()
		castle.name = "BattleCastle_Player%d" % (i + 1)
		
		var spawn_pos = marker.global_position
		spawn_pos.y = Y_OFFSET
		
		battle_map.add_child(castle)
		GameStarter.all_battle_builds.append(castle)
		await get_tree().process_frame
		
		castle.global_position = spawn_pos
		
		var life_bar = LIFE_BAR_SCENE.instantiate()
		life_bar. name = "LifeBar_Player%d" % (i + 1)
		battle_map.add_child(life_bar)
		
		await get_tree().process_frame
		
		life_bar.global_position = spawn_pos
		controller.battle_life_bar = life_bar
		
		if i < players_data.size():
			var player_data = players_data[i]
			var team_color = Teams.get_team_color(player_data.team)
			_apply_color_to_castle(castle, team_color)
			print("  🎨 Color aplicado: Equipo %d" % player_data.team)
		
		print("  ✅ Castillo '%s' creado para %s" % [castle.name, controller.player_name])
	
	print("\n🏰 Proceso de creación de castillos finalizado\n")

func _apply_color_to_castle(castle: Node, color: Color) -> void:
	_apply_color_to_meshes(castle, color)

func _apply_color_to_meshes(node: Node, color: Color) -> void:
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		var tint_color = color.lerp(Color. WHITE, 0.6)
		tint_color.a = 1.0
		
		var surface_count = mesh_instance.mesh.get_surface_count() if mesh_instance.mesh else 0
		
		for i in range(surface_count):
			var original_material = mesh_instance.get_surface_override_material(i)
			
			if original_material == null:
				original_material = mesh_instance.mesh.surface_get_material(i)
			
			var new_material: StandardMaterial3D
			
			if original_material and original_material is StandardMaterial3D:
				new_material = original_material. duplicate()
			else:
				new_material = StandardMaterial3D.new()
			
			if new_material. albedo_texture:
				new_material.albedo_color = tint_color
			else:
				var original_color = new_material.albedo_color
				new_material.albedo_color = original_color * tint_color
			
			mesh_instance.set_surface_override_material(i, new_material)
	
	for child in node.get_children():
		_apply_color_to_meshes(child, color)

# === VICTORIA ===
func check_victory_conditions() -> void:
	print("\n🏆 Verificando condiciones de victoria...")
	
	var alive_players: Array = []
	var alive_teams: Array = []
	
	for controller in GameStarter. get_player_controllers():
		if is_instance_valid(controller) and not controller.is_defeated:
			alive_players.append(controller)
			
			var player_data = _get_player_data_for_controller(controller)
			if player_data and player_data.team not in alive_teams:
				alive_teams.append(player_data.team)
	
	if alive_teams.size() == 1:
		var winning_team = alive_teams[0]
		print("🏆 ¡EQUIPO %d HA GANADO!" % winning_team)
		_on_team_victory(winning_team, alive_players)
		return
	
	if alive_players.size() == 0:
		print("⚖️ EMPATE")
		_on_game_draw()
		return

func _get_player_data_for_controller(controller) -> PlayerData:
	var players_data = GameStarter.configured_players
	var controllers = GameStarter.get_player_controllers()
	
	var index = controllers.find(controller)
	if index >= 0 and index < players_data.size():
		return players_data[index]
	
	return null

func _on_team_victory(winning_team: int, winning_players: Array) -> void:
	print("\n🏆 VICTORIA DEL EQUIPO %d" % winning_team)
	get_tree().paused = true
	
	var active_controller = GameStarter.get_active_player_controller()
	
	if active_controller in winning_players:
		_show_victory_screen_for_player(active_controller)
	else:
		if active_controller and active_controller.has_method("_show_lose_screen"):
			active_controller._show_lose_screen()

func _on_game_draw() -> void:
	print("\n⚖️ EMPATE")
	get_tree().paused = true

func _show_victory_screen_for_player(controller) -> void:
	if controller.has_method("_show_victory_screen") and not controller.is_bot:
		controller._show_victory_screen()
