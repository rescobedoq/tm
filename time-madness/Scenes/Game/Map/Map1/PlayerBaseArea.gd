extends Area3D
class_name PlayerBaseArea

# Esta área detecta cuando unidades enemigas entran a la base del jugador

func _ready() -> void:
	# 🔥 CONFIGURAR LAYERS DEL ÁREA
	collision_layer = 0  # El área no está en ninguna capa
	collision_mask = 1 << 8  # Detecta Layer 9 (unidades en batalla)
	
	# Conectar señal de entrada de cuerpos
	body_entered.connect(_on_body_entered)
	print("🛡️ Área de base configurada: %s (Mask: %d)" % [name, collision_mask])
func _on_body_entered(body: Node3D) -> void:
	# Verificar que sea una unidad
	if not body is Unit:
		return
	
	var unit = body as Unit
	
	# Verificar que la unidad esté viva
	if not unit.is_alive:
		return
	
	# Obtener el controller del área
	var area_controller = get_meta("player_controller", null)
	
	if area_controller == null:
		print("⚠️ Área %s no tiene controller asignado" % name)
		return
	
	# Verificar si es enemigo
	if unit.player_owner != area_controller:
		print("💥 Unidad enemiga '%s' de %s entró a base de %s" % [
			unit.name,
			unit.player_owner.player_name if unit.player_owner else "desconocido",
			area_controller.player_name
		])
		
		# 🔥 LLAMADA DIRECTA: Restar vida al jugador
		area_controller.lose_life()
		
		# 🔥 MATAR LA UNIDAD
		if unit.has_method("_trigger_death"):
			unit._trigger_death()
		else:
			unit.queue_free()
		
		print("  💀 Unidad enemiga eliminada")
