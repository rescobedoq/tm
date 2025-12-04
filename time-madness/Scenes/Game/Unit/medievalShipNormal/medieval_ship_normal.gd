extends Unit
class_name ShipNormal

@onready var anim_player = $medievalShipNormal/AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var selection_circle = $Selection
@onready var aura_controller = $Aura  # 🔥 Referencia directa al nodo Aura

const PORTRAIT_PATH := "res://Assets/Images/Portraits/Units/medievalShipNormal.png"
const GHOST_SHIP_SCENE := "res://Scenes/Game/Unit/medievalShipGhost/medievalShipGhost_controller.tscn"
const KRAKEN_SHIP_SCENE := "res://Scenes/Game/Unit/medievalShipKraken/medievalShipKraken_controller.tscn"

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
	unit_type = "Medieval Ship Normal"
	max_health = 200
	current_health = max_health
	max_magic = 100
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
	
	abilities = [
		UnitAbility. new(
			"res://Assets/Images/HUD/icons/ghostIcon.jpg",
			"Ghost Ship",
			"Evolve into Ghost Ship.\nCosto: 1 energia",
			"ghostShip_ability" 
		),
		UnitAbility.new(
			"res://Assets/Images/HUD/icons/krakenIcon.png",
			"Kraken Ship",
			"Evolve into Kraken Ship.\nCosto: 1 energia",
			"krakenShip_ability" 
		),
	]

func play_idle():
	print(">>> play_idle CALLED <<<")

func play_move():
	print(">>> play_move CALLED <<<")

func play_attack():
	print(">>> play_attack CALLED <<<")
	
func play_death():
	print(">>> play_death CALLED <<<")

# ===================================================
# 🔥 HABILIDADES DE EVOLUCIÓN
# ===================================================
func use_ability(ability: UnitAbility) -> void:
	if ability. ability_id == "ghostShip_ability":
		_evolve_to_ghost_ship()
	elif ability.ability_id == "krakenShip_ability":
		_evolve_to_kraken_ship()
	else:
		super.use_ability(ability)

func _evolve_to_ghost_ship() -> void:
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Ghost Ship")
		return
	
	current_magic -= 1
	print("👻 EVOLUCIONANDO A GHOST SHIP!")
	
	_perform_evolution(GHOST_SHIP_SCENE, "Ghost Ship")

func _evolve_to_kraken_ship() -> void:
	if current_magic < 1:
		print("⚠️ No hay suficiente energía para Kraken Ship")
		return
	
	current_magic -= 1
	print("🐙 EVOLUCIONANDO A KRAKEN SHIP!")
	
	_perform_evolution(KRAKEN_SHIP_SCENE, "Kraken Ship")

func _perform_evolution(evolution_scene_path: String, evolution_name: String) -> void:
	var evolution_scene = load(evolution_scene_path)
	if evolution_scene == null:
		print("❌ No se pudo cargar la escena: %s" % evolution_scene_path)
		return
	
	# Guardar datos
	var saved_position = global_position
	var saved_rotation = rotation
	var saved_owner = player_owner
	
	# Deseleccionar si estaba seleccionado
	if saved_owner and saved_owner.selected_unit == self:
		saved_owner.deselect_current_unit()
	
	# Tween de hundimiento
	var disappear_tween = create_tween()
	disappear_tween.set_parallel(true)
	disappear_tween.tween_property(self, "global_position:y", saved_position.y - 5.0, 0.5)
	disappear_tween.tween_property(self, "rotation_degrees:z", rotation_degrees.z + 15, 0.5)
	await disappear_tween.finished
	
	# Remover del owner
	if saved_owner:
		if self in saved_owner.units:
			saved_owner.units.erase(self)
		if self in saved_owner.attack_units:
			saved_owner.attack_units.erase(self)
		if self in saved_owner.defense_units:
			saved_owner.defense_units.erase(self)
		if saved_owner.has_method("_update_units_labels"):
			saved_owner._update_units_labels()
	
	# Ocultar barco original
	visible = false
	
	# Instanciar nueva unidad
	var evolved_ship = evolution_scene.instantiate()
	get_tree().current_scene.add_child(evolved_ship)
	
	# Esperar un frame para que se inicialice
	await get_tree().process_frame
	
	# Posicionar más alto y escalar pequeño al inicio
	var start_position = saved_position + Vector3(0, 8.0, 0) # +8 unidades en Y
	evolved_ship.global_position = start_position
	evolved_ship.rotation = saved_rotation
	evolved_ship.scale = Vector3(0.5, 0.5, 0.5)  # empezar más pequeño
	
	# Asignar propietario y agregar al owner
	if saved_owner and evolved_ship is Unit:
		evolved_ship.player_owner = saved_owner
		saved_owner.add_unit(evolved_ship)
	
	# Tween para emerger + scale
	var appear_tween = evolved_ship.create_tween()
	appear_tween.set_parallel(true)
	appear_tween.tween_property(evolved_ship, "global_position:y", saved_position.y, 0.7)
	appear_tween.tween_property(evolved_ship, "scale", Vector3(1, 1, 1), 0.7)
	await appear_tween.finished
	
	# Eliminar barco original
	queue_free()
