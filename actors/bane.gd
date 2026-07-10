extends CharacterBody2D
const SPEED = 30.0
const GRAVITY = 980.0
@onready var anim = $AnimatedSprite2D
var direcao = 1
var distancia = 20.0
var pos_inicial: Vector2
var pode_machucar: bool = true
func _ready():
	pos_inicial = global_position
	anim.play("direita")
	anim.scale = Vector2(0.5, 0.5)
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity.x = SPEED * direcao
	
	move_and_slide()
	# Inverte ao atingir a distância
	if global_position.x > pos_inicial.x + distancia:
		direcao = -1
	elif global_position.x < pos_inicial.x - distancia:
		direcao = 1
	if direcao == -1:
		anim.play("esquerda")
	else:
		anim.play("direita")
	if pode_machucar:
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is CharacterBody2D:
				var batman = col.get_collider()
				if batman.has_method("die") and not batman.is_dead:
					pode_machucar = false
					var hud = get_tree().root.find_child("HUD", true, false)
					if hud:
						hud.perder_vida()
					await get_tree().create_timer(2.0, false).timeout
					pode_machucar = true
