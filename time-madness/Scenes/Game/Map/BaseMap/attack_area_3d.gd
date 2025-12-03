extends Area3D

var is_active: bool = true

func _ready():
	collision_layer = 0
	
	# 🔥 DETECTAR TODAS LAS CAPAS DE JUGADORES (2-7)
	collision_mask = 0
	for i in range(6):  # 6 jugadores posibles
		var player_layer = 2 + i
		collision_mask |= 1 << player_layer
	
	print("✅ AttackArea configurada para detectar TODOS los jugadores (mask: %d)" % collision_mask)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not is_active:
		return
		
	if body is Unit:
		print("🔥 Unidad ENTRÓ al área de ataque: %s (Dueño: %s)" % [
			body.unit_type,
			body.player_owner.player_name if body.player_owner else "sin dueño"
		])
		
		# 🔥 Obtener el dueño de la unidad (no el jugador activo)
		var owner = body.player_owner
		if owner and owner.has_method("move_unit_to_attack"):
			owner.move_unit_to_attack(body)
		else:
			print("⚠️ La unidad no tiene player_owner válido")

func _on_body_exited(body):
	if not is_active:
		return
		
	if body is Unit:
		print("🚶 Unidad SALIÓ del área de ataque: %s (Dueño: %s)" % [
			body.unit_type,
			body.player_owner.player_name if body.player_owner else "sin dueño"
		])
		
		# 🔥 Obtener el dueño de la unidad (no el jugador activo)
		var owner = body.player_owner
		if owner and owner.has_method("move_unit_to_defense"):
			owner.move_unit_to_defense(body)
		else:
			print("⚠️ La unidad no tiene player_owner válido")

func deactivate():
	is_active = false
	monitoring = false
	print("❌ AttackArea desactivada")

func activate():
	is_active = true
	monitoring = true
	print("✅ AttackArea activada")
