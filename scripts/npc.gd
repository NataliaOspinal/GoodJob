extends CharacterBody2D

enum NpcType { IDLE, PATROL }
enum EstadoMision { ANTES_DEL_EVENTO, EVENTO_EN_PROGRESO, LISTO_PARA_FINALIZAR, COMPLETADO }

@export var type: NpcType = NpcType.IDLE
@export var speed: float = 30.0

@export var datos: DatosNPC

@export_group("Visuales del NPC")
@export var usar_estatico: bool = false
@export var textura_estatica: Texture2D
@export var frames_animados: SpriteFrames
@export var icono_popin_personalizado: Texture2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $SpriteEstatico
@onready var area_deteccion: Area2D = $AreaDeteccion
@onready var boton_popin: TextureButton = $BotonPopIn

var path_follow: PathFollow2D
var moving_forward: bool = true
var pausado_por_dialogo: bool = false
var estado_actual: EstadoMision = EstadoMision.ANTES_DEL_EVENTO

func _ready() -> void:
	boton_popin.hide()
	if icono_popin_personalizado != null:
		boton_popin.texture_normal = icono_popin_personalizado
		
	# Configuración Visual
	if usar_estatico:
		anim.hide()
		sprite.show()
		if textura_estatica != null:
			sprite.texture = textura_estatica
	else:
		sprite.hide()
		anim.show()
		if frames_animados != null:
			anim.sprite_frames = frames_animados
			
	if not usar_estatico and type == NpcType.IDLE:
		anim.play("Idle")
			
	if type == NpcType.PATROL and get_parent() is PathFollow2D:
		path_follow = get_parent()
		

func _physics_process(delta: float) -> void:
	if pausado_por_dialogo:
		if not usar_estatico:
			anim.play("Idle") 
		return 
		
	if type == NpcType.PATROL and path_follow:
		var old_pos = global_position
		
		if moving_forward:
			path_follow.progress += speed * delta
			if path_follow.progress_ratio >= 1.0:
				moving_forward = false
		else:
			path_follow.progress -= speed * delta
			if path_follow.progress_ratio <= 0.0:
				moving_forward = true
				
		# --- LÓGICA DE 4 DIRECCIONES ---
		var direction = global_position - old_pos
		if direction.length() > 0.1: # Si nos movimos
			_update_animations(direction)

func _update_animations(direction: Vector2) -> void:
	if usar_estatico:
		# Si es una estatua o imagen fija, solo lo volteamos
		sprite.flip_h = (direction.x < 0)
		return
		
	if abs(direction.x) > abs(direction.y):
		anim.play("Left")
		anim.flip_h = (direction.x > 0) # Lo volteamos si va a la derecha
	else:
		if direction.y < 0:
			anim.play("Up")
		else:
			anim.play("Down")
		anim.flip_h = false

# Logica de interaccion y eventos
func _al_jugador_entrar(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if datos != null and datos.es_npc_especial:
			if estado_actual == EstadoMision.EVENTO_EN_PROGRESO and GameManager.mision_resuelta:
				estado_actual = EstadoMision.LISTO_PARA_FINALIZAR
		
		pausado_por_dialogo = true
		boton_popin.show()

func _al_jugador_salir(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pausado_por_dialogo = false
		boton_popin.hide()

func _al_presionar_popin() -> void:
	boton_popin.hide()
	
	if datos == null:
		return
		
	# Si NO es especial, simplemente lee los textos de la Fase 1 como un diálogo normal
	if not datos.es_npc_especial:
		get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogos_fase_1, self)
		return
		
	# Si SÍ es especial, navega por las fases
	match estado_actual:
		EstadoMision.ANTES_DEL_EVENTO:
			get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogos_fase_1, self)
		EstadoMision.EVENTO_EN_PROGRESO:
			get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogo_recordatorio, self)
		EstadoMision.LISTO_PARA_FINALIZAR:
			get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogos_fase_2, self)
		EstadoMision.COMPLETADO:
			get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogo_bucle_final, self)

func on_dialogo_terminado() -> void:
	if datos != null and datos.es_npc_especial:
		match estado_actual:
			EstadoMision.ANTES_DEL_EVENTO:
				estado_actual = EstadoMision.EVENTO_EN_PROGRESO
				if datos.id_evento != "":
					# Avisamos que el evento INICIA
					get_tree().call_group("GestorEventos", "ejecutar_evento", datos.id_evento)
					
			EstadoMision.LISTO_PARA_FINALIZAR:
				estado_actual = EstadoMision.COMPLETADO
				if datos.id_evento != "":
					get_tree().call_group("GestorEventos", "finalizar_evento", datos.id_evento)
				
	pausado_por_dialogo = false
