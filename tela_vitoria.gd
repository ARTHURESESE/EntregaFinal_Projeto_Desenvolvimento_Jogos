extends CanvasLayer

func _ready():
	var minutos = int(GameManager.tempo_total) / 60
	var segundos = int(GameManager.tempo_total) % 60

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var titulo = Label.new()
	titulo.text = "GOTHAM ESTÁ SALVA!"
	titulo.add_theme_font_size_override("font_size", 56)
	titulo.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	titulo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.position = Vector2(50, -150)
	add_child(titulo)

	var tempo_label = Label.new()
	tempo_label.text = "Tempo total: %02d:%02d" % [minutos, segundos]
	tempo_label.add_theme_font_size_override("font_size", 36)
	tempo_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	tempo_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tempo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tempo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tempo_label.position = Vector2(50, 0)
	add_child(tempo_label)

	var btn = Button.new()
	btn.text = "Jogar Novamente"
	btn.add_theme_font_size_override("font_size", 28)
	btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	btn.position.y = -100
	btn.pressed.connect(func():
		GameManager.vidas = 3
		GameManager.tempo_total = 0.0
		get_tree().change_scene_to_file("res://world_01.tscn")
	)
	add_child(btn)
