extends AnimatableBody2D

var velocidade := 35.0
var distancia := 30.0
var direcao := 1
var pos_inicial: Vector2

func _ready():
	pos_inicial = position
	sync_to_physics = true

func _physics_process(delta):
	position.x += velocidade * direcao * delta
	
	if position.x > pos_inicial.x + distancia:
		position.x = pos_inicial.x + distancia
		direcao = -1
	elif position.x < pos_inicial.x - distancia:
		position.x = pos_inicial.x - distancia
		direcao = 1
