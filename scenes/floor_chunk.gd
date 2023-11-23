extends Node3D

@export var first_one = false
var stone_resource_scene = preload("res://scenes/stone_resource.tscn")
var seed_id: int
var random = RandomNumberGenerator.new()

signal create_chunk(i, j)


func _ready():
	print("FloorChunk ready. First one = ", first_one)
	create_children()


func create_children():
	random.randomize()

	var instance: Node3D = null
			
	for resource_type in [Constants.STONE, Constants.WOOD]:
		for i in range(_how_much_of(resource_type)):
			instance = stone_resource_scene.instantiate()
			instance.mResource_type = resource_type
			instance.name = resource_type + "_" + str(i) + "_" + self.name
			print("Establecido ", resource_type, " al recurso ", instance.name)
			add_child(instance)
			instance.set_meta("resource", true)
			instance.global_scale(Vector3.ONE * 3)
			var pos_x = _get_position_for(resource_type, i*6358, 181)
			var pos_z = _get_position_for(resource_type, i*4582, 846)
			
			if first_one and abs(pos_x) < 10 and abs(pos_z) < 10:
				continue
				
				# print("Ojo. Estamos en el first_one floor_chunk y la posición que ha salido es " + str(pos_x) + ", " + str(pos_z))
				# pos_x = random.randi_range(-50, 50)
				# pos_z = random.randi_range(-50, 50)
			
			print("Recurso ", instance.name," creado en " + str(pos_x) + ", " + str(pos_z))
			instance.position = Vector3(pos_x, 2, pos_z)


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		print("Ha entrado " + body.name + " en el FloorChunk: " + name)
		
		var first_index = int(name.split("_")[1])
		var second_index = int(name.split("_")[2])
		for i in range(first_index - 1, first_index + 2):
			for j in range(second_index - 1, second_index + 2):
				var must_create_chunk = not _exists_chunk(i, j)
				if must_create_chunk:
					print("Se emite la señal para crear el chunk ", i, " - ", j)
					create_chunk.emit(i, j)
					
		
func _exists_chunk(i, j):
	for children in get_parent().get_children():
		if children.name == "FloorChunk_" + str(i) + "_" + str(j):
			return true
	return false
	
func _how_much_of(resource: String):
	# return random.randi_range(5, 10)
	return (seed_id * (resource.length() + 2) * Constants.SEED) % 20
			
func _get_position_for(resource, index, x_or_y):
	# return random.randi_range(-50, 50)
	#return ((seed_id * (resource.length() + 2) * Constants.SEED * (index+1) * x_or_y) + 2457) % 100 - 50
	return (((seed_id * (resource.length() + 2) * Constants.SEED * (index+1)) % 3614) * seed_id) % 100 - 50
