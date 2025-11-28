extends Node3D

#poner una unidad enemiga


func _ready():
	var player1 = $PlayerController
	var player2 = $PlayerController2
	player1.add_unit($MedievalSoldierControler)
	player2.add_unit($MedievalSoldierControler2)
	hide_node_recursive(player2)

# Función recursiva para ocultar un nodo y todos sus hijos
func hide_node_recursive(node: Node) -> void:
	if not node:
		return
	
	# Si el nodo tiene la propiedad "visible", ocultarlo
	if "visible" in node:
		node.visible = false
	
	# Recorrer todos los hijos y llamar la función recursivamente
	for child in node.get_children():
		if child is Node:
			hide_node_recursive(child)
