extends Node
class_name AIBrain

var bot: BotController

func _ready():
	bot = get_parent() # BotController es el padre
	print("🧠 AIBrain conectado al bot:", bot.player_name)

func process_ai(delta):
	if not bot.is_battle_mode:
		process_economic_ai()
	else:
		process_combat_ai()

# ========================
# 🌾 IA ECONÓMICA
# ========================
func process_economic_ai():
	# Preparar prompt para pedirle a la IA
	var prompt = generate_economy_prompt()

	# Aquí llamas a GPT/tu IA externa y recibes un COMANDO
	var action = call_external_ai(prompt)

	# Ejecutar la acción
	execute_action(action)

# ========================
# ⚔️ IA DE COMBATE
# ========================
func process_combat_ai():
	var prompt = generate_combat_prompt()
	var action = call_external_ai(prompt)
	execute_action(action)

# ========================
# 🧩 GENERACIÓN DE PROMPTS
# ========================
func generate_combat_prompt() -> String:
	var text = "Estado actual del bot:\n"
	text += "- Unidades: %s\n" % str(bot.battle_units)
	text += "- Enemigos visibles: %s\n" % str(GameStarter.all_battle_units)
	text += "- Vidas: %d/%d\n" % [bot.current_lives, bot.max_lives]
	text += "Da una instrucción clara. Ej: MOVE_ALL x,y,z o ATTACK unit_id"
	return text

func generate_economy_prompt() -> String:
	var text = "Economía del bot:\n"
	text += "- Oro: %d\n" % bot.gold
	text += "- Recursos: %d\n" % bot.resources
	text += "- Upkeep: %d/%d\n" % [bot.upkeep, bot.maxUpKeep]
	text += "Da una instrucción: PRODUCE soldier o BUILD farm"
	return text

# ========================
# 🎮 EJECUCIÓN DE ACCIONES
# ========================
func execute_action(action: String):
	# Haces un parser simple del resultado de la IA
	var args = action.split(" ")

	match args[0]:
		"MOVE_ALL":
			bot.move_all_attack_units_to_position(Vector3(args[1].to_float(), 0, args[2].to_float()))

		"ATTACK":
			var unit_id = int(args[1])
			var target_id = int(args[2])
			var unit = bot.get_unit_by_id(unit_id)
			var target = bot.get_enemy_by_id(target_id)
			bot.attack_enemy(unit, target)

		"PRODUCE":
			bot.create_unit(args[1])

		"BUILD":
			bot.create_building(args[1])

		_:
			print("❌ Acción IA desconocida:", action)

# (simular llamada a IA si aún no conectas GPT)
func call_external_ai(prompt: String) -> String:
	print("PROMPT ENVIADO A IA:\n", prompt)
	return "MOVE_ALL 10 5" # Simulación temporal
