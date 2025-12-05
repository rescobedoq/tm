extends Building
class_name Castle


func _ready():
	building_type = "castle"
	super._ready() 



func get_building_scale() -> int:
	return Building.get_building_scale_value("barracks")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("castle")
	
func _train_slave() -> void:
	var player = _get_player_owner()
	if player == null:
		print("❌ No se encontró PlayerController")
		return

	if not player.has_method("add_worker"):
		print("❌ PlayerController no tiene método add_worker()")
		return

	player.add_worker()
