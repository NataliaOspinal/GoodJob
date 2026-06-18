extends CanvasLayer

@onready var ui_timer: Timer = $UITimer
@onready var margin_container: MarginContainer = $MarginContainer 
@onready var caja_dialogo: Panel = $CajaDialogo
@onready var boton_cv: TextureButton = $MarginContainer/HBoxContainer/BotonCV
@onready var pantalla_cv = $PantallaCv
@onready var contenedor_folders: HBoxContainer = $ContadorFolders
@onready var label_folders: Label = $ContadorFolders/Label
@onready var menu_opciones: Panel = $MenuOpciones
@onready var texto_pregunta: Label = $MenuOpciones/TextoPregunta
@onready var btn_opcion_a: Button = $MenuOpciones/VBoxContainer/BtnOpcionA
@onready var btn_opcion_b: Button = $MenuOpciones/VBoxContainer/BtnOpcionB
@onready var boton_mapa: TextureButton = $MarginContainer/HBoxContainer/BotonMapa
@onready var pantalla_mapa: Control = $PantallaMapa
@onready var btn_cerrar_mapa: Button = $PantallaMapa/BtnCerrarMapa

var opcion_a_es_correcta: bool = false
var emisor_actual: Node = null
var dialogo_actual: Array[String] = []
var indice_dialogo: int = 0
var touch_area_y_end: float = 0.0

func _ready() -> void:
	touch_area_y_end = get_viewport().get_visible_rect().size.y / 3.0
	caja_dialogo.hide()
	menu_opciones.hide()
	boton_cv.pressed.connect(_al_presionar_boton_cv)
	contenedor_folders.hide()
	btn_opcion_a.pressed.connect(_al_elegir_opcion_a)
	btn_opcion_b.pressed.connect(_al_elegir_opcion_b)
	pantalla_mapa.hide()
	boton_mapa.pressed.connect(_al_presionar_boton_mapa)
	btn_cerrar_mapa.pressed.connect(_cerrar_mapa)

func iniciar_dialogo_npc(lineas: Array[String], emisor_nodo: Node) -> void:
	if lineas.size() == 0: 
		return
	
	dialogo_actual = lineas
	indice_dialogo = 0
	emisor_actual = emisor_nodo 
	
	caja_dialogo.show()
	caja_dialogo.mostrar_texto(dialogo_actual[indice_dialogo])
	
func _siguiente_linea() -> void:
	indice_dialogo += 1
	if indice_dialogo < dialogo_actual.size():
		caja_dialogo.mostrar_texto(dialogo_actual[indice_dialogo])
	else:
		caja_dialogo.hide()

		if emisor_actual != null and emisor_actual.has_method("on_dialogo_terminado"):
			emisor_actual.on_dialogo_terminado()
			
		emisor_actual = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if event.position.y <= touch_area_y_end:
			_mostrar_ui()

func _mostrar_ui() -> void:
	ui_timer.start() 
	
	if margin_container.visible and margin_container.modulate.a >= 0.95:
		return
		
	margin_container.show()
	var tween = create_tween()
	tween.tween_property(margin_container, "modulate:a", 1.0, 0.3)

func _ocultar_ui() -> void:
	var tween = create_tween()
	tween.tween_property(margin_container, "modulate:a", 0.0, 0.5)
	tween.tween_callback(margin_container.hide)
	
func _al_presionar_boton_cv() -> void:
	print("¡El botón detectó el clic!")
	pantalla_cv.mostrar_cv()
	
func mostrar_contador_folders(mostrar: bool) -> void:
	contenedor_folders.visible = mostrar

func actualizar_contador_folders(actual: int, meta: int) -> void:
	label_folders.text = str(actual) + " / " + str(meta)
func mostrar_menu_opciones(npc: Node) -> void:
	emisor_actual = npc
	menu_opciones.show()
	
	if npc.datos != null and npc.datos.pregunta_panico != "":
		texto_pregunta.text = npc.datos.pregunta_panico
		
		if randf() > 0.5:
			btn_opcion_a.text = npc.datos.opcion_correcta
			btn_opcion_b.text = npc.datos.opcion_incorrecta
			opcion_a_es_correcta = true
		else:
			btn_opcion_a.text = npc.datos.opcion_incorrecta
			btn_opcion_b.text = npc.datos.opcion_correcta
			opcion_a_es_correcta = false
	else:
		texto_pregunta.text = "ERROR: El NPC no tiene sus Datos cargados en el Inspector."

func _al_elegir_opcion_a() -> void:
	_procesar_respuesta(opcion_a_es_correcta)

func _al_elegir_opcion_b() -> void:
	_procesar_respuesta(not opcion_a_es_correcta)

func _procesar_respuesta(es_correcta: bool) -> void:
	menu_opciones.hide()
	get_tree().call_group("GestorEventos", "procesar_eleccion", emisor_actual, es_correcta)
	emisor_actual = null
func _al_presionar_boton_mapa() -> void:
	if GameManager.has_method("reproducir_sfx"):
		# Si tienes un sonido de papel, ponlo aquí, si no, usa el de botón
		pass 
		
	pantalla_mapa.modulate.a = 0.0
	pantalla_mapa.show()
	
	var tween = create_tween()
	tween.tween_property(pantalla_mapa, "modulate:a", 1.0, 0.3)

func _cerrar_mapa() -> void:
	var tween = create_tween()
	tween.tween_property(pantalla_mapa, "modulate:a", 0.0, 0.3)
	tween.tween_callback(pantalla_mapa.hide)
