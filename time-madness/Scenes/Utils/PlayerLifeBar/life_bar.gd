extends Node3D

# Referencias a los corazones (hijos directos)
@onready var h1 = $h1
@onready var h2 = $h2
@onready var h3 = $h3
@onready var h4 = $h4
@onready var h5 = $h5
@onready var h6 = $h6

# Array para manejar los corazones en orden
var hearts = []
var current_health = 6  # Vidas actuales

func _ready():
	# Agregar los corazones al array en orden (h1 a h6)
	hearts = [h1, h2, h3, h4, h5, h6]
	
	# Configurar la animación inicial de cada corazón
	for heart in hearts:
		var animated_sprite = heart.get_child(0) as AnimatedSprite3D
		if animated_sprite:
			animated_sprite.play("default")  # Cambia "default" por el nombre de tu animación
			# O si tienes animaciones específicas:
			# animated_sprite.play("full")  # Para corazón lleno

func lose_life():
	# Verificar que todavía haya vidas
	if current_health <= 0:
		print("Game Over - No quedan vidas")
		return
	
	# Obtener el índice del corazón a eliminar (de h6 a h1)
	var heart_index = current_health - 1
	var heart_to_lose = hearts[heart_index]
	
	# Obtener el AnimatedSprite3D del corazón
	var animated_sprite = heart_to_lose.get_child(0) as AnimatedSprite3D
	if animated_sprite:
		# Opción 1: Cambiar a animación de corazón vacío
		#animated_sprite.play("empty")  # Cambia por el nombre de tu animación de corazón vacío
		
		# Opción 2: Ocultar el corazón
		heart_to_lose.visible = false
		
		# Opción 3: Eliminar el corazón completamente
		# heart_to_lose.queue_free()
	
	# Reducir la vida actual
	current_health -= 1
	print("Vida perdida.  Vidas restantes: ", current_health)
	
	# Verificar si no quedan vidas
	if current_health <= 0:
		print("Game Over")
		game_over()

func game_over():
	# Aquí puedes agregar lógica de fin de juego
	pass

# Opcional: Función para ganar vida (de h1 a h6)
func gain_life():
	if current_health >= 6:
		print("Vida al máximo")
		return
	
	var heart_to_restore = hearts[current_health]
	var animated_sprite = heart_to_restore.get_child(0) as AnimatedSprite3D
	if animated_sprite:
		animated_sprite.play("default")  # O "full"
		heart_to_restore. visible = true
	
	current_health += 1
	print("Vida ganada. Vidas actuales: ", current_health)

# Para probar - puedes llamar lose_life() desde otro script o conectarlo a una señal
# Ejemplo: lose_life() cuando el jugador recibe daño
