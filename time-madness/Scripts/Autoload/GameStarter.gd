extends Node

signal game_starting(players_data: Array)

var configured_players: Array = []

func start_game(players: Array) -> void:
	configured_players = players
	emit_signal("game_starting", players)
	print("🎮 Señal game_starting emitida con %d jugadores" % players.size())
