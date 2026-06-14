extends Node2D

@onready var player = $Player

func _ready() -> void:
	# Si venimos de regreso de una isla
	if GameManager.regresando_al_overworld:
		# Movemos al jugador a la posición que habíamos guardado
		player.global_position = GameManager.posicion_overworld
		# Apagamos el interruptor para la próxima vez
		GameManager.regresando_al_overworld = false
