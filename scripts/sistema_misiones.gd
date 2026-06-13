extends Control

@onready var boton_abrir: TextureButton = $BotonAbrir
@onready var cuadro_misiones: Panel = $CuadroMisiones
@onready var boton_cerrar: TextureButton = $CuadroMisiones/BotonCerrar
@onready var ui_timer: Timer = $"../../UITimer"

func _ready() -> void:
	# Nos aseguramos del estado inicial al cargar el juego
	cuadro_misiones.hide()
	boton_abrir.show()
	
func _al_presionar_abrir() -> void:
	# Ocultamos el botón pequeño y mostramos el cuadro grande
	boton_abrir.hide()
	cuadro_misiones.show()
	ui_timer.stop() # pausamos timer

func _al_presionar_cerrar() -> void:
	# Ocultamos el cuadro grande y mostramos el botón pequeño
	cuadro_misiones.hide()
	boton_abrir.show()
	ui_timer.start()
