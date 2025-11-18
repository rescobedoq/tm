extends Node3D
class_name Entity

# En Unit.gd o Entity.gd
@export var player_owner: PlayerController

@onready var selection: Node3D = get_node_or_null("Selection")

# ---------------------------------------------------------
#   SELECCIÓN
# ---------------------------------------------------------
var _selected_internal: bool = false

@export var selected: bool:
	set(value):
		_selected_internal = value
		_update_selection_visual()
	get:
		return _selected_internal

# ---------------------------------------------------------
#   ATRIBUTOS
# ---------------------------------------------------------
@export var entity_name := "Entidad"
@export var health := 100.0
@export var max_health := 100.0
@export var move_speed := 10.0
@export var is_alive := true

func _ready():
	set_process_input(true)
	_update_selection_visual()


func _update_selection_visual():
	if selection:
		selection.visible = selected
	else:
		print("[%s] No tiene nodo Selection." % name)


# ---------------------------------------------------------
#   CLICK PARA SELECCIONAR
# ---------------------------------------------------------
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		var camera := get_viewport().get_camera_3d()
		if camera == null:
			return

		var from := camera.project_ray_origin(event.position)
		var to := from + camera.project_ray_normal(event.position) * 1000

		var result := get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(from, to)
		)

		if result and result.collider == self:
			select()


func select():
	selected = true

func deselect():
	selected = false


# ---------------------------------------------------------
#   VIDA / DAÑO
# ---------------------------------------------------------
func take_damage(amount: float) -> void:
	if not is_alive:
		return
	health -= amount
	if health <= 0:
		die()

func heal(amount: float) -> void:
	if not is_alive:
		return
	health = min(health + amount, max_health)

func die() -> void:
	is_alive = false
	print("%s ha sido destruida" % name)
