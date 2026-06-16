extends Control

@onready var caja_dialogo = $CajaDialogo
@onready var profesor: TextureRect = $MarcoProfesor/Profesor
@onready var cv_profesor: ColorRect = $CVProfesor 
@onready var contenedor_ui: Control = $ContenedorUI
@onready var fondo_intro: TextureRect = $Fondo
@onready var fondo_interactivo: TextureRect = $FondoInteractivo
@onready var audio_boton: AudioStreamPlayer = $AudioBoton 

@onready var menu_genero: HBoxContainer = $ContenedorUI/MenuGenero
@onready var menu_nombre: VBoxContainer = $ContenedorUI/MenuNombre
@onready var input_nombre: LineEdit = $ContenedorUI/MenuNombre/InputNombre

@onready var menu_carreras: GridContainer = $ContenedorUI/MenuCarreras
@onready var menu_sub_carreras: GridContainer = $ContenedorUI/MenuSubCarreras
@onready var pop_up_alerta: Panel = $ContenedorUI/PopUpAlerta

@onready var menu_especialidad: ScrollContainer = $ContenedorUI/MenuEspecialidad
@onready var contenedor_carrusel: HBoxContainer = $ContenedorUI/MenuEspecialidad/ContenedorCarrusel

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
	"Y mi CV contiene todo lo que he aprendido..", # 8 
	"y trabajado durante todos estos años.", # 9 
	"Me encargo de que estudiantes como tú...", 
	"logren ingresar a la industria que deseen!", 
	"Bueno, cuéntame algo de ti.", # 11
	"¿Eres chico o chica?", # 12
	"Y ahora dime.. ¿cómo te llamas?", # 13
	"¡Bien!\n¡Así que te llamas %s!", # 14 
	"¿Y qué carrera estudias?", # 15
	"¿Administración y Marketing?", # 16 
	"¡Qué sorpresa! Espero te vaya muy bien en los negocios!", # 17 
	"¿Y en qué te quieres especializar?", 
	"¿Con que Marketing Retail y Fidelización del Cliente?", 
	"¡Parece que te encanta el enfoque comercial!", 
	"¡%s!", 
	"¡Tu propia vida LABORAL está a punto de comenzar!", 
	"¡Te espera un mundo de sueños y aprendizaje durante tu viaje!\n¡Adelante!" 
]

var indice_actual: int = 0
var estado_espera: String = ""

func _ready() -> void:
	contenedor_ui.visible = true 
	menu_genero.visible = false
	menu_nombre.visible = false
	menu_carreras.visible = false
	menu_sub_carreras.visible = false
	menu_especialidad.visible = false
	pop_up_alerta.visible = false
	
	cv_profesor.modulate.a = 0.0 
	fondo_interactivo.modulate.a = 0.0
	profesor.texture = alba_normal
	
	caja_dialogo.avanzar_dialogo.connect(_on_caja_avanzar_dialogo)
	caja_dialogo.texto_completo.connect(_on_caja_texto_completo)
	
	$ContenedorUI/MenuGenero/BtnChico.pressed.connect(func(): _seleccionar_genero("Chico"))
	$ContenedorUI/MenuGenero/BtnChica.pressed.connect(func(): _seleccionar_genero("Chica"))
	$ContenedorUI/MenuNombre/BtnConfirmarNombre.pressed.connect(_confirmar_nombre)
	
	var btn_negocios = menu_carreras.get_node("BtnNegocios")
	btn_negocios.pressed.connect(_abrir_sub_carreras)
	for btn in menu_carreras.get_children():
		if btn != btn_negocios: btn.pressed.connect(_mostrar_popup_alerta)
			
	var btn_admin_mark = menu_sub_carreras.get_node("BtnAdminMark")
	btn_admin_mark.pressed.connect(func(): _seleccionar_carrera_final("Administración y Marketing"))
	for btn in menu_sub_carreras.get_children():
		if btn != btn_admin_mark: btn.pressed.connect(_mostrar_popup_alerta)
			
	var btn_retail = contenedor_carrusel.get_node("BtnRetail")
	btn_retail.pressed.connect(func(): _seleccionar_especialidad("Marketing Retail y Fidelización"))
	for btn in contenedor_carrusel.get_children():
		if btn is BaseButton and btn != btn_retail: 
			btn.pressed.connect(_mostrar_popup_alerta)
	
	_cargar_dialogo_actual()

func _process(delta: float) -> void:
	if menu_especialidad.visible:
		var centro_pantalla = get_viewport_rect().size.x / 2.0
		for btn in contenedor_carrusel.get_children():
			if not btn is BaseButton:
				continue
				
			var centro_btn = btn.global_position.x + (btn.size.x / 2.0)
			var distancia = abs(centro_pantalla - centro_btn)
			
			var escala = clamp(1.0 - (distancia / 1500.0), 0.85, 1.0)
			btn.scale = btn.scale.lerp(Vector2(escala, escala), 15 * delta)

func _reproducir_sonido() -> void:
	if audio_boton.stream: audio_boton.play()

func _cargar_dialogo_actual() -> void:
	if indice_actual < dialogos.size():
		var texto_a_mostrar = dialogos[indice_actual]
		
		if indice_actual == 15 or indice_actual == 22:
			texto_a_mostrar = texto_a_mostrar % GameManager.nombre_jugador
			profesor.texture = alba_sorprendida
		elif indice_actual == 16 or indice_actual == 17 or indice_actual == 19 or indice_actual == 20:
			profesor.texture = alba_normal
		elif indice_actual == 18 or indice_actual == 21:
			profesor.texture = alba_sorprendida
			
		caja_dialogo.mostrar_texto(texto_a_mostrar)

func _on_caja_texto_completo() -> void:
	if indice_actual == 13: 
		estado_espera = "genero"
		caja_dialogo.interactuable = false
		_mostrar_menu_genero()
	elif indice_actual == 14:
		estado_espera = "nombre"
		caja_dialogo.interactuable = false
		_mostrar_menu_nombre()
	elif indice_actual == 16:
		estado_espera = "carrera"
		caja_dialogo.interactuable = false
		_mostrar_menu_carreras()
	elif indice_actual == 19:
		estado_espera = "especialidad"
		caja_dialogo.interactuable = false
		_mostrar_carrusel()

func _on_caja_avanzar_dialogo() -> void:
	if estado_espera != "": return 
		
	indice_actual += 1
	
	if indice_actual == 7:
		var tween = create_tween().set_parallel(true) 
		tween.tween_property(profesor, "modulate:a", 0.0, 0.5)
		tween.tween_property(cv_profesor, "modulate:a", 1.0, 0.5)
	elif indice_actual == 12: 
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cv_profesor, "modulate:a", 0.0, 0.5)
		tween.tween_property(profesor, "modulate:a", 1.0, 0.5)
	elif indice_actual == 15 or indice_actual == 17 or indice_actual == 20:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(profesor, "modulate:a", 1.0, 0.5)
		tween.tween_property(fondo_interactivo, "modulate:a", 0.0, 0.5)
	elif indice_actual >= dialogos.size():
		_ir_a_gameplay()
		
	if indice_actual < dialogos.size():
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
	_reproducir_sonido()
	GameManager.genero_jugador = genero
	estado_espera = ""
	caja_dialogo.interactuable = true
	var tween = create_tween()
	tween.tween_property(menu_genero, "modulate:a", 0.0, 0.5)
	await tween.finished
	menu_genero.visible = false
	_on_caja_avanzar_dialogo() 

func _mostrar_menu_nombre() -> void:
	menu_nombre.modulate.a = 0.0
	menu_nombre.visible = true
	var tween = create_tween()
	tween.tween_property(menu_nombre, "modulate:a", 1.0, 0.5)

func _confirmar_nombre() -> void:
	_reproducir_sonido()
	var texto_ingresado = input_nombre.text.strip_edges()
	if texto_ingresado.length() < 2: return 
	GameManager.nombre_jugador = texto_ingresado
	estado_espera = ""
	caja_dialogo.interactuable = true
	var tween = create_tween()
	tween.tween_property(menu_nombre, "modulate:a", 0.0, 0.5)
	await tween.finished
	menu_nombre.visible = false
	_on_caja_avanzar_dialogo()

func _mostrar_menu_carreras() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(profesor, "modulate:a", 0.0, 0.5) 
	tween.tween_property(fondo_interactivo, "modulate:a", 1.0, 0.5)
	menu_carreras.modulate.a = 0.0
	menu_carreras.visible = true
	var tween_menu = create_tween()
	tween_menu.tween_property(menu_carreras, "modulate:a", 1.0, 0.5)

func _abrir_sub_carreras() -> void:
	_reproducir_sonido()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(menu_carreras, "modulate:a", 0.0, 0.4)
	menu_sub_carreras.modulate.a = 0.0
	menu_sub_carreras.visible = true
	tween.tween_property(menu_sub_carreras, "modulate:a", 1.0, 0.4)
	await tween.finished
	menu_carreras.visible = false

func _seleccionar_carrera_final(carrera: String) -> void:
	_reproducir_sonido()
	GameManager.carrera_jugador = carrera
	estado_espera = ""
	caja_dialogo.interactuable = true
	var tween = create_tween()
	tween.tween_property(menu_sub_carreras, "modulate:a", 0.0, 0.5)
	await tween.finished
	menu_sub_carreras.visible = false
	_on_caja_avanzar_dialogo()

func _mostrar_carrusel() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(profesor, "modulate:a", 0.0, 0.5) 
	tween.tween_property(fondo_interactivo, "modulate:a", 1.0, 0.5)
	menu_especialidad.modulate.a = 0.0
	menu_especialidad.visible = true
	
	await get_tree().process_frame 
	menu_especialidad.scroll_horizontal = int(contenedor_carrusel.size.x / 4.0)
	
	var tween_menu = create_tween()
	tween_menu.tween_property(menu_especialidad, "modulate:a", 1.0, 0.5)

func _seleccionar_especialidad(espec: String) -> void:
	_reproducir_sonido()
	GameManager.especializacion_jugador = espec
	print("Especialidad Guardada: ", GameManager.especializacion_jugador)
	estado_espera = ""
	caja_dialogo.interactuable = true
	var tween = create_tween()
	tween.tween_property(menu_especialidad, "modulate:a", 0.0, 0.5)
	await tween.finished
	menu_especialidad.visible = false
	_on_caja_avanzar_dialogo()

func _mostrar_popup_alerta() -> void:
	_reproducir_sonido()
	pop_up_alerta.scale = Vector2(0, 0) 
	pop_up_alerta.visible = true
	var tween = create_tween()
	tween.tween_property(pop_up_alerta, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(pop_up_alerta, "scale", Vector2(0, 0), 0.2).set_delay(1.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	pop_up_alerta.visible = false

func _ir_a_gameplay() -> void:
	# Fade out final hacia negro
	var fade_final = ColorRect.new()
	fade_final.color = Color.BLACK
	fade_final.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_final.modulate.a = 0.0
	add_child(fade_final)
	
	var tween = create_tween()
	tween.tween_property(fade_final, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")
