extends Node3D

var tree_resource_scene = preload("res://scenes/tree_resource.tscn")
var stone_resource_scene = preload("res://scenes/stone_resource.tscn")


func _ready():
	print("FloorChunck ready")
	_create_children()

func _create_children():
	var random = RandomNumberGenerator.new()
	random.randomize()

	var instance: Node3D = null
	
	for i in range(random.randi_range(5, 10)):
		instance = tree_resource_scene.instantiate()
		instance.global_scale(Vector3.ONE * 3)
		instance.position = Vector3(random.randi_range(-50, 50), 1.5, random.randi_range(-50, 50))
		add_child(instance)
		
	for i in range(random.randi_range(5, 10)):
		instance = stone_resource_scene.instantiate()
		instance.global_scale(Vector3.ONE * 3)
		instance.position = Vector3(random.randi_range(-50, 50), 1.5, random.randi_range(-50, 50))
		add_child(instance)
