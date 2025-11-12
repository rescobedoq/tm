extends Node

var current_user: String = ""  

func set_user(username: String) -> void:
	current_user = username
	print("✅ Usuario seleccionado:", current_user)

func get_user() -> String:
	return current_user
