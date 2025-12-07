extends Node
class_name AIBrain

var bot: BotController

func _ready():
	bot = get_parent() # BotController es el padre
	print("🧠 AIBrain conectado al bot:", bot.player_name)

# 🔥 FUNCIÓN PRINCIPAL: Obtener todas las acciones disponibles
func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	
	# ========================================
	# 📋 CONTEXTO DEL MAPA
	# ========================================
	var context = _get_map_context()
	actions.append("=== CONTEXTO DEL MAPA ===")
	for line in context:
		actions.append(line)
	
	actions.append("=== ACCIONES DISPONIBLES ===")
	
	# ========================================
	# 🏗️ CONSTRUCCIÓN DE EDIFICIOS
	# ========================================
	var building_types = ["barracks", "dragon", "farm", "harbor", "magic", "shrine", "smithy", "tower"]
	
	for building_type in building_types:
		if _can_build(building_type):
			var cost = BuildingCosts.get_cost(building_type)
			if cost != null:
				actions.append("BUILD: %s (Gold: %d, Resources: %d)" % [building_type, cost. gold, cost.resources])
	
	# ========================================
	# 🪖 ENTRENAMIENTO DE UNIDADES
	# ========================================
	# Obtener habilidades de todos los edificios que tenemos
	if bot.buildings != null:
		for building in bot.buildings:
			if not is_instance_valid(building):
				continue
			
			var abilities = BuildingAbilities.get_building_ability(building.building_type)
			if abilities != null:
				for ability in abilities:
					var unit_id = ability["id"]
					
					if _can_train_unit(unit_id):
						var cost = UnitCosts.get_cost(unit_id)
						if cost != null:
							actions.append("TRAIN: %s from %s (Gold: %d, Resources: %d, Upkeep: %d)" % [
								ability["name"],
								building.building_type,
								cost.gold,
								cost.resources,
								cost.upkeep
							])
	
	# ========================================
	# 🎯 ACCIONES DE COMBATE (solo en batalla)
	# ========================================
	if bot.is_battle_mode and bot.battle_units != null and bot.battle_units.size() > 0:
		# Obtener enemigos
		var enemies: Array[Entity] = []
		if GameStarter != null and GameStarter.all_battle_units != null:
			for unit in GameStarter.all_battle_units:
				if not is_instance_valid(unit) or not unit.is_alive:
					continue
				
				if unit.player_owner and unit.player_owner != bot:
					enemies.append(unit)
		
		if enemies.size() > 0:
			# Para cada unidad propia, puede atacar a cualquier enemigo
			for own_unit in bot.battle_units:
				if not is_instance_valid(own_unit) or not own_unit. is_alive:
					continue
				
				# Encontrar enemigo más cercano
				if bot.has_method("get_nearest_enemy_unit"):
					var nearest_enemy = bot.get_nearest_enemy_unit(own_unit. global_position)
					if nearest_enemy:
						actions.append("ATTACK: Unit %s → Enemy %s (Distance: %.1f)" % [
							own_unit.unit_type,
							nearest_enemy.unit_type,
							own_unit.global_position.distance_to(nearest_enemy.global_position)
						])
			
			# Mover unidades a posiciones estratégicas
			for own_unit in bot.battle_units:
				if not is_instance_valid(own_unit) or not own_unit.is_alive:
					continue
				
				actions.append("MOVE: Unit %s to random position" % own_unit.unit_type)
	
	return actions

# ========================================
# 📋 CONTEXTO DEL MAPA
# ========================================
func _get_map_context() -> Array[String]:
	var context: Array[String] = []
	
	if GameStarter != null and GameStarter.all_battle_units != null:
		context.append("Total units in battle: %d" % GameStarter.all_battle_units.size())
	context.append("--- MY UNITS ---")
	
	# Mis unidades
	if bot.battle_units != null:
		for unit in bot.battle_units:
			if is_instance_valid(unit) and unit.is_alive:
				context.append("  Unit: %s | Position: (%.1f, %.1f, %.1f) | HP: %. 0f/%.0f" % [
					unit.unit_type,
					unit.global_position.x,
					unit.global_position.y,
					unit.global_position.z,
					unit.current_health,
					unit.max_health
				])
	
	context.append("--- ENEMY UNITS ---")
	
	# Unidades enemigas
	if GameStarter != null and GameStarter.all_battle_units != null:
		for unit in GameStarter.all_battle_units:
			if is_instance_valid(unit) and unit.is_alive:
				if unit.player_owner and unit.player_owner != bot:
					var owner_name = unit.player_owner. player_name if unit.player_owner else "Unknown"
					context.append("  Unit: %s | Owner: %s | Position: (%.1f, %.1f, %.1f) | HP: %.0f/%.0f" % [
						unit.unit_type,
						owner_name,
						unit.global_position. x,
						unit.global_position.y,
						unit. global_position.z,
						unit.current_health,
						unit.max_health
					])
	
	return context

# ========================================
# 🏗️ VERIFICAR SI PUEDE CONSTRUIR EDIFICIO
# ========================================
func _can_build(building_type: String) -> bool:
	if BuildingCosts == null:
		return false
	
	var cost = BuildingCosts.get_cost(building_type)
	
	if cost == null or cost.size() == 0:
		return false
	
	# Verificar recursos
	if bot.gold < cost.gold or bot.resources < cost.resources:
		return false
	
	# 🔥 RESTRICCIONES DE ORDEN DE CONSTRUCCIÓN
	match building_type:
		"castle":
			# El castillo ya se crea al inicio
			return false
		
		"barracks", "farm":
			# Disponibles desde el inicio
			return true
		
		"harbor":
			# Requiere al menos 1 barracks
			return _has_building("barracks")
		
		"smithy":
			# Requiere barracks
			return _has_building("barracks")
		
		"tower":
			# Requiere barracks
			return _has_building("barracks")
		
		"magic":
			# Requiere smithy
			return _has_building("smithy")
		
		"shrine":
			# Requiere magic school
			return _has_building("magic")
		
		"dragon":
			# Requiere shrine
			return _has_building("shrine")
	
	return true

# ========================================
# 🪖 VERIFICAR SI PUEDE ENTRENAR UNIDAD
# ========================================
func _can_train_unit(unit_id: String) -> bool:
	if UnitCosts == null:
		return false
	
	var cost = UnitCosts.get_cost(unit_id)
	
	if cost == null or cost.size() == 0:
		return false
	
	# Verificar recursos
	if bot.gold < cost. gold:
		return false
	
	if bot.resources < cost.resources:
		return false
	
	# Verificar upkeep
	if bot.upkeep + cost.upkeep > bot.maxUpKeep:
		return false
	
	return true

# ========================================
# 🔍 VERIFICAR SI TIENE UN EDIFICIO
# ========================================
func _has_building(building_type: String) -> bool:
	if bot.buildings == null:
		return false
	
	for building in bot.buildings:
		if is_instance_valid(building) and building.building_type == building_type:
			return true
	return false
