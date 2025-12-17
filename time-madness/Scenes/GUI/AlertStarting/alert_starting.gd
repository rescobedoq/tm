extends Window

@onready var quit_button: TextureButton = $quitButton

func _ready():
	quit_button.pressed.connect(_on_quit_pressed)
func _on_quit_pressed():
	SoundManager.play_sfx(preload("res://Assets/Sounds/SFX/button1.mp3"))
	hide() 
