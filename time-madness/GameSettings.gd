class_name GameSettings
extends RefCounted 

var language: String = "English"            # sp, en, fr, por
var mouse_sensitivity: float = 1.0    # Valor flotante, por ejemplo 0 - 100
var brightness: float = 1.0            # Valor flotante, 0 - 100
var font_size: String = "medium"       # Small, Medium, Large

func to_dict() -> Dictionary:
	return {
		"language": language,
		"mouse_sensitivity": mouse_sensitivity,
		"brightness": brightness,
		"font_size": font_size
	}

func from_dict(data: Dictionary) -> void:
	language = data.get("language", "en")
	mouse_sensitivity = data.get("mouse_sensitivity", 1.0)
	brightness = data.get("brightness", 1.0)
	font_size = data.get("font_size", "medium")
