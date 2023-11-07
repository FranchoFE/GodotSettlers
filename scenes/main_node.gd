extends Node

var worker_scene = preload("res://scenes/worker_resource.tscn")
var chunck_scene = preload("res://scenes/floor_chunk3.tscn")

var stones = 0
var trees = 0


func _process(delta):
	# Se crea un nuevo recurso	
	if Input.is_action_just_pressed("new resource"):
		var instance = worker_scene.instantiate()
		# instance.global_scale(Vector3.ONE * 3)
		instance.position = $InitialResourcesPosition.global_position
		instance.position.y = 0.5
		add_child(instance)


func _on_player_locked_worker_signal(worker):
	if worker != null:
		$GUI/ActionLabel.set_text("Seleccionado trabajador " + str(worker.name))
	else:
		$GUI/ActionLabel.set_text("Ningún trabajador seleccionado")
	
		
func add_resources(resources):
	stones += resources
	$GUI/StoneLabel.text = "Piedra: " + str(stones)
