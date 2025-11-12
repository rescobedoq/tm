class_name PlayerProfile
extends RefCounted

var options: GameSettings = GameSettings.new()

var username: String = ""
var statistics: String = ""      # Por ahora solo un string
var game_history: String = ""    # Por ahora solo un string
var saved_games: String = ""     # Por ahora solo un string

func to_dict() -> Dictionary:
	return {
		"username": username,
		"options": options.to_dict(),
		"statistics": statistics,
		"game_history": game_history,
		"saved_games": saved_games
	}


func from_dict(data: Dictionary) -> void:
	username = data.get("username", "")	
	if data.has("options"):
		options.from_dict(data["options"])
	else:
		options = GameSettings.new()
	
	statistics = data.get("statistics", "")
	game_history = data.get("game_history", "")
	saved_games = data.get("saved_games", "")
