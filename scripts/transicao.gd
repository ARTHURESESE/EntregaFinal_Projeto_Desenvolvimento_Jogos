extends CanvasLayer

var label: Label
var bg: ColorRect

func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.visible = false
	add_child(bg)

	label = Label.new()
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.visible = false
	add_child(label)

func ir_para(texto: String, cena: String):
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/level.wav")
	add_child(audio)
	audio.play()

	bg.visible = true
	label.text = texto
	label.visible = true
	await get_tree().create_timer(3.0, false).timeout
	bg.visible = false
	label.visible = false
	get_tree().change_scene_to_file(cena)
