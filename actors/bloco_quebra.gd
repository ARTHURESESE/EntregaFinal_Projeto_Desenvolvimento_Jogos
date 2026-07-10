extends StaticBody2D

var pisado := false

func _iniciar_quebra():
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/rock.wav")
	get_tree().root.add_child(audio)
	audio.play()
	_tremer()
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _tremer():
	var pos_original = position
	var tween1 = create_tween()
	tween1.tween_property(self, "position:x", pos_original.x + 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x - 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x + 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x - 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x, 0.05)
	await tween1.finished
	# Desativa colisão só após o tremor
	$CollisionShape2D.disabled = true
	_particulas()
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween2.finished

func _particulas():
	for i in 8:
		var p = ColorRect.new()
		p.color = Color(0.6, 0.3, 0.1, 1)
		p.size = Vector2(4, 4)
		p.position = global_position
		get_tree().root.add_child(p)
		var angulo = (i / 8.0) * TAU
		var velocidade = Vector2(cos(angulo), sin(angulo)) * randf_range(40, 100)
		var tween = p.create_tween()
		tween.tween_property(p, "position", p.position + velocidade, 0.4)
		tween.parallel().tween_property(p, "modulate:a", 0.0, 0.4)
		tween.tween_callback(p.queue_free)
