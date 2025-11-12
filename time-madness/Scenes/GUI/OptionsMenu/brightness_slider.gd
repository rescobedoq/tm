extends HSlider

@onready var value_label: Label = $Label

func _ready():
	update_label()
	self.value_changed.connect(Callable(self, "_on_value_changed"))

func _on_value_changed(value: float) -> void:
	update_label()

func update_label() -> void:
	value_label.text = str(round(value * 100) / 100.0)
