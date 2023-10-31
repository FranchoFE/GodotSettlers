extends Node3D

@export var pending_elements: int = 20

func _on_area_3d_body_entered(body):
	print("STONE - Entrando en el recurso por parte de ", body.name, ". Quedan ", pending_elements, " elementos.")
	if pending_elements > 0:
		pending_elements -= 1	

func _on_area_3d_body_exited(body):
	print("STONE - Saliendo del recurso por parte de ", body.name)
