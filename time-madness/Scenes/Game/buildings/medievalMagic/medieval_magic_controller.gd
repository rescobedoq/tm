# Magic.gd
extends Building
class_name Magic
func _ready():
	abilities = [
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalMagicSoldier.png",
			"Entrenar Soldado Mágico",
			"Entrena un soldado que combina combate físico con habilidades mágicas."
		),
		BuildingAbility.new(
			"res://Assets/Images/Portraits/Units/medievalSorcerer.png",
			"Entrenar Hechicero",
			"Entrena un hechicero especializado en magia ofensiva."
		),
	]

	super._ready()

func get_building_scale() -> int:
	return Building.get_building_scale_value("magic")

func get_building_portrait() -> String:
	return Building.get_building_portrait_path("magic")
