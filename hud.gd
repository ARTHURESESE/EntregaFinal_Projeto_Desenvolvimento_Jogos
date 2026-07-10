extends CanvasLayer

const TEMPO_PADRAO_FASE: float = 120.0
const TEMPO_FASE_3: float = 180.0

var tempo_restante: float = 0.0
var ativo: bool = true
var pausado: bool = false
var pause_overlay: ColorRect
var pause_label: Label
var vidas_container: HBoxContainer
var stamina_fill: ColorRect
var stamina_fill_max_width: float = 162.0
var progresso_fill: ColorRect
var progresso_fill_max_height: float = 188.0
var alerta_overlay: ColorRect

@onready var timer_label = $LabelTimer

func _ready():
	var cena = get_tree().current_scene.scene_file_path
	_iniciar_tempo_da_fase(cena)
	GameManager.cena_atual = cena
	_criar_atmosfera_tela()

	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	timer_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.position.y = 8

	var fase_label = Label.new()
	fase_label.add_theme_font_size_override("font_size", 14)
	fase_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	fase_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	fase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	fase_label.position = Vector2(40, 8)
	fase_label.name = "FaseLabel"
	if "world_01" in cena:
		fase_label.text = "FASE 1 — O Fundo do Poço"
	elif "world_02" in cena:
		fase_label.text = "FASE 2 — A Escalada"
	elif "world_03" in cena:
		fase_label.text = "FASE 3 — A Liberdade"
	add_child(fase_label)
	fase_label.modulate.a = 0.0
	var fase_tween = create_tween()
	fase_tween.tween_property(fase_label, "modulate:a", 1.0, 0.7)

	vidas_container = HBoxContainer.new()
	vidas_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	vidas_container.position = Vector2(-110, 8)
	add_child(vidas_container)

	for i in 3:
		var heart = TextureRect.new()
		heart.texture = load("res://assets/Sprite_heart.png")
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(24, 24)
		heart.name = "Heart" + str(i)
		vidas_container.add_child(heart)

	atualizar_vidas()

	_criar_barra_stamina()
	_criar_barra_progresso()

	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0, 0, 0, 0.7)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	add_child(pause_overlay)

	pause_label = Label.new()
	pause_label.text = "PAUSADO"
	pause_label.add_theme_font_size_override("font_size", 64)
	pause_label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	pause_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.visible = false
	add_child(pause_label)

func atualizar_vidas():
	for i in 3:
		var heart = vidas_container.get_child(i)
		heart.visible = i < GameManager.vidas

func _iniciar_tempo_da_fase(cena: String):
	if GameManager.cena_atual != cena:
		GameManager.tempo_restante_fase = _tempo_inicial_da_fase(cena)
	tempo_restante = GameManager.tempo_restante_fase

func _tempo_inicial_da_fase(cena: String) -> float:
	if "world_03" in cena:
		return TEMPO_FASE_3
	return TEMPO_PADRAO_FASE

func atualizar_stamina(valor: float):
	if stamina_fill:
		var carga = clamp(valor, 0.0, 1.0)
		stamina_fill.size.x = carga * stamina_fill_max_width
		if carga >= 1.0:
			var pulso = 0.5 + sin(Time.get_ticks_msec() / 120.0) * 0.5
			stamina_fill.color = Color(1.0, 0.72 + pulso * 0.12, 0.06, 1)
		else:
			stamina_fill.color = Color(0.94, 0.66, 0.06, 1)

func atualizar_progresso(valor: float):
	if progresso_fill:
		var carga = clamp(valor, 0.0, 1.0)
		var altura = carga * progresso_fill_max_height
		progresso_fill.size.y = altura
		progresso_fill.position.y = 8.0 + progresso_fill_max_height - altura
		if carga >= 1.0:
			var pulso = 0.5 + sin(Time.get_ticks_msec() / 120.0) * 0.5
			progresso_fill.color = Color(1.0, 0.72 + pulso * 0.12, 0.06, 1)
		else:
			progresso_fill.color = Color(0.94, 0.66, 0.06, 1)

func _criar_atmosfera_tela():
	var viewport_size = get_viewport().get_visible_rect().size

	var escurecer = ColorRect.new()
	escurecer.name = "AtmosferaEscura"
	escurecer.color = Color(0.0, 0.0, 0.02, 0.16)
	escurecer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	escurecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	escurecer.z_index = -100
	add_child(escurecer)

	alerta_overlay = ColorRect.new()
	alerta_overlay.name = "AlertaTempo"
	alerta_overlay.color = Color(0.55, 0.04, 0.0, 0.0)
	alerta_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	alerta_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alerta_overlay.z_index = -97
	add_child(alerta_overlay)

func _criar_barra_progresso():
	var frame_size = Vector2(30, 204)
	var margem_vertical = 8.0
	progresso_fill_max_height = frame_size.y - margem_vertical * 2

	var progresso_panel = Control.new()
	progresso_panel.name = "ProgressoPanel"
	progresso_panel.size = Vector2(38, 238)
	progresso_panel.position = Vector2(4, 268)
	progresso_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(progresso_panel)

	var label_topo = Label.new()
	label_topo.text = "TOPO"
	label_topo.add_theme_font_size_override("font_size", 9)
	label_topo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1))
	label_topo.add_theme_color_override("font_shadow_color", Color(0.12, 0.02, 0.0, 1))
	label_topo.add_theme_constant_override("shadow_offset_x", 1)
	label_topo.add_theme_constant_override("shadow_offset_y", 1)
	label_topo.position = Vector2(2, 0)
	label_topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progresso_panel.add_child(label_topo)

	var sombra_barra = ColorRect.new()
	sombra_barra.color = Color(0, 0, 0, 0.8)
	sombra_barra.size = frame_size
	sombra_barra.position = Vector2(5, 18)
	sombra_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progresso_panel.add_child(sombra_barra)

	var frame = Panel.new()
	frame.name = "BarraProgressoFrame"
	frame.size = frame_size
	frame.position = Vector2(1, 14)
	frame.clip_contents = true
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _criar_estilo_stamina(Color(0.0, 0.0, 0.02, 1), Color(0.02, 0.12, 0.32, 1), 0))
	progresso_panel.add_child(frame)

	progresso_fill = ColorRect.new()
	progresso_fill.name = "BarraProgresso"
	progresso_fill.color = Color(0.94, 0.66, 0.06, 1)
	progresso_fill.size = Vector2(16, 0)
	progresso_fill.position = Vector2(7, margem_vertical + progresso_fill_max_height)
	progresso_fill.clip_contents = true
	progresso_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(progresso_fill)

	var brilho = ColorRect.new()
	brilho.color = Color(1.0, 0.92, 0.24, 0.55)
	brilho.size = Vector2(3, progresso_fill_max_height)
	brilho.position = Vector2.ZERO
	brilho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progresso_fill.add_child(brilho)

	var sombra_fill = ColorRect.new()
	sombra_fill.color = Color(0.34, 0.16, 0.0, 0.55)
	sombra_fill.size = Vector2(4, progresso_fill_max_height)
	sombra_fill.position = Vector2(12, 0)
	sombra_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progresso_fill.add_child(sombra_fill)

	for i in range(1, 12):
		var scanline = ColorRect.new()
		scanline.color = Color(0, 0, 0, 0.22)
		scanline.size = Vector2(16, 1)
		scanline.position = Vector2(0, i * 15)
		scanline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		progresso_fill.add_child(scanline)

	for i in range(1, 10):
		var marca = ColorRect.new()
		marca.color = Color(0.0, 0.0, 0.02, 0.85)
		marca.size = Vector2(16, 2)
		marca.position = Vector2(7, margem_vertical + i * (progresso_fill_max_height / 10.0))
		marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(marca)

	var recorte_topo = ColorRect.new()
	recorte_topo.color = Color(0.04, 0.18, 0.42, 0.9)
	recorte_topo.size = Vector2(16, 2)
	recorte_topo.position = Vector2(7, 6)
	recorte_topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(recorte_topo)

	var recorte_base = ColorRect.new()
	recorte_base.color = Color(0.0, 0.04, 0.14, 1)
	recorte_base.size = Vector2(16, 2)
	recorte_base.position = Vector2(7, margem_vertical + progresso_fill_max_height)
	recorte_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(recorte_base)

	var label_base = Label.new()
	label_base.text = "BASE"
	label_base.add_theme_font_size_override("font_size", 9)
	label_base.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	label_base.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label_base.add_theme_constant_override("shadow_offset_x", 1)
	label_base.add_theme_constant_override("shadow_offset_y", 1)
	label_base.position = Vector2(3, 220)
	label_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progresso_panel.add_child(label_base)

func _criar_barra_stamina():
	var barra_w = 220.0
	var barra_h = 42.0
	var margem = 24.0

	var stamina_panel = Control.new()
	stamina_panel.name = "StaminaPanel"
	stamina_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	stamina_panel.size = Vector2(barra_w, barra_h)
	stamina_panel.position = Vector2(-(barra_w + margem), -(barra_h + margem))
	add_child(stamina_panel)

	var sombra_icon = ColorRect.new()
	sombra_icon.color = Color(0, 0, 0, 0.8)
	sombra_icon.size = Vector2(34, 34)
	sombra_icon.position = Vector2(4, 8)
	stamina_panel.add_child(sombra_icon)

	var sombra_barra = ColorRect.new()
	sombra_barra.color = Color(0, 0, 0, 0.8)
	sombra_barra.size = Vector2(178, 28)
	sombra_barra.position = Vector2(46, 11)
	stamina_panel.add_child(sombra_barra)

	var icon_frame = Panel.new()
	icon_frame.size = Vector2(34, 34)
	icon_frame.position = Vector2(0, 4)
	icon_frame.add_theme_stylebox_override("panel", _criar_estilo_stamina(Color(0.0, 0.0, 0.02, 1), Color(0.02, 0.12, 0.32, 1), 0))
	stamina_panel.add_child(icon_frame)

	var icon = Label.new()
	icon.text = "⚡"
	icon.add_theme_font_size_override("font_size", 23)
	icon.add_theme_color_override("font_color", Color(1.0, 0.78, 0.08, 1))
	icon.add_theme_color_override("font_shadow_color", Color(0.12, 0.02, 0.0, 1))
	icon.add_theme_constant_override("shadow_offset_x", 2)
	icon.add_theme_constant_override("shadow_offset_y", 2)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_frame.add_child(icon)

	var frame = Panel.new()
	frame.size = Vector2(178, 28)
	frame.position = Vector2(42, 7)
	frame.clip_contents = true
	frame.add_theme_stylebox_override("panel", _criar_estilo_stamina(Color(0.0, 0.0, 0.02, 1), Color(0.02, 0.12, 0.32, 1), 0))
	stamina_panel.add_child(frame)

	stamina_fill = ColorRect.new()
	stamina_fill.name = "StaminaFill"
	stamina_fill.color = Color(0.94, 0.66, 0.06, 1)
	stamina_fill.size = Vector2(0, 16)
	stamina_fill.position = Vector2(7, 6)
	stamina_fill.clip_contents = true
	frame.add_child(stamina_fill)

	var brilho = ColorRect.new()
	brilho.color = Color(1.0, 0.92, 0.24, 0.55)
	brilho.size = Vector2(stamina_fill_max_width, 3)
	brilho.position = Vector2.ZERO
	stamina_fill.add_child(brilho)

	var sombra_fill = ColorRect.new()
	sombra_fill.color = Color(0.34, 0.16, 0.0, 0.55)
	sombra_fill.size = Vector2(stamina_fill_max_width, 4)
	sombra_fill.position = Vector2(0, 12)
	stamina_fill.add_child(sombra_fill)

	for y in [4, 9, 14]:
		var scanline = ColorRect.new()
		scanline.color = Color(0, 0, 0, 0.22)
		scanline.size = Vector2(stamina_fill_max_width, 1)
		scanline.position = Vector2.ZERO + Vector2(0, y)
		stamina_fill.add_child(scanline)

	for i in range(1, 10):
		var marca = ColorRect.new()
		marca.color = Color(0.0, 0.0, 0.02, 0.85)
		marca.size = Vector2(2, 16)
		marca.position = Vector2(7 + i * 16, 6)
		frame.add_child(marca)

	var recorte_topo = ColorRect.new()
	recorte_topo.color = Color(0.04, 0.18, 0.42, 0.9)
	recorte_topo.size = Vector2(162, 2)
	recorte_topo.position = Vector2(7, 4)
	frame.add_child(recorte_topo)

	var recorte_base = ColorRect.new()
	recorte_base.color = Color(0.0, 0.04, 0.14, 1)
	recorte_base.size = Vector2(162, 2)
	recorte_base.position = Vector2(7, 22)
	frame.add_child(recorte_base)

func _criar_estilo_stamina(bg: Color, borda: Color, raio: int) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = borda
	s.corner_radius_top_left = raio
	s.corner_radius_top_right = raio
	s.corner_radius_bottom_left = raio
	s.corner_radius_bottom_right = raio
	return s

func _criar_estilo_btn() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 1)
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color(1, 0.84, 0, 1)
	s.corner_radius_top_left = 4
	s.corner_radius_top_right = 4
	s.corner_radius_bottom_left = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func _criar_estilo_btn_hover() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(1, 0.84, 0, 0.15)
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color(1, 0.84, 0, 1)
	s.corner_radius_top_left = 4
	s.corner_radius_top_right = 4
	s.corner_radius_bottom_left = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func perder_vida():
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/die.wav")
	add_child(audio)
	audio.play()
	GameManager.vidas -= 1
	GameManager.tempo_restante_fase = tempo_restante
	atualizar_vidas()
	if GameManager.vidas <= 0:
		GameManager.vidas = 3
		GameManager.tempo_restante_fase = 120.0
		_game_over()
	else:
		get_tree().call_deferred("change_scene_to_file", "res://actors/vida_perdida.tscn")

func _game_over():
	ativo = false
	GameManager.parar_musica()
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://actors/game_over.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		pausado = !pausado
		get_tree().set_deferred("paused", pausado)
		pause_overlay.visible = pausado
		pause_label.visible = pausado

func _process(delta):
	if not ativo or pausado:
		return

	GameManager.tempo_total += delta

	tempo_restante -= delta
	GameManager.tempo_restante_fase = tempo_restante

	if tempo_restante <= 0:
		tempo_restante = 0
		ativo = false
		_game_over()

	var minutos = int(tempo_restante) / 60
	var segundos = int(tempo_restante) % 60
	timer_label.text = "TIME  %02d:%02d" % [minutos, segundos]
	_atualizar_alerta_tempo()

	var batman = get_tree().root.find_child("CharacterBody2D", true, false)
	if batman:
		var chao_y = -35.0
		var topo_y = -3561.0
		var progresso = clamp((chao_y - batman.global_position.y) / (chao_y - topo_y), 0.0, 1.0)
		atualizar_progresso(progresso)

func _atualizar_alerta_tempo():
	if tempo_restante <= 20.0:
		var pulso = 0.5 + sin(Time.get_ticks_msec() / 140.0) * 0.5
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.24 + pulso * 0.2, 0.08, 1))
		timer_label.position.y = 8 + pulso * 2
		if alerta_overlay:
			alerta_overlay.color = Color(0.55, 0.04, 0.0, 0.05 + pulso * 0.06)
	elif tempo_restante <= 45.0:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.12, 1))
		timer_label.position.y = 8
		if alerta_overlay:
			alerta_overlay.color = Color(0.55, 0.04, 0.0, 0.0)
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		timer_label.position.y = 8
		if alerta_overlay:
			alerta_overlay.color = Color(0.55, 0.04, 0.0, 0.0)
