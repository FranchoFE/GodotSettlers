extends Node

var chunk_scene = preload("res://scenes/floor_chunks.tscn")
var building_scene = preload("res://scenes/main_town_building.tscn")

var stone_in_town: int = 500
var wood_in_town: int = 500
var draw_building_mode: bool = false


func _ready():
	var data_saved: SettlersDataToSave = GameSaver.restore_game()
	stone_in_town = data_saved.stones
	wood_in_town = data_saved.wood
	
	$GUI.update_resources(stone_in_town, wood_in_town)
	_on_create_chunk(0, 0)
	
	for building in data_saved.buildings:
		if building.name != "MainTownBuilding":
			_build_new_building(building.position, building.name)
	
	for worker in data_saved.workers:
		var building_found = null
		for building in $Buildings.get_children():
			if building.name == worker.home:
				building_found = building
				break
		if building_found != null:
			var instance = building_found.create_new_worker()
			instance.global_position = worker.position
			if instance != null:
				$Workers.add_child(instance)
			else:
				print("No se ha podido crear el trabajador")


func _process(_delta):
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
		_build_new_building(_get_mouse_position_in_floor(), "")
		_change_draw_building_mode()
			
	if draw_building_mode:
		_draw_next_building_position()


func _change_draw_building_mode():
	draw_building_mode = not draw_building_mode
	if draw_building_mode:
		if stone_in_town < 100 or wood_in_town < 200:
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
	if resource_type == Constants.STONE:
		stone_in_town += resources
	elif resource_type == Constants.STONE:
		wood_in_town += resources
	$GUI.update_resources(stone_in_town, wood_in_town)


func _on_create_chunk(i, j):
	print("Recibida señal para crear el floor chunk ", i, " - ", j)
	var chunk_scene_instance = chunk_scene.instantiate()
	chunk_scene_instance.name = "FloorChunk_" + str(i) + "_" + str(j)
	chunk_scene_instance.first_one = true
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
		
	
func _build_new_building(pos: Vector3, building_name: String):
	if building_name == null or building_name.length() == 0:
		building_name = "Building_" + str($Buildings.get_child_count())
	
	var instance = building_scene.instantiate()
	$Buildings.add_child(instance)
	instance.name = building_name
	instance.position = pos
	instance.global_scale(Vector3.ONE * 3)
	
	stone_in_town -= 100
	wood_in_town -= 200
	
	$GUI.update_resources(stone_in_town, wood_in_town)

	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F8:
				get_tree().quit()
			KEY_F10:
				var vp = get_viewport()
				vp.debug_draw = (vp.debug_draw + 1 ) % 4
				get_viewport().set_input_as_handled()
		
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("go_home"):
		var data_to_save = SettlersDataToSave.new()
		data_to_save.stones = stone_in_town
		data_to_save.wood = wood_in_town
			
		for building in $Buildings.get_children():
			var building_to_save = BuildingDataToSave.new()
			building_to_save.name = building.name
			building_to_save.position = building.global_position
			data_to_save.buildings.append(building_to_save)
			for worker in building.mWorkers:
				var worker_to_save = WorkerDataToSave.new()
				worker_to_save.name = worker.name
				worker_to_save.position = worker.global_position
				worker_to_save.home = building.name
				data_to_save.workers.append(worker_to_save)
		
		GameSaver.save_game(data_to_save)
		SceneSwitcher.switch_scene("res://scenes/inside_building.tscn")


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
