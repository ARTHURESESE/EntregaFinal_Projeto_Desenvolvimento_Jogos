extends Area2D

var transitioning = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if transitioning:
		return
	if body is CharacterBody2D:
		transitioning = true
		body.set_physics_process(false)
		var hud = get_tree().root.find_child("HUD", true, false)
		if hud:
			hud.ativo = false
		_iniciar_transicao()

func _iniciar_transicao():
	var cena_atual = get_tree().current_scene.scene_file_path

	if "world_01" in cena_atual:
		get_tree().change_scene_to_file("res://actors/transicao_12.tscn")
	elif "world_02" in cena_atual:
		get_tree().change_scene_to_file("res://actors/transicao_23.tscn")
	else:
		GameManager.vidas = 3
		GameManager.tempo_restante_fase = 120.0
		get_tree().change_scene_to_file("res://actors/tela_vitoria.tscn")
