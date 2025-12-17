extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer
var current_music: AudioStream = null
var fade_tween: Tween

func play_music(music: AudioStream, loop := true):
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	if current_music == music:
		return
	
	current_music = music
	player.stream = music
	player.play()
	player.stream_paused = false

func stop_music():
	player.stop()
	current_music = null

func pause_music():
	player.stream_paused = true

func resume_music():
	player.stream_paused = false
func stop_music_fade(duration := 1.0):
	if not player.playing:
		return
	
	# Cancelar tween anterior si existe
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(
		player,
		"volume_db",
		-80,
		duration
	)
	
	fade_tween.finished.connect(_on_fade_finished)

func _on_fade_finished():
	player.stop()
	player.volume_db = 0
	current_music = null
