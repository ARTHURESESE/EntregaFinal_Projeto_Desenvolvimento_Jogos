extends ColorRect

func _ready():
	_pulsar()

func _pulsar():
	while true:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.4, 1.5)
		tween.tween_property(self, "modulate:a", 0.15, 1.5)
		await tween.finished
