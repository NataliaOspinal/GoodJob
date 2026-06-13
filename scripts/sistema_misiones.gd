extends Control

@onready var boton_abrir: TextureButton = $BotonAbrir
@onready var cuadro_misiones: Panel = $CuadroMisiones
@onready var boton_cerrar: TextureButton = $CuadroMisiones/BotonCerrar
@onready var ui_timer: Timer = $"../../UITimer"

var posicion_original_x: float

func _ready() -> void:
	# Nos aseguramos del estado inicial al cargar el juego
	cuadro_misiones.hide()
	boton_abrir.show()
	posicion_original_x = cuadro_misiones.position.x
	
func _al_presionar_abrir() -> void:
	# Ocultamos el botón pequeño y mostramos el cuadro grande
	boton_abrir.hide()
	ui_timer.stop() # pausamos timer
	# Empieza 150 píxeles más a la izquierda
	cuadro_misiones.position.x = posicion_original_x - 150
	cuadro_misiones.modulate.a = 0.0
	cuadro_misiones.show()
	
	# Creamos la animación
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Efecto de rebote
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Movemos a posición original y fade-in en 0.4 segundos
	tween.tween_property(cuadro_misiones, "position:x", posicion_original_x, 0.4)
	tween.tween_property(cuadro_misiones, "modulate:a", 1.0, 0.3)

func _al_presionar_cerrar() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animación directa sin rebote
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Lo deslizamos hacia la izquierda y hace el fade-out
	tween.tween_property(cuadro_misiones, "position:x", posicion_original_x - 150, 0.3)
	tween.tween_property(cuadro_misiones, "modulate:a", 0.0, 0.2)
	
	# Cuando la animación termine
	tween.chain().tween_callback(cuadro_misiones.hide)
	tween.tween_callback(boton_abrir.show)
	tween.tween_callback(ui_timer.start)
