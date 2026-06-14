extends Resource
class_name DatosNPC

@export var nombre_npc: String

@export_group("Configuración de Misión/Evento")
@export var es_npc_especial: bool = false
@export var id_evento: String = ""

@export_group("Textos")
@export_multiline var dialogos_fase_1: Array[String] 
@export_multiline var dialogo_recordatorio: Array[String]
@export_multiline var dialogos_fase_2: Array[String]
@export_multiline var dialogo_bucle_final: Array[String]
