extends Node2D

@export var puntos_carrera: Array[Marker2D] = []

var npcs_corriendo: Dictionary = {}

func ejecutar_evento(id: String) -> void:
	match id:
		"estampida_npcs":
			_iniciar_minijuego()

func _iniciar_minijuego() -> void:
	GameManager.npcs_atrapados = 0
	GameManager.juego_atrapados_activo = true
	
	var civiles = get_tree().get_nodes_in_group("NpcsPlaza")
	GameManager.meta_npcs = civiles.size()
	
	for npc in civiles:
		# Configuramos al NPC en modo Marioneta
		npc.type = npc.NpcType.CONTROL_EXTERNO
		npc.modo_interaccion_fisica = true
		npc.boton_popin.hide()
		
		npc.fue_tocado_por_jugador.connect(_al_atrapar_npc)
		
		npcs_corriendo[npc] = puntos_carrera.pick_random()

func _physics_process(delta: float) -> void:
	if not GameManager.juego_atrapados_activo: 
		return
		
	# En cada frame, la Isla mueve a todos los NPCs como piezas de ajedrez
	for npc in npcs_corriendo.keys():
		var destino_actual = npcs_corriendo[npc].global_position
		
		var direccion = (destino_actual - npc.global_position).normalized()
		npc.velocity = direccion * 180.0 # Velocidad de huida rápida
		
		if npc.global_position.distance_to(destino_actual) < 20.0:
			npcs_corriendo[npc] = puntos_carrera.pick_random()

func _al_atrapar_npc(npc_atrapado: Node2D) -> void:
	npcs_corriendo.erase(npc_atrapado)
	
	npc_atrapado.type = npc_atrapado.NpcType.IDLE
	npc_atrapado.modo_interaccion_fisica = false
	npc_atrapado.velocity = Vector2.ZERO
	
	GameManager.npcs_atrapados += 1
	print("¡Atrapaste a uno! Llevas: ", GameManager.npcs_atrapados, "/", GameManager.meta_npcs)
	
	if GameManager.npcs_atrapados >= GameManager.meta_npcs:
		GameManager.juego_atrapados_activo = false
		print("¡Minijuego completado!")
		get_tree().call_group("GestorEventos", "finalizar_evento", "estampida_npcs")
