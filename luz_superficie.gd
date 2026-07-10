extends Node2D

var alpha := 0.0
var crescendo := true

func _ready():
	position = Vector2(0, 0)

func _process(delta):
	if crescendo:
		alpha += delta * 0.3
		if alpha >= 1.0:
			crescendo = false
	else:
		alpha -= delta * 0.3
		if alpha <= 0.5:
			crescendo = true
	queue_redraw()

func _draw():
	var topo_y := -3500.0
	var centro_x := 300.0  # centro da abertura
	var abertura := 600.0  # largura do cone na base
	var altura := 250.0    # comprimento do cone

	# Cone que sai de um ponto e se abre para baixo
	var pontos = PackedVector2Array([
		Vector2(centro_x, topo_y),                        # ponto do topo (origem)
		Vector2(centro_x - abertura, topo_y + altura),    # base esquerda
		Vector2(centro_x + abertura, topo_y + altura),    # base direita
	])

	var cores = PackedColorArray([
		Color(1.0, 0.9, 0.4, alpha * 0.7),   # topo - mais forte
		Color(1.0, 0.9, 0.4, 0.0),           # base esquerda - transparente
		Color(1.0, 0.9, 0.4, 0.0),           # base direita - transparente
	])

	draw_polygon(pontos, cores)

	draw_polygon(pontos, cores)
