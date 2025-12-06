extends Node
class_name AIBrain

var bot: BotController

func _ready():
	bot = get_parent() # BotController es el padre
	print("🧠 AIBrain conectado al bot:", bot.player_name)
