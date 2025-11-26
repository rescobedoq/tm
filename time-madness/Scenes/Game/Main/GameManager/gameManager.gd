# GameManager.gd
extends Node
class_name GameManager

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

@onready var player1 = $Node/Players/Player1
@onready var player2 = $Node/Players/Player2
@onready var player3 = $Node/Players/Player3
@onready var player4 = $Node/Players/Player4
@onready var player5 = $Node/Players/Player5
@onready var player6 = $Node/Players/Player6

var player_nodes: Array = []

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

@onready var battle_log_node = $Node

# (sincronizada con GameStarter)
var time: int = 1 

var blink_timer: float = 0.0
var blink_interval: float = 0.5
var blink_state: bool = true

func _ready() -> void:
	battle_log_node.visible = false
	
	player_nodes = [player1, player2, player3, player4, player5, player6]
	color_nodes = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
	
	for color in color_nodes:
		color.visible = false
	
	# 🔥 Conectar señal de cambio de stage
	GameStarter.stage_changed.connect(_on_stage_changed)
	
	video_player.play()
	video_player.finished.connect(_on_video_finished)

func _process(delta: float) -> void:
	_update_color_blink(delta)

func _update_color_blink(delta: float) -> void:
	blink_timer += delta
	
	if blink_timer >= blink_interval:
		blink_timer = 0.0
		blink_state = not blink_state
		
		if time >= 1 and time <= color_nodes.size():
			color_nodes[time - 1].visible = blink_state

func _update_colors() -> void:
	for i in range(color_nodes.size()):
		if i < time - 1: 
			color_nodes[i]. visible = true
		elif i == time - 1: 
			pass
		else:  
			color_nodes[i].visible = false

func _setup_players() -> void:
	var players_data = GameStarter. configured_players
	
	print("📋 Configurando %d jugadores en Battle Log" % players_data.size())
	
	for i in range(player_nodes.size()):
		if i < players_data.size():
			var player_data = players_data[i]
			var player_node = player_nodes[i]
			
			player_node.get_node("Name").text = player_data.player_name
			player_node. get_node("Faction").text = player_data.race
			
			var color_rect = player_node.get_node("ColorRect")
			color_rect. color = _get_team_color(player_data.team)
			
			var status_node = player_node.get_node("Status")
			if status_node is Label:
				status_node.text = "-"
			
			player_node.visible = true
			
			print("✅ Jugador %d: %s | Facción: %s | Equipo: %d" % [i+1, player_data.player_name, player_data.race, player_data. team])
		else:
			player_nodes[i].visible = false

func _get_team_color(team_id: int) -> Color:
	match team_id:
		0: return Color.RED
		1: return Color.BLUE
		2: return Color.GREEN
		3: return Color.YELLOW
		4: return Color.PURPLE
		5: return Color.ORANGE
		_: return Color.WHITE

func _on_video_finished() -> void:
	video_player. visible = false
	_setup_players()
	
	time = GameStarter.get_current_stage()
	_update_colors()
	
	battle_log_node.visible = true
	
	print("🎮 Listo para iniciar la partida - Stage: %d" % time)
	print("⏳ Esperando 7 segundos antes de iniciar la siguiente fase...")
	await get_tree().create_timer(7.0).timeout
	_start_game()

func _on_stage_changed(new_stage: int) -> void:
	time = new_stage
	_update_colors()
	print("🎨 Visual actualizado a stage: %d" % time)
	
func _start_game() -> void:
	print("🚀 Iniciando partida...")
	var active_controller = GameStarter.get_active_player_controller()
	if active_controller == null:
		print("❌ Error: No se encontró PlayerController activo")
		return
		
	for controller in GameStarter.get_player_controllers():
		add_child(controller)
		if not controller.is_active_player:
			controller.get_node("RtsController").visible = false
			controller.get_node("UnitHud").visible = false
			controller.get_node("TeamHud").visible = false
			controller.get_node("PlayerHud").visible = false
			controller.get_node("BaseMap").visible = false
		print("✅ PlayerController añadido: %s | Visible: %s" % [controller. player_name, controller.is_active_player])	
	
	battle_log_node.visible = false
	print("🎮 ¡Juego iniciado!  Controlando a: %s" % active_controller. player_name)
