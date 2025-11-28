extends Area3D

func _ready():
	collision_layer = 0       
	collision_mask = 1 << 1   
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	print("✅ Area3D configurada para detectar unidades de ataque")

func _on_body_entered(body):
	if body is Unit:
		print("🔥 Unidad ENTRÓ al área de ataque:", body.unit_type)
		
		var player = _get_player_owner()
		if player:
			player.move_unit_to_attack(body)

func _on_body_exited(body):
	if body is Unit:
		print("🚶 Unidad SALIÓ del área de ataque:", body.unit_type)
		
		var player = _get_player_owner()
		if player:
			player. move_unit_to_defense(body)

# 🔥 Buscar el PlayerController (dueño del área)
func _get_player_owner():
	var parent = get_parent()
	
	# Buscar hacia arriba en el árbol hasta encontrar PlayerController
	while parent != null:
		if parent is PlayerController:
			return parent
		parent = parent.get_parent()
	
	print("❌ No se encontró PlayerController para este Area3D")
	return null
