extends Control

func _ready():
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/gameover.wav")
	add_child(audio)
	audio.play()

	$BotaoJogar.pressed.connect(func():
		GameManager.vidas = 3
		GameManager.tempo_restante_fase = 120.0
		GameManager.tocar_musica()
		get_tree().change_scene_to_file("res://world_01.tscn")
	)
