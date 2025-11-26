# GameStarter.gd (Autoload)
extends Node

signal game_starting(players_data: Array)
signal stage_changed(new_stage: int)  # 🔥 Nueva señal

var configured_players: Array = []

# 🔥 Variable de stage global
var current_stage: int = 1
var max_stages: int = 10

func start_game(players: Array) -> void:
	configured_players = players
	current_stage = 1  # 🔥 Inicializar stage
	emit_signal("game_starting", players)
	print("🎮 Señal game_starting emitida con %d jugadores" % players.size())
	print("⏱️ Stage inicial: %d" % current_stage)

# 🔥 Avanzar al siguiente stage
func next_stage() -> void:
	if current_stage < max_stages:
		current_stage += 1
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage avanzado a: %d" % current_stage)
	else:
		print("⚠️ Ya estás en el último stage")

# 🔥 Establecer un stage específico
func set_stage(stage: int) -> void:
	if stage >= 1 and stage <= max_stages:
		current_stage = stage
		emit_signal("stage_changed", current_stage)
		print("⏱️ Stage establecido a: %d" % current_stage)

# 🔥 Obtener stage actual
func get_current_stage() -> int:
	return current_stage
