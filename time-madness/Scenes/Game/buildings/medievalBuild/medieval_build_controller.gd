extends CharacterBody3D

var building_type: String = ""
var default_scale: Vector3 = Vector3(10, 10, 10)
var proximity_area: Area3D
var is_valid_placement: bool = true
var preview_model: Node3D = null
var player_owner: Node = null  # 🔥 NUEVO

func _ready():
	# 🔥 NO configurar layers aquí
	# Se configurarán cuando se asigne al jugador
	
	await get_tree().process_frame
	_setup_proximity_detection()

# 🔥 NUEVA FUNCIÓN: Configurar para un jugador
func setup_for_player(player: Node):
	player_owner = player
	
	if "player_index" not in player:
		print("❌ Player no tiene player_index")
		return
	
	var player_layer = 2 + player.player_index
	
	# CharacterBody3D del placeholder (no colisiona)
	collision_layer = 0
	collision_mask = 0
	
	# Area3D detecta edificios del mismo jugador
	if proximity_area:
		proximity_area.collision_layer = 0
		proximity_area. collision_mask = 1 << player_layer
		print("✅ BuildingPlaceholder configurado - Detecta layer %d (Jugador %d)" % [player_layer, player.player_index])
	
	# Forzar verificación inicial
	_check_placement_validity()

func _process(_delta):
	# 🔥 VERIFICAR EN CADA FRAME
	_check_placement_validity()

func _check_placement_validity():
	if proximity_area == null:
		is_valid_placement = true
		return
	
	var overlapping_bodies = proximity_area. get_overlapping_bodies()
	var overlapping_areas = proximity_area.get_overlapping_areas()
	
	
	
	# Filtrar para excluirse a sí mismo
	var valid_bodies = []
	for body in overlapping_bodies:
		if body != self:
			valid_bodies.append(body)

	var valid_areas = []
	for area in overlapping_areas:
		if area != proximity_area:
			valid_areas.append(area)
	
	# Actualizar estado
	var was_valid = is_valid_placement
	is_valid_placement = valid_bodies.size() == 0 and valid_areas.size() == 0
	
	# Solo actualizar visual si cambió
	if was_valid != is_valid_placement:
		_update_visual_feedback()

func _setup_proximity_detection():
	proximity_area = get_node_or_null("Area3D")
	
	if proximity_area == null:
		print("❌ No se encontró Area3D en BuildingPlaceholder")
		return
	
	# 🔥 Layers se configuran en setup_for_player()
	
	var collision_shape = proximity_area. get_node_or_null("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = false
	
	_adjust_proximity_radius()
	
	# Señales para optimización
	proximity_area.area_entered.  connect(_on_area_nearby)
	proximity_area.area_exited. connect(_on_area_cleared)
	proximity_area.body_entered.connect(_on_building_nearby)
	proximity_area. body_exited.connect(_on_building_cleared)

func _get_building_scale() -> int:
	return Building.get_building_scale_value(building_type)

func _adjust_proximity_radius():
	if proximity_area == null:
		return
	# 🔹 Aquí podrías ajustar el radio según el tipo de edificio si quieres

func _on_area_nearby(area: Area3D):
	print("🟡 Area3D entró: %s" % area.name)
	if area != proximity_area:
		is_valid_placement = false
		_update_visual_feedback()

func _on_area_cleared(area: Area3D):
	print("🟢 Area3D salió: %s" % area.name)
	pass

func _on_building_nearby(body):
	print("🟡 Body entró: %s (tipo: %s)" % [body.name, body.get_class()])
	if body is CharacterBody3D and body != self:
		is_valid_placement = false
		_update_visual_feedback()

func _on_building_cleared(body):
	print("🟢 Body salió: %s" % body.name)
	pass

# ...  resto del código sin cambios ...

func _update_visual_feedback():
	if preview_model == null:
		return
	
	var color = Color.GREEN if is_valid_placement else Color.RED
	color.a = 0.6
	
	_apply_color_recursive(preview_model, color)

func _apply_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		for i in range(mesh_instance.get_surface_override_material_count()):
			var mat = mesh_instance.get_active_material(i)
			if mat:
				var new_mat = mat.duplicate()
				if new_mat is StandardMaterial3D:
					new_mat.albedo_color = color
					new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mesh_instance.set_surface_override_material(i, new_mat)
	
	for child in node.get_children():
		_apply_color_recursive(child, color)

func set_building_type(b: String) -> void:
	building_type = b
	
	if proximity_area:
		_adjust_proximity_radius()
	
	_create_preview_model()

func _create_preview_model():
	if preview_model:
		preview_model.queue_free()
	
	preview_model = get_build()
	if preview_model:
		if preview_model is CharacterBody3D:
			preview_model.set_physics_process(false)
			preview_model.collision_layer = 0
			preview_model.collision_mask = 0
		
		_remove_physics_recursive(preview_model)

		add_child(preview_model)
		_update_visual_feedback()

func _remove_physics_recursive(node: Node):
	for child in node.get_children():
		if child is CollisionShape3D or child is Area3D or child is CollisionPolygon3D or child is CollisionObject3D:
			child.queue_free()
		else:
			_remove_physics_recursive(child)

func get_build() -> Node3D:
	if building_type == "":
		return null
		
	var scene_path := ""

	match building_type:
		"barracks":
			scene_path = "res://Scenes/Game/buildings/medievalBarracks/medievalBarracks_controller.tscn"
		"dragon":
			scene_path = "res://Scenes/Game/buildings/medievalHatchery/medievalHatchery_controller.tscn"
		"farm":
			scene_path = "res://Scenes/Game/buildings/medivalFarm/medievalFarm_controller.tscn"
		"harbor":
			scene_path = "res://Scenes/Game/buildings/medievalHarbor/medievalHarbor_controller.tscn"
		"magic":
			scene_path = "res://Scenes/Game/buildings/medievalMagic/medievalMagic_controller.tscn"
		"shrine":
			scene_path = "res://Scenes/Game/buildings/medievalShrine/medievalShrine_controller.tscn"
		"smithy":
			scene_path = "res://Scenes/Game/buildings/medievalSmithy/medievalSmithy_controller.tscn"
		"tower":
			scene_path = "res://Scenes/Game/buildings/medievalTower/medievalTower_controller.tscn"
		_:
			return null

	var scene = load(scene_path)
	if not scene:
		return null

	return scene.instantiate()


# 🔥 NUEVA FUNCIÓN: Verificar si la posición actual es válida
func is_placement_valid() -> bool:
	# Forzar una verificación inmediata
	_check_placement_validity()
	return is_valid_placement

# 🔥 NUEVA FUNCIÓN: Verificar en una posición específica
func can_build_at_position(pos: Vector3, player_layer: int) -> bool:
	# Temporal: mover el placeholder a esa posición
	var original_pos = global_position
	global_position = pos
	
	await get_tree().process_frame
	
	# Configurar layers para el jugador específico
	if proximity_area:
		proximity_area.collision_mask = 1 << player_layer
	
	# Verificar colisiones
	_check_placement_validity()
	var result = is_valid_placement
	
	# Restaurar posición
	global_position = original_pos
	
	return result
