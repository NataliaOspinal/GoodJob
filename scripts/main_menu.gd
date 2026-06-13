extends Control

@onready var seccion_menu: Control = $SeccionMenu
@onready var seccion_pre_intro: Control = $SeccionPreIntro
@onready var texto_introduccion: Label = $SeccionPreIntro/ContenedorTexto/TextoIntroduccion
@onready var filtro_fade: ColorRect = $FiltroFade

var bloques_texto: Array = [
	"En el mundo que estas apunto de entrar, te embarcaras en una gran aventura de la que vas a ser el profesional.\n\n\nHabla con la gente y curiosea todo lo que te llame la atención, sea donde sea. Consigue información y despeja tus dudas con cualquiera que te rodee.",
	"Durante el camino, tendrás que aprender sobre ti mismo, salir de tu zona de confort y aplicar todo conocimiento que adquieras.\n\n\nEs valido que te sientas perdido en ciertos momentos o que el camino sea incierto, pero ¡ánimo, tú puedes!",
	"Recuerda, habla con todo el mundo; crecerás como persona, y ese es tu principal objetivo.\n\n\nPulsa en la pantalla, ¡que comience la aventura!"
]

var indice_texto: int = 0
var esperando_tap: bool = false
var en_transicion: bool = false 

func _ready() -> void:
	seccion_menu.visible = true
	seccion_pre_intro.visible = false
	filtro_fade.modulate.a = 0.0
	texto_introduccion.modulate.a = 0.0
	
	filtro_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_boton_empezar_pressed() -> void:
	$SeccionMenu/BotonEmpezar.disabled = true
	_iniciar_secuencia()

func _iniciar_secuencia() -> void:
	filtro_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween_out = create_tween()
	tween_out.tween_property(filtro_fade, "modulate:a", 1.0, 0.8)
	await tween_out.finished
	
	seccion_menu.visible = false
	seccion_pre_intro.visible = true
	
	var tween_in = create_tween()
	tween_in.tween_property(filtro_fade, "modulate:a", 0.0, 0.8)
	await tween_in.finished
	
	filtro_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mostrar_texto_actual()

func _mostrar_texto_actual() -> void:
	if indice_texto >= bloques_texto.size():
		_ir_a_la_intro_del_profesor()
		return
		
	en_transicion = true
	texto_introduccion.text = bloques_texto[indice_texto]
	
	var tween_texto_in = create_tween()
	tween_texto_in.tween_property(texto_introduccion, "modulate:a", 1.0, 0.8)
	await tween_texto_in.finished
	
	await get_tree().create_timer(4.0).timeout
	
	esperando_tap = true
	en_transicion = false

func _input(event: InputEvent) -> void:
	if esperando_tap and not en_transicion and event is InputEventScreenTouch and event.pressed:
		esperando_tap = false
		en_transicion = true
		
		var tween_texto_out = create_tween()
		tween_texto_out.tween_property(texto_introduccion, "modulate:a", 0.0, 0.5)
		await tween_texto_out.finished
		
		indice_texto += 1
		_mostrar_texto_actual()

func _ir_a_la_intro_del_profesor() -> void:
	var tween_final = create_tween()
	tween_final.tween_property(filtro_fade, "modulate:a", 1.0, 0.8)
	await tween_final.finished
	
	get_tree().change_scene_to_file("res://Scenes/introduction.tscn")
