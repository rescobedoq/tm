extends Node

@onready var mediumFontCheckBox: CheckBox = $mediumFontCheckBox
@onready var smallFontCheckBox: CheckBox = $smallFontCheckBox
@onready var largeFontCheckBox: CheckBox = $largeFontCheckBox

var checkboxes: Array[CheckBox]

func _ready():
	checkboxes = [mediumFontCheckBox, smallFontCheckBox, largeFontCheckBox]
	for cb in checkboxes:
		cb.toggled.connect(_on_checkbox_toggled.bind(cb))

	mediumFontCheckBox.set_pressed(true)

func _on_checkbox_toggled(pressed: bool, sender: CheckBox) -> void:
	if not pressed:
		return
	for cb in checkboxes:
		if cb != sender:
			if cb.pressed:
				cb.set_pressed(false)
