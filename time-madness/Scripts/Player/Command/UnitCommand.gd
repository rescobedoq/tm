# UnitCommand.gd
class_name UnitCommand
extends RefCounted

# Clase base para todos los comandos de unidades

func execute() -> void:
	push_error("execute() debe ser implementado en subclases")

func undo() -> void:
	# Opcional: para implementar deshacer comandos
	pass
