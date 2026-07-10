extends Control

func _ready():
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/die.wav")
	add_child(audio)
	audio.play()
	await get_tree().create_timer(1.5).timeout
	get_tree().call_deferred("change_scene_to_file", GameManager.cena_atual)
