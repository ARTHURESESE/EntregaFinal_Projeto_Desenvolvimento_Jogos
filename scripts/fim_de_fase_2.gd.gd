extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.set_physics_process(false)
		show_transition()

func show_transition():
	var canvas = CanvasLayer.new()
	get_tree().root.add_child(canvas)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)

	var label = Label.new()
	label.text = "Você escapou do poço!\nGotham está salva!"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	canvas.add_child(label)

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://world_01.tscn")
