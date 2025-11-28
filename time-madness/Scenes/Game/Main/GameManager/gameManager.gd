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
	INTRO_VIDEO,      # Mostrando video inicial
	STAGE_PREPARATION, # Mostrando HUD entre stages (7 segundos)
	STAGE_PLAYING     # Jugando el stage actual
}

var current_game_state: GameState = GameState.INTRO_VIDEO
var current_stage: int = 1

# === SISTEMA DE PARPADEO ===
var blink_timer: float = 0.0
var blink_interval: float = 0.5
var blink_state: bool = true

# === INICIALIZACIÓN ===
func _ready() -> void:
	# Inicializar arrays
	player_nodes = [player1, player2, player3, player4, player5, player6]
	color_nodes = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
	
	# Ocultar todo inicialmente
	battle_log_node.visible = false
	for color in color_nodes:
		color.visible = false
	
	# Conectar señales de GameStarter
	GameStarter.stage_changed.connect(_on_stage_changed)
	GameStarter.stage_time_over.connect(_on_stage_time_over)
	
	# Iniciar video intro
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
	current_game_state = GameState. INTRO_VIDEO
	video_player.visible = true
	video_player.play()
	video_player.finished.connect(_on_video_finished)
	print("🎬 Reproduciendo video de introducción...")

func _on_video_finished() -> void:
	video_player.visible = false
	print("✅ Video terminado")
	
	# Configurar jugadores y mostrar HUD
	_setup_players()
	current_stage = GameStarter.get_current_stage()
	_update_stage_colors()
	
	# 🔥 Instanciar los PlayerControllers UNA SOLA VEZ al inicio
	_spawn_player_controllers()
	
	# Iniciar primera preparación
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
			player_node. get_node("Faction").text = player_data. race
			player_node.get_node("ColorRect"). color = _get_team_color(player_data.team)
			
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

func _get_team_color(team_id: int) -> Color:
	match team_id:
		0: return Color.RED
		1: return Color. BLUE
		2: return Color. GREEN
		3: return Color. YELLOW
		4: return Color.PURPLE
		5: return Color. ORANGE
		_: return Color.WHITE

# 🔥 INSTANCIAR CONTROLLERS UNA SOLA VEZ
func _spawn_player_controllers() -> void:
	print("\n🎮 Instanciando PlayerControllers (UNA SOLA VEZ)...")
	
	for controller in GameStarter.get_player_controllers():
		add_child(controller)
		_hide_player_ui(controller)
		print("  ✅ %s instanciado" % controller.player_name)
	if GameStarter.battle_map_instance != null:
		GameStarter.battle_map_instance.visible = false
	
	print("✅ Todos los PlayerControllers listos\n")

# === GESTIÓN DE STAGES ===
func _start_stage_preparation() -> void:
	current_game_state = GameState. STAGE_PREPARATION
	battle_log_node.visible = true
	
	print("\n" + "━".repeat(60))
	print("🛡️  PREPARACIÓN PARA STAGE %d" % current_stage)
	print("━". repeat(60))
	
	# Mostrar resumen del stage anterior
	if current_stage > 1:
		_show_stage_summary(current_stage - 1)
	
	print("⏳ Esperando 7 segundos antes de iniciar...")
	await get_tree().create_timer(7.0).timeout
	
	_start_stage_playing()

func _start_stage_playing() -> void:
	current_game_state = GameState. STAGE_PLAYING
	battle_log_node.visible = false
	
	print("\n" + "⚔". repeat(30))
	print("⚔️  INICIANDO STAGE %d" % current_stage)
	print("⚔".repeat(30))
	
	# 🔥 ALTERNAR ENTRE BASE MAP Y BATTLE MAP
	if GameStarter.is_battle_stage:
		_show_battle_map()
	else:
		_show_base_maps()
	
	# 🔥 INICIAR EL TIMER
	GameStarter.start_stage_timer()
	
	print("🎮 ¡Stage en progreso!")

# 🔥 MOSTRAR BATTLE MAP (stages pares)
func _show_battle_map() -> void:
	print("⚔️ Stage PAR → Mostrando Battle Map compartido")
	
	# Ocultar todos los BaseMaps de los jugadores
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_player_ui(controller)
	
	# Mostrar el BattleMap persistente
	if GameStarter.battle_map_instance != null:
		GameStarter. battle_map_instance.visible = true
		print("✅ Battle Map visible")

# 🔥 MOSTRAR BASE MAPS (stages impares)
func _show_base_maps() -> void:
	print("🏠 Stage IMPAR → Mostrando BaseMap individual")
	
	# Ocultar BattleMap
	if GameStarter.battle_map_instance != null:
		GameStarter.battle_map_instance. visible = false
	
	# Mostrar solo el UI del jugador activo
	var active_controller = GameStarter. get_active_player_controller()
	if active_controller and is_instance_valid(active_controller):
		_show_player_ui(active_controller)
		print("✅ UI del jugador activo visible")
	
	# Ocultar UI de los demás
	for controller in GameStarter. get_player_controllers():
		if controller != active_controller:
			_hide_player_ui(controller)

# 🔥 MOSTRAR UI DEL JUGADOR
func _show_player_ui(controller) -> void:
	if not is_instance_valid(controller):
		return
		
	controller.get_node("RtsController").visible = true
	controller.get_node("UnitHud").visible = true
	controller. get_node("TeamHud"). visible = true
	controller.get_node("PlayerHud").visible = true
	controller.get_node("BaseMap").visible = true
	controller.get_node("InfoHud").visible = true

# 🔥 OCULTAR UI DEL JUGADOR
func _hide_player_ui(controller) -> void:
	if not is_instance_valid(controller):
		return
	controller.get_node("RtsController").visible = false
	controller.get_node("UnitHud").visible = false
	controller.get_node("TeamHud").visible = false
	controller.get_node("PlayerHud").visible = false
	controller.get_node("BaseMap").visible = false
	controller.get_node("InfoHud").visible = false

# === SEÑALES DE GAMESTARTER ===
func _on_stage_changed(new_stage: int) -> void:
	current_stage = new_stage
	_update_stage_colors()
	print("🎨 Indicadores visuales actualizados al stage: %d" % current_stage)

func _on_stage_time_over(finished_stage: int) -> void:
	print("\n⏰ TIEMPO DEL STAGE %d AGOTADO" % finished_stage)
	
	# Mostrar resumen
	_show_stage_summary(finished_stage)
	
	# Ocultar todo (se mostrará en el siguiente stage según tipo)
	if GameStarter.battle_map_instance != null:
		GameStarter.battle_map_instance.visible = false
	
	for controller in GameStarter.get_player_controllers():
		if is_instance_valid(controller):
			_hide_player_ui(controller)
	
	# Iniciar preparación del siguiente stage
	_start_stage_preparation()

# === RESUMEN DEL STAGE ===
func _show_stage_summary(stage_number: int) -> void:
	print("\n📊 RESUMEN DEL STAGE %d:" % stage_number)
	print("=".repeat(60))
	
	for controller in GameStarter. get_player_controllers():
		if not is_instance_valid(controller):
			continue
			
		if "attack_units" in controller:
			var units = controller.attack_units
			if units.size() == 0:
				print("  %s: Sin unidades de ataque" % controller.player_name)
			else:
				var unit_names = []
				for u in units:
					if is_instance_valid(u):
						unit_names.append(u.name)
				print("  %s: %s" % [controller.player_name, ", ".join(unit_names)])
		else:
			print("  %s: [Sin datos de unidades]" % controller.player_name)
	
	print("=".repeat(60))

# === SISTEMA DE COLORES ===
func _update_stage_colors() -> void:
	for i in range(color_nodes.size()):
		if i < current_stage - 1:
			color_nodes[i]. visible = true
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
			color_nodes[current_color_index]. visible = blink_state
