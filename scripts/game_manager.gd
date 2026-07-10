extends Node

var vidas: int = 3
var tempo_total: float = 0.0
var tempo_restante_fase: float = 120.0
var cena_atual: String = "res://world_01.tscn"
var musica: AudioStreamPlayer = null

func _ready():
	musica = AudioStreamPlayer.new()
	musica.stream = load("res://assets/dark1.mp3")
	musica.volume_db = -10.0
	add_child(musica)
	musica.play()
	musica.finished.connect(func():
		musica.play()
	)

func parar_musica():
	if musica:
		musica.stop()

func tocar_musica():
	if musica and not musica.playing:
		musica.play()
