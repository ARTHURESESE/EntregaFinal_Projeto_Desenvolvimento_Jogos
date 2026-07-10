extends PointLight2D

func _ready():
	texture = GradientTexture2D.new()
	color = Color(1, 0.84, 0, 1)  # amarelo
	energy = 2.0
	texture_scale = 3.0
	_pulsar()

func _pulsar():
	while true:
		var tween = create_tween()
		tween.tween_property(self, "energy", 4.0, 0.8)
		tween.tween_property(self, "energy", 1.5, 0.8)
		await tween.finished
