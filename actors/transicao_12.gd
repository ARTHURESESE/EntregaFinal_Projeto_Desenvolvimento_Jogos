extends Control

func _ready():
	GameManager.tempo_restante_fase = 120.0
	GameManager.vidas = 3
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/level.wav")
	add_child(audio)
	audio.play()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://world_02.tscn")
