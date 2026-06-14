extends CanvasLayer

@onready var ui_timer: Timer = $UITimer
@onready var margin_container: MarginContainer = $MarginContainer 
@onready var caja_dialogo: Panel = $CajaDialogo
@onready var boton_cv: TextureButton = $MarginContainer/HBoxContainer/BotonCV
@onready var pantalla_cv = $PantallaCv

var emisor_actual: Node = null
var dialogo_actual: Array[String] = []
var indice_dialogo: int = 0
var touch_area_y_end: float = 0.0

func _ready() -> void:
	# Área superior es el tercio de arriba de la pantalla (1280 / 3)
	touch_area_y_end = get_viewport().get_visible_rect().size.y / 3.0
	caja_dialogo.hide()
	boton_cv.pressed.connect(_al_presionar_boton_cv)
	
func iniciar_dialogo_npc(lineas: Array[String], emisor_nodo: Node) -> void:
	if lineas.size() == 0: 
		return
	
	dialogo_actual = lineas
	indice_dialogo = 0
	emisor_actual = emisor_nodo # Guardamos al NPC en la memoria de la UI
	
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
	
	# Si ya está completamente visible, no se hace nada
	if margin_container.visible and margin_container.modulate.a >= 0.95:
		return
		
	# Si está oculta o haciendo el fade-out de bajada, hacemos el fade-in
	margin_container.show()
	var tween = create_tween()
	tween.tween_property(margin_container, "modulate:a", 1.0, 0.3)

func _ocultar_ui() -> void:
	# Tween para el Fade-out
	var tween = create_tween()
	# Transparencia en 0.5 segundos
	tween.tween_property(margin_container, "modulate:a", 0.0, 0.5)
	# Ocultar de verdad
	tween.tween_callback(margin_container.hide)
	
func _al_presionar_boton_cv() -> void:
	print("¡El botón detectó el clic!")
	pantalla_cv.mostrar_cv()
