extends Control

@onready var boton_abrir: TextureButton = $BotonAbrir
@onready var cuadro_misiones: Panel = $CuadroMisiones
@onready var boton_cerrar: TextureButton = $CuadroMisiones/BotonCerrar
@onready var ui_timer: Timer = $"../../UITimer"

@onready var texto_mision: Label = $CuadroMisiones/TextoMision

var posicion_original_x: float

func _ready() -> void:
	cuadro_misiones.hide()
	boton_abrir.show()
	posicion_original_x = cuadro_misiones.position.x
	
	boton_abrir.pressed.connect(_al_presionar_abrir)
	boton_cerrar.pressed.connect(_al_presionar_cerrar)
	
func _al_presionar_abrir() -> void:
	_actualizar_mision_actual() 
	
	boton_abrir.hide()
	ui_timer.stop() 
	cuadro_misiones.position.x = posicion_original_x - 150
	cuadro_misiones.modulate.a = 0.0
	cuadro_misiones.show()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(cuadro_misiones, "position:x", posicion_original_x, 0.4)
	tween.tween_property(cuadro_misiones, "modulate:a", 1.0, 0.3)

func _al_presionar_cerrar() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween.tween_property(cuadro_misiones, "position:x", posicion_original_x - 150, 0.3)
	tween.tween_property(cuadro_misiones, "modulate:a", 0.0, 0.2)
	
	tween.chain().tween_callback(cuadro_misiones.hide)
	tween.tween_callback(boton_abrir.show)
	tween.tween_callback(ui_timer.start)

func _actualizar_mision_actual() -> void:
	if not GameManager.cv_tech_skills_desbloqueado:
		texto_mision.text = "- Aprende Power BI!"
	elif GameManager.cv_tech_skills_desbloqueado and not GameManager.cv_soft_skills_desbloqueado:
		texto_mision.text = "- Entrena tus habilidades blandas."
	else:
		texto_mision.text = "- A.I.D.A quiere revisar tu CV!"
