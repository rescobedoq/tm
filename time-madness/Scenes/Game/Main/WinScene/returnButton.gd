extends Button

func _ready() -> void:
	# Conectar la señal pressed del botón
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("🏠 Regresando a StartingOptions...")
	
	# 🔥 LIMPIAR TODO EL ESTADO DEL GAMESTARTER
	if GameStarter:
		GameStarter.reset_game_state()
	
	# 🔥 CAMBIAR A LA ESCENA DE STARTING OPTIONS
	get_tree().change_scene_to_file("res://Scenes/GUI/SinglePlayer/StartingOptions/startingOptions.tscn"
)
