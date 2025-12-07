extends Node3D

@onready var aura_mesh: MeshInstance3D = $MeshInstance3D
const AURA_SHADER_PATH = "res://Scenes/Utils/AURA/AURA.gdshader"
func _ready():
	# Validar que el mesh existe
	if aura_mesh == null:
		print("❌ Aura: No se encontró el nodo MeshInstance3D")
		return
	
	# 🔥 Si no hay material_override, crearlo
	if aura_mesh.material_override == null:
		print("⚠️ Aura: Creando ShaderMaterial automáticamente...")
		var shader = load(AURA_SHADER_PATH)
		if shader == null:
			print("❌ Aura: No se pudo cargar el shader desde:", AURA_SHADER_PATH)
			return
		
		var new_material = ShaderMaterial. new()
		new_material. shader = shader
		aura_mesh.material_override = new_material
		print("✅ Aura: ShaderMaterial creado y asignado")
	
	# Validar que es ShaderMaterial
	if not (aura_mesh. material_override is ShaderMaterial):
		print("❌ Aura: El material no es un ShaderMaterial")
		return
	
	print("✅ Aura inicializada correctamente en: %s" % get_parent().name)

func set_aura_color_from_player(player_index: int) -> void:
	if aura_mesh == null:
		print("❌ Aura: aura_mesh es null en set_aura_color_from_player")
		return
	
	var mat := aura_mesh.material_override as ShaderMaterial
	if mat == null:
		print("⚠️ Aura: No hay ShaderMaterial asignado en material_override")
		return

	# Obtener color del equipo desde el singleton Teams
	var color := Teams.get_team_color(player_index)
	
	print("🎨 Aura: Aplicando color del jugador %d: %s" % [player_index, color])

	# Ajustar transparencia
	color.a = 0.35

	# Aplicar al shader
	mat.set_shader_parameter("aura_color", color)
	
	print("✅ Aura configurada con color: %s para %s" % [color, get_parent().name])

# 🔥 FUNCIÓN OPCIONAL: Cambiar intensidad del aura
func set_aura_intensity(intensity: float) -> void:
	var mat := aura_mesh.material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("glow_intensity", intensity)

# 🔥 FUNCIÓN OPCIONAL: Activar/desactivar aura
func set_aura_visible(is_visible: bool) -> void:
	if aura_mesh:
		aura_mesh.visible = is_visible

# 🔥 FUNCIÓN OPCIONAL: Animar el aura (pulso más fuerte)
func pulse_aura(duration: float = 0.5, strength: float = 0.3) -> void:
	var mat := aura_mesh.material_override as ShaderMaterial
	if mat == null:
		return
	
	var original_strength = mat.get_shader_parameter("pulse_strength")
	mat. set_shader_parameter("pulse_strength", strength)
	
	await get_tree().create_timer(duration).timeout
	
	if mat:  # Verificar que aún existe
		mat. set_shader_parameter("pulse_strength", original_strength)
