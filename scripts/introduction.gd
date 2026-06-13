extends Control

@onready var caja_dialogo = $CajaDialogo
@onready var profesor: ColorRect = $Profesor
@onready var cv_profesor: ColorRect = $CVProfesor
@onready var contenedor_ui: Control = $ContenedorUI

var dialogos: Array = [
	"¡Hola!\n¡Bienvenido al mundo LABORAL!", 
	"¡Me llamo ALBA!", 
	"Seré tu profesor que te acompañará en esta aventura.", 
	"Este mundo te va a ayudar a formarte, teniendo como base tu CV.", 
	"Para algunos, el CV es un pedazo de papel...", 
	"...pero otros lo usan para empezar a trabajar en lo que aman.", 
	"En cuanto a mí...", 
	"Tengo muchos años de experiencia.", 
	"Y mi CV contiene todo lo que he aprendido", 
	"y trabajado durante todos estos años.", 
	"Me encargo que estudiantes como tú", 
	"Logren ingresar a la industria que deseen!", 
	"Bueno, cuéntame algo de ti.", 
	"¿Eres chico o chica?" 
]

var indice_actual: int = 0
var esperando_opcion: bool = false

func _ready() -> void:
	contenedor_ui.visible = false
	cv_profesor.modulate.a = 0.0 
	
	caja_dialogo.avanzar_dialogo.connect(_on_caja_avanzar_dialogo)
	caja_dialogo.texto_completo.connect(_on_caja_texto_completo)
	
	_cargar_dialogo_actual()

func _cargar_dialogo_actual() -> void:
	if indice_actual < dialogos.size():
		caja_dialogo.mostrar_texto(dialogos[indice_actual])

func _on_caja_texto_completo() -> void:
	if indice_actual == 12:
		esperando_opcion = true
		caja_dialogo.interactuable = false
		_mostrar_seleccion_genero()

func _on_caja_avanzar_dialogo() -> void:
	if esperando_opcion:
		return
		
	indice_actual += 1
	
	if indice_actual == 7:
		var tween = create_tween().set_parallel(true) 
		tween.tween_property(profesor, "modulate:a", 0.0, 0.5)
		tween.tween_property(cv_profesor, "modulate:a", 1.0, 0.5)
		
	elif indice_actual == 10:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cv_profesor, "modulate:a", 0.0, 0.5)
		tween.tween_property(profesor, "modulate:a", 1.0, 0.5)
		
	_cargar_dialogo_actual()

func _mostrar_seleccion_genero() -> void:
	print("Lógica de botones: Aparecen Chico/Chica y se oculta el profesor.")
	var tween = create_tween()
	tween.tween_property(profesor, "modulate:a", 0.0, 0.5)
