# UnitCommandInvoker.gd
class_name UnitCommandInvoker
extends RefCounted

# Invocador de comandos - maneja la ejecución de comandos

var command_history: Array[UnitCommand] = []
var current_index: int = -1

func execute_command(command: UnitCommand) -> void:
	if command == null:
		return
	
	command. execute()
	
	# Agregar al historial
	command_history. append(command)
	current_index += 1

func undo() -> void:
	if current_index < 0 or command_history.is_empty():
		return
	
	var command = command_history[current_index]
	command. undo()
	current_index -= 1

func clear_history() -> void:
	command_history.clear()
	current_index = -1
