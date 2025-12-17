extends Node

@export var initial_players := 6
@export var max_players := 32

var players: Array[AudioStreamPlayer] = []

func _ready():
	for i in range(initial_players):
		_create_player()

func _create_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	add_child(p)
	players.append(p)
	return p

func play_sfx(sound: AudioStream, volume_db := -6.0):
	for p in players:
		if not p.playing:
			p.stream = sound
			p.volume_db = volume_db
			p.play()
			return
	# 2️⃣ si no hay libres → crear otro
	if players.size() < max_players:
		var p := _create_player()
		p.stream = sound
		p.volume_db = volume_db
		p.play()
		return

	# 3️⃣ opcional: forzar reutilización
	players[0].stop()
	players[0].stream = sound
	players[0].volume_db = volume_db
	players[0].play()
