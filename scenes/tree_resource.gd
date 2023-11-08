extends Node3D

@export var pending_elements: int = 20

func _on_area_3d_body_entered(body):
	if pending_elements > 0:
		pending_elements -= 1	

func _on_area_3d_body_exited(body):
	pass
