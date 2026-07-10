extends StaticBody2D

var pisado := false

func _iniciar_quebra():
	await get_tree().create_timer(0.5).timeout
	_tremer()
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _tremer():
	var pos_original = position
	var tween1 = create_tween()
	tween1.tween_property(self, "position:x", pos_original.x + 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x - 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x + 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x - 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x + 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x - 4, 0.05)
	tween1.tween_property(self, "position:x", pos_original.x, 0.05)
	await tween1.finished
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween2.finished
