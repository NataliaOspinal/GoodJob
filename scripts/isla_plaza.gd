extends Node2D

@export var puntos_carrera: Array[Marker2D] = []
@export var centro_plaza: Marker2D
@export var npc_principal: Node2D
var npcs_corriendo: Dictionary = {}
var npcs_esperando_charla: Array[Node2D] = []
var npcs_regresando: Array[Node2D] = []

func ejecutar_evento(id: String) -> void:
	match id:
		"estampida_npcs":
			_iniciar_minijuego()

func finalizar_evento(id: String) -> void:
	match id:
		"estampida_npcs":
			if GameManager.has_method("desbloquear_habilidad"):
				GameManager.desbloquear_habilidad("Escucha Activa")
			print("¡Minijuego completado y habilidad Escucha Activa obtenida!")

func _iniciar_minijuego() -> void:
	GameManager.npcs_atrapados = 0
	GameManager.juego_atrapados_activo = true
	
	var civiles = get_tree().get_nodes_in_group("NpcsPlaza")
	GameManager.meta_npcs = civiles.size()
	
	for npc in civiles:
		npc.type = npc.NpcType.CONTROL_EXTERNO
		npc.modo_interaccion_fisica = true
		npc.boton_popin.hide()
		
		# Conectamos cuando choca físicamente
		if not npc.fue_tocado_por_jugador.is_connected(_al_interceptar_npc):
			npc.fue_tocado_por_jugador.connect(_al_interceptar_npc)
			
		# Conectamos cuando termina de leer diálogo
		if not npc.is_connected("dialogo_cerrado", _al_terminar_charla_npc):
			npc.connect("dialogo_cerrado", _al_terminar_charla_npc)
		
		npcs_corriendo[npc] = puntos_carrera.pick_random()

func _physics_process(delta: float) -> void:
	if not GameManager.juego_atrapados_activo: return
		
	for npc in npcs_corriendo.keys():
		var destino_actual = npcs_corriendo[npc].global_position
		var direccion = (destino_actual - npc.global_position).normalized()
		npc.velocity = direccion * 180.0
		
		if npc.global_position.distance_to(destino_actual) < 20.0:
			npcs_corriendo[npc] = puntos_carrera.pick_random()

	for npc in npcs_regresando.duplicate():
		if centro_plaza == null: break
			
		var distancia = npc.global_position.distance_to(centro_plaza.global_position)
		if distancia > 15.0:
			var direccion = (centro_plaza.global_position - npc.global_position).normalized()
			npc.velocity = direccion * 50.0 
		else:
			# Llegaron al centro
			npc.velocity = Vector2.ZERO
			npc.type = npc.NpcType.IDLE
			npcs_regresando.erase(npc)
			_verificar_victoria_final()

func _al_interceptar_npc(npc_interceptado: Node2D) -> void:
	npcs_corriendo.erase(npc_interceptado)
	npcs_esperando_charla.append(npc_interceptado)
	
	npc_interceptado.modo_interaccion_fisica = false
	npc_interceptado.velocity = Vector2.ZERO
	
	npc_interceptado.boton_popin.show()

func _al_terminar_charla_npc(npc_hablado: Node2D) -> void:
	if npcs_corriendo.is_empty() and npcs_esperando_charla.is_empty() and npcs_regresando.is_empty():
		GameManager.juego_atrapados_activo = false
		print("¡Todos están a salvo en el centro!")
		
		if npc_principal != null:
			npc_principal.estado_actual = npc_principal.EstadoMision.DESPUES_DEL_EVENTO
			
func _verificar_victoria_final() -> void:
	if npcs_corriendo.is_empty() and npcs_esperando_charla.is_empty() and npcs_regresando.is_empty():
		GameManager.juego_atrapados_activo = false
		print("¡Todos están a salvo en el centro!")
		get_tree().call_group("GestorEventos", "finalizar_evento", "estampida_npcs")
