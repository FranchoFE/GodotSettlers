extends Node

var worker_scene = preload("res://scenes/worker_resource.tscn")
var chunk_scene = preload("res://scenes/floor_chunks.tscn")
var building_scene = preload("res://scenes/main_town_building.tscn")

var stones = 0
var wood = 0


func _process(delta):
	# Se crea un nuevo recurso	
	if Input.is_action_just_pressed("new resource"):
		var instance = worker_scene.instantiate()
		# instance.global_scale(Vector3.ONE * 3)
		instance.position = $InitialResourcesPosition.global_position
		instance.position.y = 0.5
		add_child(instance)
		
	_draw_right_gui()
	_set_next_building_position()


func _on_player_locked_worker_signal(worker):
	if worker != null:
		$GUI/ActionLabel.set_text("Seleccionado trabajador " + str(worker.name))
	else:
		$GUI/ActionLabel.set_text("Ningún trabajador seleccionado")
	
		
func add_resources(resources, resource_type):
	if resource_type == "STONE":
		stones += resources
		$GUI/StoneLabel.text = "Piedra: " + str(stones)
	elif resource_type == "WOOD":
		wood += resources
		$GUI/WoodLabel.text = "Madera: " + str(wood)


func _on_create_chunk(i, j):
	print("Recibida señal para crear el floor chunk ", i, " - ", j)
	var chunk_scene_instance = chunk_scene.instantiate()
	chunk_scene_instance.name = "FloorChunk_" + str(i) + "_" + str(j)
	chunk_scene_instance.position = Vector3(i*100, -0.5, j*100)
	
	chunk_scene_instance.create_chunk.connect(_on_create_chunk)
	
	$World/FloorChunks.add_child(chunk_scene_instance)


func _draw_right_gui():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		$RightGUI/Label.text = "FPS: " + str(roundi(Engine.get_frames_per_second()))


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


func _set_next_building_position():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		var mouse_position_3D = _get_mouse_position_in_floor()
		$World/FloorChunks/NewBuildingMark.position = mouse_position_3D

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and event.button_index == 1:
		print("Pulsado botón de ratón ", event)
		var mouse_position_3D = _get_mouse_position_in_floor()
		_draw_new_building(mouse_position_3D)
		
	
func _draw_new_building(pos: Vector3):
	var instance = building_scene.instantiate()
	$Buildings.add_child(instance)
	instance.position = pos
	instance.global_scale(Vector3.ONE * 3)

	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F8:
				get_tree().quit()
			KEY_F10:
				var vp = get_viewport()
				vp.debug_draw = (vp.debug_draw + 1 ) % 4
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					$World/FloorChunks/NewBuildingMark.visible = false
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					$World/FloorChunks/NewBuildingMark.visible = true
				get_viewport().set_input_as_handled()


