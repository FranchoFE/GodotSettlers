extends Node3D


func _on_area_3d_body_entered(body):
	print("Ha entrado ", body.name, " en la casa")
	if body.has_meta("worker"):
		var resources = body.give_resources_to_town()
		


func _on_area_3d_body_exited(body):
	print("Ha salido ", body.name, " de la casa")
