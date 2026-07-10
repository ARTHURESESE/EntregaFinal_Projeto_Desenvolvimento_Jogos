extends Control

func _ready():
	$BotaoJogar.pressed.connect(func():
		get_tree().change_scene_to_file("res://world_01.tscn")
	)
	
	$BotaoControles.pressed.connect(func():
		$ControlesOverlay.visible = true
	)
	
	$ControlesOverlay/BotaoFechar.pressed.connect(func():
		$ControlesOverlay.visible = false
	)
