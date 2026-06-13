extends Control

@onready var caja_dialogo = $CajaDialogo
@onready var profesor: TextureRect = $Profesor
@onready var cv_profesor: ColorRect = $CVProfesor # (Cámbialo a TextureRect cuando tengas la imagen del CV)
@onready var contenedor_ui: Control = $ContenedorUI

@onready var fondo_intro: TextureRect = $Fondo
@onready var fondo_interactivo: TextureRect = $FondoInteractivo

# Nodos de las opciones
@onready var menu_genero: HBoxContainer = $ContenedorUI/MenuGenero
@onready var btn_chico: Button = $ContenedorUI/MenuGenero/BtnChico
@onready var btn_chica: Button = $ContenedorUI/MenuGenero/BtnChica
@onready var menu_nombre: VBoxContainer = $ContenedorUI/MenuNombre
@onready var input_nombre: LineEdit = $ContenedorUI/MenuNombre/InputNombre
@onready var btn_confirmar_nombre: Button = $ContenedorUI/MenuNombre/BtnConfirmarNombre

@export var alba_normal: Texture2D
@export var alba_sorprendida: Texture2D

var dialogos: Array = [
	"¡Hola!\n¡Bienvenido al mundo LABORAL!", # 0
	"¡Me llamo ALBA!", # 1
	"Seré tu profesor que te acompañará en esta aventura.", # 2
	"Este mundo te va a ayudar a formarte, teniendo como base tu CV.", # 3
	"Para algunos, el CV es un pedazo de papel...", # 4 
	"...pero otros lo usan para empezar a trabajar en lo que aman.", # 5 
	"En cuanto a mí...", # 6 
	"Tengo muchos años de experiencia.", # 7
	"Y mi CV contiene todo lo que he aprendido...", # 8 
	"...y trabajado durante todos estos años.", # 9 
	"Mi trabajo es que estudiantes como tú logren ingresar a la industria que deseen.", # 10
	"Bueno, cuéntame algo de ti.", # 11
	"¿Eres chico o chica?", # 12 
	"Pero primero dime cómo te llamas.", # 13 
	"¡Bien!\n¡Así que te llamas %s!", 
	"¿Y qué carrera estudias?" 
]

var indice_actual: int = 0
var estado_espera: String = ""

func _ready() -> void:
	contenedor_ui.visible = true 
	menu_genero.visible = false
	menu_nombre.visible = false
	cv_profesor.modulate.a = 0.0 
	fondo_interactivo.modulate.a = 0.0
	
	profesor.texture = alba_normal
	
	caja_dialogo.avanzar_dialogo.connect(_on_caja_avanzar_dialogo)
	caja_dialogo.texto_completo.connect(_on_caja_texto_completo)
	btn_chico.pressed.connect(func(): _seleccionar_genero("Chico"))
	btn_chica.pressed.connect(func(): _seleccionar_genero("Chica"))
	btn_confirmar_nombre.pressed.connect(_confirmar_nombre)
	
	_cargar_dialogo_actual()

func _cargar_dialogo_actual() -> void:
	if indice_actual < dialogos.size():
		var texto_a_mostrar = dialogos[indice_actual]
		
		if indice_actual == 14:
			texto_a_mostrar = texto_a_mostrar % GameManager.nombre_jugador
			profesor.texture = alba_sorprendida 
		elif indice_actual == 15:
			profesor.texture = alba_normal
			
		caja_dialogo.mostrar_texto(texto_a_mostrar)

func _on_caja_texto_completo() -> void:
	if indice_actual == 12:
		estado_espera = "genero"
		caja_dialogo.interactuable = false
		_mostrar_menu_genero()
		
	elif indice_actual == 13:
		estado_espera = "nombre"
		caja_dialogo.interactuable = false
		_mostrar_menu_nombre()

func _on_caja_avanzar_dialogo() -> void:
	if estado_espera != "":
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
	elif indice_actual == 14:
		# Entra Profesor y Fondo Intro, sale Fondo Interactivo
		var tween = create_tween().set_parallel(true)
		tween.tween_property(profesor, "modulate:a", 1.0, 0.5)
		tween.tween_property(fondo_interactivo, "modulate:a", 0.0, 0.5)
		
	_cargar_dialogo_actual()


func _mostrar_menu_genero() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(profesor, "modulate:a", 0.0, 0.5) 
	tween.tween_property(fondo_interactivo, "modulate:a", 1.0, 0.5)
	
	menu_genero.modulate.a = 0.0
	menu_genero.visible = true
	var tween_menu = create_tween()
	tween_menu.tween_property(menu_genero, "modulate:a", 1.0, 0.5)

func _seleccionar_genero(genero: String) -> void:
	GameManager.genero_jugador = genero
	print("Género seleccionado: ", genero)
	
	menu_genero.visible = false
	estado_espera = ""
	caja_dialogo.interactuable = true
	_on_caja_avanzar_dialogo() 

func _mostrar_menu_nombre() -> void:
	menu_nombre.modulate.a = 0.0
	menu_nombre.visible = true
	var tween = create_tween()
	tween.tween_property(menu_nombre, "modulate:a", 1.0, 0.5)

func _confirmar_nombre() -> void:
	var texto_ingresado = input_nombre.text.strip_edges()
	
	if texto_ingresado.length() < 2:
		return 
		
	GameManager.nombre_jugador = texto_ingresado
	print("Nombre confirmado: ", GameManager.nombre_jugador)
	
	menu_nombre.visible = false
	estado_espera = ""
	caja_dialogo.interactuable = true
	_on_caja_avanzar_dialogo()
