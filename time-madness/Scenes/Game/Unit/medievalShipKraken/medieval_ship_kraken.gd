extends Unit
class_name ShipKraken

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalShipKraken.png"

var selection_tween: Tween

func _ready():
	unit_category = "aquatic"
	
	# 🔥 CONFIGURAR AURA ANTES DE LLAMAR A super._ready()
	if aura_controller == null:
		aura_controller = get_node_or_null("Aura")
	
	# 🔥 Configurar el aura con el color del jugador
	if aura_controller and player_owner:
		if "player_index" in player_owner:
			aura_controller. set_aura_color_from_player(player_owner.player_index)
			print("✅ Aura configurada para jugador %d en %s" % [player_owner. player_index, name])
		else:
			print("⚠️ player_owner no tiene player_index en %s" % name)
	else:
		if not aura_controller:
			print("⚠️ No se encontró nodo Aura en %s" % name)
		if not player_owner:
			print("⚠️ player_owner es null en %s" % name)
	
	super._ready()

	unit_type = "Medieval Ship Kraken"
	max_health = 200
	current_health = max_health
	max_magic = 30
	current_magic = max_magic
	attack_damage = 25
	defense = 10
	move_speed = 7
	attack_range = 3.0

	var tex := load(PORTRAIT_PATH)
	if tex:
		portrait = tex
		print("Retrato cargado correctamente:", PORTRAIT_PATH)
	else:
		print("ERROR: No se pudo cargar el retrato:", PORTRAIT_PATH)

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
