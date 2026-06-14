extends CharacterBody2D

enum NpcType { IDLE, PATROL }
@export var type: NpcType = NpcType.IDLE
@export var speed: float = 30.0
@export var datos: DatosNPC

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_deteccion: Area2D = $AreaDeteccion
@onready var boton_popin: TextureButton = $BotonPopIn

var path_follow: PathFollow2D
var moving_forward: bool = true
var pausado_por_dialogo: bool = false

func _ready() -> void:
	boton_popin.hide()
	if type == NpcType.IDLE:
		anim.play("Idle")
	elif type == NpcType.PATROL:
		anim.play("Walk")
		# Verificamos si el nodo padre es un PathFollow2D
		if get_parent() is PathFollow2D:
			path_follow = get_parent()

func _physics_process(delta: float) -> void:
	if pausado_por_dialogo:
		return
	if type == NpcType.PATROL and path_follow:
		# Guardamos la posición X antes de movernos para saber a dónde mirar
		var old_x = global_position.x
		
		# Movemos el PathFollow2D
		if moving_forward:
			path_follow.progress += speed * delta
			# progress_ratio va de 0.0 (inicio) a 1.0 (final)
			if path_follow.progress_ratio >= 1.0:
				moving_forward = false
		else:
			path_follow.progress -= speed * delta
			if path_follow.progress_ratio <= 0.0:
				moving_forward = true
				
		# Volteamos el sprite comparando si fuimos a la izquierda o derecha
		if global_position.x > old_x:
			anim.flip_h = false
		elif global_position.x < old_x:
			anim.flip_h = true

func _al_jugador_entrar(body: Node2D) -> void:
	# Comprobamos si el cuerpo que entró al área es el Player
	if body.is_in_group("Player"):
		pausado_por_dialogo = true
		boton_popin.show()

func _al_jugador_salir(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pausado_por_dialogo = false
		boton_popin.hide()
		if type == NpcType.PATROL:
			anim.play("Walk")

func _al_presionar_popin() -> void:
	# Escondemos el botón para que no hagan "spam" de clics
	boton_popin.hide() 
	
	# Usamos un "Grupo" para avisarle a la Interfaz sin necesidad de cables
	if datos != null:
		get_tree().call_group("Interfaz", "iniciar_dialogo_npc", datos.dialogos)
