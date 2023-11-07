extends Node3D

@export var first_one = false
var tree_resource_scene = preload("res://scenes/tree_resource.tscn")
var stone_resource_scene = preload("res://scenes/stone_resource.tscn")
var chunck_scene = preload("res://scenes/floor_chunk3.tscn")


func _ready():
	print("FloorChunk ready. First one = ", first_one)
	create_children()


func create_children():
	var random = RandomNumberGenerator.new()
	random.randomize()

	var instance: Node3D = null
	
	for i in range(random.randi_range(5, 10)):
		instance = tree_resource_scene.instantiate()
		instance.global_scale(Vector3.ONE * 3)
		var pos_x = random.randi_range(-50, 50)
		var pos_z = random.randi_range(-50, 50)
		
		while first_one and abs(pos_x) < 10 and abs(pos_z) < 10:
			pos_x = random.randi_range(-50, 50)
			pos_z = random.randi_range(-50, 50)
			
		instance.position = Vector3(pos_x, 1.5, pos_z)
		add_child(instance)
		
	for i in range(random.randi_range(5, 10)):
		instance = stone_resource_scene.instantiate()
		instance.global_scale(Vector3.ONE * 3)
		var pos_x = random.randi_range(-50, 50)
		var pos_z = random.randi_range(-50, 50)
		
		while first_one and abs(pos_x) < 10 and abs(pos_z) < 10:
			pos_x = random.randi_range(-50, 50)
			pos_z = random.randi_range(-50, 50)
			
		instance.position = Vector3(pos_x, 1.5, pos_z)
		add_child(instance)


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		print("Ha entrado " + body.name + " en el FloorChunk: " + name)
		
		var first_index = int(name.split("_")[1])
		var second_index = int(name.split("_")[2])
		for i in range(first_index - 1, first_index + 2):
			for j in range(second_index - 1, second_index + 2):
				var must_create_chunk = not _exists_chunk(i, j)
				if must_create_chunk:
					_create_chunk(i, j)
	
func _create_chunk(i, j):
	print("Vamos a crear el chunk " + str(i) + ", " + str(j))
	var chunk_scene_instance = chunck_scene.instantiate()
	chunk_scene_instance.name = "FloorChunk_" + str(i) + "_" + str(j)
	chunk_scene_instance.position = Vector3(i*100, 0, j*100)
	get_parent().add_child(chunk_scene_instance)
		
func _exists_chunk(i, j):
	for children in get_parent().get_children():
		if children.name == "FloorChunk_" + str(i) + "_" + str(j):
			return true
	return false
			
