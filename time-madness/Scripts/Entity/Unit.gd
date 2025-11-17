# Unit.gd
extends Entity
class_name Unit

@export var attack_damage: float = 10
@export var attack_range: float = 5.0

@onready var anim_tree: AnimationTree = $Model/AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

var velocity := Vector3.ZERO
var move_target: Vector3
var is_moving = false

func set_animation(anim: String):
	if anim_state != null:
		anim_state.travel(anim)

# ---------------------------------------------------
# move unit
# ---------------------------------------------------
func move_to(target: Vector3, delta: float) -> void:
	if not is_alive:
		return
	
	move_target = target
	is_moving = true
	set_animation("move")

	var direction = (target - global_position)
	direction.y = 0

	if direction.length() > 0.1:
		velocity = direction.normalized() * move_speed
		global_translate(velocity * delta)
	else:
		is_moving = false
		set_animation("idle")

# ---------------------------------------------------
# Attack
# ---------------------------------------------------
func attack(target: Entity) -> void:
	if not is_alive or not target.is_alive:
		return
	
	var dist = global_position.distance_to(target.global_position)
	if dist <= attack_range:
		set_animation("attack")
		target.take_damage(attack_damage)
	else:
		move_to(target.global_position, get_process_delta_time())
