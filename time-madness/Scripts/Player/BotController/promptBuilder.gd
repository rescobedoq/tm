extends Node
class_name PromptBuilder

var bot: BotController
var ai_brain: AIBrain

func _ready():
	bot = get_parent()
	ai_brain = bot.get_node("AIBrain")
	
	if ai_brain == null:
		push_error("❌ PromptBuilder: No se encontró AIBrain")
		return
	
	print("📝 PromptBuilder conectado al bot:", bot.player_name)

# 🔥 Construir el prompt completo
func build_prompt() -> String:
	var prompt = ""
	
	prompt += "=== GAME STATE ===\n"
	prompt += _get_game_state_text()
	prompt += "\n\n"
	
	var actions = ai_brain.get_available_actions()
	for action in actions:
		prompt += action + "\n"
	
	prompt += "\n"
	prompt += "=== INSTRUCTIONS ===\n"
	prompt += "You are an AI playing a strategy game. Based on the current game state and available actions, decide what action to take.\n"
	prompt += "Respond with ONLY the action you want to execute, exactly as written in the AVAILABLE ACTIONS list.\n"
	prompt += "Example response: BUILD: barracks (Gold: 100, Resources: 50)\n"
	
	return prompt

# 📊 Obtener el estado del juego como texto
func _get_game_state_text() -> String:
	var state = ""
	state += "Player: %s\n" % bot.player_name
	state += "Gold: %d\n" % bot.gold
	state += "Resources: %d\n" % bot.resources
	state += "Upkeep: %d / %d\n" % [bot.upkeep, bot.maxUpKeep]
	state += "\n"
	
	state += "Buildings:\n"
	if bot.buildings != null and bot.buildings.size() > 0:
		for building in bot.buildings:
			if is_instance_valid(building):
				state += "  - %s\n" % building.building_type
	else:
		state += "  (none)\n"
	
	state += "\n"
	
	state += "Battle Units:\n"
	if bot. battle_units != null and bot. battle_units.size() > 0:
		for unit in bot.battle_units:
			if is_instance_valid(unit) and unit.is_alive:
				state += "  - %s | HP: %. 0f/%.0f | Pos: (%.1f, %.1f, %.1f)\n" % [
					unit.unit_type,
					unit.current_health,
					unit.max_health,
					unit.global_position.x,
					unit.global_position.y,
					unit.global_position.z
				]
	else:
		state += "  (none)\n"
	
	return state

# 🔄 Cada 60 segundos, enviar petición al LLM
var time_accumulator: float = 0.0

func _process(delta: float):
	time_accumulator += delta
	if time_accumulator >= 1.0:
		time_accumulator = 0.0
		
		# 🔥 Llamar al servicio singleton
		if LLMService != null:
			var request_data = {
				"available_actions": _get_available_actions_string(),
				"game_context": _get_game_state_text(),
				"max_tokens": 1000,
				"temperature": 0.7
			}
			
			# Enviar petición con callback
			LLMService.send_prompt_request(request_data, _on_llm_response)
		else:
			push_error("❌ LLMService no está disponible como singleton")

# 📝 Convertir acciones disponibles a string
func _get_available_actions_string() -> String:
	var actions = ai_brain.get_available_actions()
	var actions_str = ""
	for action in actions:
		actions_str += action + ", "
	return actions_str. trim_suffix(", ")

# 📥 Callback cuando llega la respuesta del LLM
func _on_llm_response(response_data: Dictionary):
	print("\n🎯 [%s] Respuesta del LLM recibida:" % bot.player_name)
	print(JSON.stringify(response_data, "\t"))
	
	# Aquí procesarías la acción sugerida
	if response_data.has("action"):
		print("✅ Acción a ejecutar: %s" % response_data["action"])
		# bot.execute_action(response_data["action"])
