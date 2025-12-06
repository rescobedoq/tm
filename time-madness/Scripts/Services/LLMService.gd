extends Node

# 🌐 Configuración de la API
const API_BASE_URL = "http://localhost:8000/"
const API_ENDPOINT = "/api/game/prompt"

var http_request: HTTPRequest
var pending_callbacks: Dictionary = {}  # Almacena callbacks por request_id

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	print("🌐 LLMService singleton inicializado")
	
	# 🧪 PRUEBA: Hacer una petición automática
	await get_tree().create_timer(2.0).timeout
	test_request()

# 🧪 Función de prueba
func test_request():
	print("\n🚀 EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEnviando petición de prueba...")
	
	var test_data = {
		"available_actions": "Train Soldier, Train Archer, Build Farm",
		"game_context": "Player has 500 gold, 200 resources. Castle and Barracks built.",
		"max_tokens": 1000,
		"temperature": 0.7
	}
	
	send_prompt_request(test_data, func(response):
		print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅ Respuesta de prueba recibida:")
		print(JSON.stringify(response, "\t"))
	)

# 🔥 FUNCIÓN PRINCIPAL: Enviar petición al LLM con callback
func send_prompt_request(data: Dictionary, callback: Callable = Callable()):
	var url = API_BASE_URL + API_ENDPOINT
	var json_string = JSON.stringify(data)
	
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
	]
	
	print("📤 Enviando petición a: %s" % url)
	print("📦 Datos: %s" % json_string)
	
	# Guardar el callback para cuando llegue la respuesta
	var request_id = Time.get_ticks_msec()
	if callback. is_valid():
		pending_callbacks[request_id] = callback
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		push_error("❌ Error al enviar petición: %s" % error)
		pending_callbacks.erase(request_id)

# 📥 Callback cuando se completa la petición
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("\n📥 Respuesta recibida (código: %d)" % response_code)
	
	if response_code != 200:
		print("❌ Error HTTP %d" % response_code)
		print("Cuerpo: %s" % body.get_string_from_utf8())
		_trigger_callbacks({})
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("❌ Error al parsear JSON")
		print("Raw: %s" % body.get_string_from_utf8())
		_trigger_callbacks({})
		return
	
	var response_data = json.data
	print("✅ Respuesta exitosa")
	
	# Ejecutar todos los callbacks pendientes
	_trigger_callbacks(response_data)

# 🔔 Ejecutar callbacks
func _trigger_callbacks(response_data: Dictionary):
	for callback in pending_callbacks.values():
		if callback.is_valid():
			callback.call(response_data)
	
	pending_callbacks.clear()
