# SelectionBox.gd
extends Control
class_name SelectionBox

var start_position: Vector2 = Vector2. ZERO
var end_position: Vector2 = Vector2. ZERO
var is_selecting: bool = false

# Color del rectángulo de selección
var box_color: Color = Color(0, 1, 0, 0.3)  # Verde con transparencia
var border_color: Color = Color(0, 1, 0, 1)  # Verde brillante
var border_width: float = 2.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func start_selection(pos: Vector2) -> void:
	start_position = pos
	end_position = pos
	is_selecting = true
	visible = true
	queue_redraw()

func update_selection(pos: Vector2) -> void:
	if not is_selecting:
		return
	end_position = pos
	queue_redraw()

func end_selection() -> Rect2:
	is_selecting = false
	visible = false
	
	# Calcular el rectángulo de selección
	var rect = Rect2()
	rect.position. x = min(start_position.x, end_position.x)
	rect.position.y = min(start_position.y, end_position.y)
	rect.size.x = abs(end_position.x - start_position.x)
	rect.size.y = abs(end_position.y - start_position.y)
	
	queue_redraw()
	return rect

func cancel_selection() -> void:
	is_selecting = false
	visible = false
	queue_redraw()

func _draw() -> void:
	if not is_selecting:
		return
	
	var rect = Rect2()
	rect.position = Vector2(
		min(start_position.x, end_position. x),
		min(start_position.y, end_position. y)
	)
	rect.size = Vector2(
		abs(end_position.x - start_position.x),
		abs(end_position.y - start_position.y)
	)
	
	# Dibujar el relleno semi-transparente
	draw_rect(rect, box_color)
	
	# Dibujar los bordes (4 líneas)
	# Arriba
	draw_line(
		Vector2(rect.position. x, rect.position.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y),
		border_color,
		border_width
	)
	# Derecha
	draw_line(
		Vector2(rect.position. x + rect.size.x, rect.position.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y),
		border_color,
		border_width
	)
	# Abajo
	draw_line(
		Vector2(rect.position.x + rect.size.x, rect. position.y + rect.size. y),
		Vector2(rect.position.x, rect.position.y + rect. size.y),
		border_color,
		border_width
	)
	# Izquierda
	draw_line(
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		Vector2(rect.position. x, rect.position.y),
		border_color,
		border_width
	)
