extends Panel

signal texto_completo
signal avanzar_dialogo

@onready var texto: RichTextLabel = $Texto
@onready var flecha: Label = $Flecha
@onready var timer_letras: Timer = $TimerLetras
@onready var audio_tap: AudioStreamPlayer = $AudioTap

var texto_terminado: bool = false
var interactuable: bool = true
var en_pausa_puntuacion: bool = false 

func _ready() -> void:
	texto.add_theme_color_override("default_color", Color.BLACK)
	flecha.add_theme_color_override("font_color", Color.RED)
	
	flecha.visible = false
	texto.visible_characters = 0
	
	timer_letras.wait_time = 0.03
	timer_letras.timeout.connect(_on_timer_letras_timeout)

func mostrar_texto(nuevo_texto: String) -> void:
	texto.text = nuevo_texto
	texto.visible_characters = 0
	texto_terminado = false
	en_pausa_puntuacion = false
	flecha.visible = false
	timer_letras.start()

func _on_timer_letras_timeout() -> void:
	if texto.visible_characters < texto.get_total_character_count():
		texto.visible_characters += 1
		
		var texto_limpio = texto.get_parsed_text() 
		if texto.visible_characters <= texto_limpio.length():
			var ultimo_caracter = texto_limpio[texto.visible_characters - 1]
			
			if ultimo_caracter == "." or ultimo_caracter == ",":
				timer_letras.stop()
				en_pausa_puntuacion = true
				
				await get_tree().create_timer(0.5).timeout
				
				if not texto_terminado and en_pausa_puntuacion:
					en_pausa_puntuacion = false
					timer_letras.start()
	else:
		_terminar_animacion_texto()

func _terminar_animacion_texto() -> void:
	timer_letras.stop()
	en_pausa_puntuacion = false
	texto.visible_characters = texto.get_total_character_count()
	texto_terminado = true
	
	flecha.visible = true
	_animar_flecha()
	emit_signal("texto_completo")

func _animar_flecha() -> void:
	if texto_terminado:
		var tween = create_tween().set_loops()
		tween.tween_property(flecha, "modulate:a", 0.0, 0.4)
		tween.tween_property(flecha, "modulate:a", 1.0, 0.4)

func _input(event: InputEvent) -> void:
	if not visible or not interactuable:
		return
		
	if event is InputEventScreenTouch and event.pressed:
		if audio_tap.stream:
			audio_tap.play()
		
		if not texto_terminado:
			_terminar_animacion_texto()
		else:
			emit_signal("avanzar_dialogo")
