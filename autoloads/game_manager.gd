extends Node

var genero_jugador: String = ""
var nombre_jugador: String = ""
var carrera_jugador: String = ""
var especializacion_jugador: String = ""

var npcs_atrapados: int = 0
var meta_npcs: int = 0
var juego_atrapados_activo: bool = false

var posicion_overworld: Vector2 = Vector2.ZERO
var regresando_al_overworld: bool = false

var items_recolectados: int = 0
var meta_items: int = 15
var mision_resuelta: bool = false
var errores_recolectados: int = 0

func registrar_item_recogido() -> void:
	items_recolectados += 1
	print("Items: ", items_recolectados, "/", meta_items)
	if items_recolectados >= meta_items:
		mision_resuelta = true
		print("¡Misión lista para ser entregada!")
	
func registrar_error_carpeta() -> void:
	errores_recolectados += 1
	print("Carpetas incorrectas: ", errores_recolectados, "/3")
	
	if errores_recolectados >= 3:
		get_tree().call_deferred("call_group", "GestorEventos", "reiniciar_mision_folders")
