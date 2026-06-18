extends Node2D

@export var puntos_carrera: Array[Marker2D] = []
@export var centro_plaza: Marker2D
@export var npc_principal: Node2D

var npcs_corriendo: Dictionary = {}
var npcs_regresando: Array[Node2D] = []

func _ready() -> void:
	add_to_group("GestorEventos")
	
	var civiles = get_tree().get_nodes_in_group("NpcsPlaza")
	GameManager.meta_npcs = civiles.size()
	
	for npc in civiles:
		npc.type = npc.NpcType.CONTROL_EXTERNO
		npc.modo_interaccion_fisica = true
		npc.boton_popin.hide()
		
		if not npc.fue_tocado_por_jugador.is_connected(_al_interceptar_npc):
			npc.fue_tocado_por_jugador.connect(_al_interceptar_npc)
		
		npcs_corriendo[npc] = puntos_carrera.pick_random()

func _physics_process(delta: float) -> void:
	for npc in npcs_corriendo.keys():
		var destino_actual = npcs_corriendo[npc].global_position
		var direccion = (destino_actual - npc.global_position).normalized()
		npc.velocity = direccion * 60.0
		
		if npc.global_position.distance_to(destino_actual) < 20.0:
			npcs_corriendo[npc] = puntos_carrera.pick_random()

	for npc in npcs_regresando.duplicate():
		if centro_plaza == null: break
			
		var distancia = npc.global_position.distance_to(centro_plaza.global_position)
		if distancia > 15.0:
			var direccion = (centro_plaza.global_position - npc.global_position).normalized()
			npc.velocity = direccion * 60.0 
		else:
			npc.velocity = Vector2.ZERO
			npc.type = npc.NpcType.IDLE
			npcs_regresando.erase(npc)
			_verificar_victoria_final()

func ejecutar_evento(id: String) -> void:
	match id:
		"estampida_npcs":
			GameManager.npcs_atrapados = 0
			GameManager.juego_atrapados_activo = true

func finalizar_evento(id: String) -> void:
	match id:
		"estampida_npcs":
			if GameManager.has_method("desbloquear_habilidad"):
				GameManager.desbloquear_habilidad("Escucha Activa")

func _al_interceptar_npc(npc_interceptado: Node2D) -> void:
	npcs_corriendo.erase(npc_interceptado)
	npc_interceptado.modo_interaccion_fisica = false
	npc_interceptado.velocity = Vector2.ZERO
	
	if GameManager.juego_atrapados_activo:
		get_tree().call_group("Interfaz", "mostrar_menu_opciones", npc_interceptado)
	else:
		get_tree().call_group("Interfaz", "iniciar_dialogo_npc", ["¡AAAAHHH! ¡ESTOY COLAPSANDO, DÉJAME EN PAZ!"], npc_interceptado)
		if not npc_interceptado.is_connected("dialogo_cerrado", _reanudar_carrera):
			npc_interceptado.connect("dialogo_cerrado", _reanudar_carrera)

func _reanudar_carrera(npc: Node2D) -> void:
	npc.disconnect("dialogo_cerrado", _reanudar_carrera)
	npc.modo_interaccion_fisica = true
	npcs_corriendo[npc] = puntos_carrera.pick_random()

func procesar_eleccion(npc: Node2D, correcta: bool) -> void:
	if correcta:
		if GameManager.has_method("reproducir_sfx"):
			GameManager.reproducir_sfx(GameManager.snd_buen_folder)
		npcs_regresando.append(npc)
	else:
		if GameManager.has_method("reproducir_sfx"):
			GameManager.reproducir_sfx(GameManager.snd_mal_folder)
		npc.modo_interaccion_fisica = true 
		npcs_corriendo[npc] = puntos_carrera.pick_random()

func _verificar_victoria_final() -> void:
	if npcs_corriendo.is_empty() and npcs_regresando.is_empty():
		GameManager.juego_atrapados_activo = false
		if npc_principal != null:
			npc_principal.estado_actual = npc_principal.EstadoMision.LISTO_PARA_FINALIZAR
