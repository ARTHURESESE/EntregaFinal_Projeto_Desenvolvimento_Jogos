extends Control

func _ready():
	$BotaoMenu.pressed.connect(func():
		GameManager.vidas = 3
		GameManager.tempo_restante_fase = 120.0
		GameManager.tempo_total = 0.0
		GameManager.tocar_musica()
		get_tree().change_scene_to_file("res://actors/menu_inicial.tscn")
	)
