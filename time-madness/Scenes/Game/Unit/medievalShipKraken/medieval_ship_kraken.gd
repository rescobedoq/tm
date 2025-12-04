extends Unit
class_name ShipKraken

var selection_tween: Tween

func _ready():
	unit_category = "aquatic"
	portrait_path = "res://Assets/Images/Portraits/Units/medievalShipKraken.png"
	unit_type = "Medieval Ship Kraken"
	super._ready()

func play_idle():
	print(">>> play_idle CALLED <<<")
	# No tiene animación

func play_move():
	print(">>> play_move CALLED <<<")
	# No tiene animación

func play_attack():
	print(">>> play_attack CALLED <<<")
	# No tiene animación
func play_death():
	print(">>> play_death CALLED <<<")
	# No tiene animación
