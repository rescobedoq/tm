extends Window

@onready var quit_button: TextureButton = $quitButton

func _ready():
	quit_button.pressed.connect(Callable(self, "_on_quit_pressed"))
func _on_quit_pressed():
	hide() 
