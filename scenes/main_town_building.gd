extends Node3D

var worker_scene = preload("res://scenes/worker_resource.tscn")

var mWorkers = []
var mMax_workers = 5


func _on_area_3d_body_entered(body):
	print("Ha entrado ", body.name, " en la casa")
	if body.has_meta("worker"):
		body.give_resources_to_town()


func _on_area_3d_body_exited(body):
	print("Ha salido ", body.name, " de la casa")
	
	
func create_new_worker():	
	if mWorkers.size() >= mMax_workers:
		return null
	
	var instance = worker_scene.instantiate()
	instance.position = self.global_position 
	instance.position.x = instance.position.x + 2
	instance.position.y = 0.5
	var resource_name = "worker_" + self.name + "_" + str(mWorkers.size() + 1)
	instance.name = resource_name
	instance.set_home(self)
	mWorkers.append(instance)
	
	return instance
