extends Node

var chunk_scene = preload("res://scenes/floor_chunks.tscn")
var building_scene = preload("res://scenes/main_town_building.tscn")

var stones: int = 500
var wood: int = 500
var draw_building_mode: bool = false


func _ready():
	_on_create_chunk(0, 0)


func _process(delta):
	# Se crea un nuevo recurso	
	if Input.is_action_just_pressed("new resource"):
		var nearest_building = _find_nearest_building_to_player()
		var instance = nearest_building.create_new_worker()
		if instance != null:
			$Workers.add_child(instance)
		else:
			print("No se ha podido crear el trabajador")
	elif Input.is_action_just_pressed("new building"):
		_change_draw_building_mode()
	elif Input.is_action_just_pressed("select_action"):
		_build_new_building(_get_mouse_position_in_floor())
		_change_draw_building_mode()
			
	if draw_building_mode:
		_draw_next_building_position()


func _change_draw_building_mode():
	draw_building_mode = not draw_building_mode
	if draw_building_mode:
		if stones < 100 or wood < 200:
			$GUI.show_message("No tienes los recursos suficientes\npara crear una casa")
			draw_building_mode = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$World/FloorChunks/NewBuildingMark.visible = true
	elif not draw_building_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$World/FloorChunks/NewBuildingMark.visible = false
	get_viewport().set_input_as_handled()


func _on_player_locked_worker_signal(worker):
	$GUI.selected_worker(worker)
	
		
func add_resources(resources, resource_type):
	if resource_type == "STONE":
		stones += resources
	elif resource_type == "WOOD":
		wood += resources
	$GUI.update_resources(stones, wood)


func _on_create_chunk(i, j):
	print("Recibida señal para crear el floor chunk ", i, " - ", j)
	var chunk_scene_instance = chunk_scene.instantiate()
	chunk_scene_instance.name = "FloorChunk_" + str(i) + "_" + str(j)
	chunk_scene_instance.position = Vector3(i*100, -0.5, j*100)
	
	chunk_scene_instance.create_chunk.connect(_on_create_chunk)
	
	$World/FloorChunks.add_child(chunk_scene_instance)


func _get_mouse_position_in_floor():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		var viewport = get_viewport()
		var mouse_position = viewport.get_mouse_position()
		var camera = viewport.get_camera_3d()
		var origin = camera.project_ray_origin(mouse_position)
		var direction = camera.project_ray_normal(mouse_position)
		
		var ray_length = camera.far
		var end = origin + direction * ray_length
		
		var space_state = $World.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = space_state.intersect_ray(query)
		
		var mouse_position_3D:Vector3 = result.get("position", end)
		mouse_position_3D.y = 0
		
		return mouse_position_3D


func _draw_next_building_position():
	var mouse_position_3D = _get_mouse_position_in_floor()
	$World/FloorChunks/NewBuildingMark.position = mouse_position_3D
		
	
func _build_new_building(pos: Vector3):
	var instance = building_scene.instantiate()
	$Buildings.add_child(instance)
	var building_name = "Building_" + str($Buildings.get_child_count())
	instance.name = building_name
	instance.position = pos
	instance.global_scale(Vector3.ONE * 3)
	
	stones -= 100
	wood -= 200
	
	$GUI.update_resources(stones, wood)

	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F8:
				get_tree().quit()
			KEY_F10:
				var vp = get_viewport()
				vp.debug_draw = (vp.debug_draw + 1 ) % 4
				get_viewport().set_input_as_handled()

func _find_nearest_building_to_player():
	var min_distance_found: float = -1.0
	var min_building_found = null
	for building in $Buildings.get_children():
		var player_position: Vector3 = $Player.global_position
		var building_position: Vector3 = building.global_position
		
		var actual_distance = player_position.distance_to(building_position)
		if min_distance_found < 0 or min_distance_found > actual_distance:
			min_building_found = building
			min_distance_found = actual_distance
	
	print("El edificio más cercano encontrado es ", min_building_found.name)		
	return min_building_found
