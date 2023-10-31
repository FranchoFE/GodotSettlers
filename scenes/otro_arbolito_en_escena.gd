extends Node3D

@export var pending_elements: int = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	print("Entrando en el recurso por parte de ", body.name, ". Quedan ", pending_elements, " elementos.")
	if pending_elements > 0:
		pending_elements -= 1	

func _on_area_3d_body_exited(body):
	print("Saliendo del recurso por parte de ", body.name)
