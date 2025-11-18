# Entity.gd
extends Node3D
class_name Entity

# ---------------------------------------------------
# Common parameters
# ---------------------------------------------------
@export var entity_name: String = "Entidad"
@export var health: float = 100
@export var max_health: float = 100
@export var move_speed: float = 10.0
@export var is_alive: bool = true

# Graphic node
@onready var model: Node3D = $Model

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		
		if camera == null:
			return
			
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		
		var result = space_state.intersect_ray(query)
		
		if result and result.collider == self:
			_on_click()

func _on_click():
	print("Click en: ", entity_name)
# ---------------------------------------------------
# Basic functions!
# ---------------------------------------------------

# Take damage
func take_damage(amount: float) -> void:
	if not is_alive:
		return
	health -= amount
	if health <= 0:
		die()

# being healed/repair
func heal(amount: float) -> void:
	if not is_alive:
		return
	health = min(health + amount, max_health)

# death!
func die() -> void:
	is_alive = false
	# Por defecto desactiva la entidad visualmente
	if model:
		model.visible = false
	print("%s ha sido destruida" % name)

# movement
func move_to(target_position: Vector3, delta: float) -> void:
	if not is_alive:
		return
	var direction = (target_position - global_position)
	if direction.length() > 0.1:
		direction = direction.normalized()
		global_translate(direction * move_speed * delta)
