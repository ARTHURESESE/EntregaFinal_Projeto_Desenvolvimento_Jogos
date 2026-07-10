extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 980.0

@onready var anim = $AnimatedSprite2D
@onready var camera = $Camera2D

var is_dead: bool = false
var tempo_caindo: float = 0.0
var estava_no_ar: bool = false
var tempo_no_ar: float = 0.0
var primeiro_pouso: bool = true
var pulos_restantes: int = 2
var stamina: float = 0.0
var stamina_max: float = 100.0
var stamina_recarga: float = 6.67
var camera_pos_inicial: Vector2
var tremor_tempo: float = 0.0
var tremor_forca: float = 0.0

func _ready():
	floor_snap_length = 0.0
	floor_stop_on_slope = false
	randomize()
	camera_pos_inicial = camera.position
	camera.position_smoothing_speed = 6.0
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/jumpsound.wav")
	audio.name = "JumpSound"
	audio.volume_db = -10.0
	add_child(audio)
	
	var audio_fall = AudioStreamPlayer.new()
	audio_fall.stream = load("res://assets/falling.wav")
	audio_fall.name = "FallSound"
	add_child(audio_fall)

	var audio_die = AudioStreamPlayer.new()
	audio_die.stream = load("res://assets/die.wav")
	audio_die.name = "DieSound"
	add_child(audio_die)

	var audio_walk = AudioStreamPlayer.new()
	audio_walk.stream = load("res://assets/footstep.wav")
	audio_walk.name = "WalkSound"
	audio_walk.volume_db = -16.0
	add_child(audio_walk)

func _physics_process(delta):
	_atualizar_tremor_camera(delta)

	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true

	if is_dead:
		return

	stamina = min(stamina + stamina_recarga * delta, stamina_max)

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > 0:
			tempo_caindo += delta
			estava_no_ar = true
			tempo_no_ar += delta
			pulos_restantes = 0
			if tempo_caindo >= 1.0:
				die()
				return
	else:
		pulos_restantes = 2
		if estava_no_ar and tempo_no_ar > 0.2 and not primeiro_pouso:
			$FallSound.play()
			_criar_particulas(Color(0.42, 0.38, 0.31, 0.75), 7, Vector2(16, 4), 0.35)
			_iniciar_tremor(1.8, 0.12)
		if estava_no_ar:
			primeiro_pouso = false
		estava_no_ar = false
		tempo_no_ar = 0.0
		tempo_caindo = 0.0

	var direction = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		direction = -1.0
	elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		direction = 1.0

	velocity.x = direction * SPEED

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("move_jump")) and pulos_restantes > 0:
		if pulos_restantes == 1:
			if stamina >= stamina_max:
				velocity.y = JUMP_VELOCITY * 0.65
				stamina = 0.0
				pulos_restantes -= 1
				$JumpSound.play()
				$WalkSound.stop()
				_criar_particulas(Color(1.0, 0.76, 0.12, 0.9), 10, Vector2(22, 8), 0.42)
				_iniciar_tremor(2.2, 0.14)
		else:
			velocity.y = JUMP_VELOCITY
			pulos_restantes -= 1
			$JumpSound.play()
			$WalkSound.stop()
			_criar_particulas(Color(0.36, 0.34, 0.3, 0.75), 6, Vector2(18, 5), 0.32)

	var hud = get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("atualizar_stamina"):
		hud.atualizar_stamina(stamina / stamina_max)

	move_and_slide()

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var colisor = col.get_collider()
		if colisor is CharacterBody2D and colisor != self and not is_dead:
			die()
			return

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var normal = col.get_normal()
		if normal.y < -0.5:
			var colisor = col.get_collider()
			if colisor is StaticBody2D and not (colisor is AnimatableBody2D):
				if colisor.has_method("_iniciar_quebra") and not colisor.pisado:
					colisor.pisado = true
					colisor._iniciar_quebra()

	if not is_on_floor() and velocity.y > 0:
		anim.play("caindo")
		$WalkSound.stop()
	elif direction < 0:
		anim.play("esquerda")
		if is_on_floor() and not $WalkSound.playing:
			$WalkSound.play()
		elif not is_on_floor():
			$WalkSound.stop()
	elif direction > 0:
		anim.play("direita")
		if is_on_floor() and not $WalkSound.playing:
			$WalkSound.play()
		elif not is_on_floor():
			$WalkSound.stop()
	else:
		anim.play("parado")
		$WalkSound.stop()

func die():
	is_dead = true
	$WalkSound.stop()
	_iniciar_tremor(5.0, 0.25)
	_criar_particulas(Color(0.95, 0.72, 0.08, 0.9), 14, Vector2(30, 14), 0.55)
	await get_tree().create_timer(0.1).timeout
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		hud.call_deferred("perder_vida")
	else:
		get_tree().call_deferred("reload_current_scene")

func _iniciar_tremor(forca: float, duracao: float):
	tremor_forca = max(tremor_forca, forca)
	tremor_tempo = max(tremor_tempo, duracao)

func _atualizar_tremor_camera(delta: float):
	if not camera:
		return

	if tremor_tempo <= 0.0:
		camera.position = camera.position.lerp(camera_pos_inicial, min(delta * 10.0, 1.0))
		return

	tremor_tempo -= delta
	var intensidade = tremor_forca * clamp(tremor_tempo / 0.25, 0.0, 1.0)
	camera.position = camera_pos_inicial + Vector2(randf_range(-intensidade, intensidade), randf_range(-intensidade, intensidade))

	if tremor_tempo <= 0.0:
		tremor_forca = 0.0

func _criar_particulas(cor: Color, quantidade: int, espalhamento: Vector2, duracao: float):
	var cena = get_tree().current_scene
	if not cena:
		return

	for i in quantidade:
		var tamanho = randf_range(3.0, 6.0)
		var p = Polygon2D.new()
		p.color = cor
		p.polygon = PackedVector2Array([
			Vector2(-tamanho, -tamanho),
			Vector2(tamanho, -tamanho),
			Vector2(tamanho, tamanho),
			Vector2(-tamanho, tamanho)
		])
		cena.add_child(p)

		var origem = global_position + Vector2(randf_range(-9.0, 9.0), -4.0 + randf_range(-2.0, 2.0))
		p.global_position = origem

		var direcao = Vector2(randf_range(-1.0, 1.0), randf_range(-0.9, 0.25)).normalized()
		var destino = p.global_position + Vector2(direcao.x * randf_range(espalhamento.x * 0.4, espalhamento.x), direcao.y * randf_range(espalhamento.y * 0.5, espalhamento.y))
		var tween = p.create_tween()
		tween.tween_property(p, "global_position", destino, duracao)
		tween.parallel().tween_property(p, "rotation", randf_range(-PI, PI), duracao)
		tween.parallel().tween_property(p, "modulate:a", 0.0, duracao)
		tween.tween_callback(p.queue_free)
