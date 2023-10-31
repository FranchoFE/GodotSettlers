extends Area3D

@export var pending_elements: int = 20

func _on_body_entered(body):
	print("ha entrado en el recurso el señor ", body.name, ". Quedan ", pending_elements, " elementos.")
	pending_elements -= 1


func _on_body_exited(body):
	print("hasta luego ", body.name)
