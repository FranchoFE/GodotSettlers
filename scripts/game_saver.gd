extends Node

var data_to_save: SettlersDataToSave
var worker_data_to_save: WorkerDataToSave

func save_game(data: SettlersDataToSave) -> void:	
	var file = FileAccess.open("user://settlers.save", FileAccess.WRITE)
	file.store_string(Constants.WOOD + "=" + str(data.wood) + "\n")
	file.store_string(Constants.STONE + "=" + str(data.stones) + "\n")
	file.store_string("Workers=%d\n" % data.workers.size())
	
	var index = 1
	for worker in data.workers:
		file.store_string("Worker_%d_Name=%s\n" % [index, worker.name])
		file.store_string("Worker_%d_Position=%f,%f,%f\n" % [index, 
			worker.position.x, worker.position.y, worker.position.z])
		file.store_string("Worker_%d_Home=%s\n" % [index, worker.home])	
		index += 1
	file.store_string("Buildings=%d\n" % data.buildings.size())
	
	index = 1
	for building in data.buildings:
		file.store_string("Building_%d_Name=%s\n" % [index, building.name])
		file.store_string("Building_%d_Position=%d,%d,%d\n" % [index, 
			round(building.position.x), round(building.position.y), round(building.position.z)])
		index += 1
	
func restore_game() -> SettlersDataToSave:
	var data_saved: SettlersDataToSave = SettlersDataToSave.new()
	var file = FileAccess.open("user://settlers.save", FileAccess.READ)
	if file == null:
		return 
		
	var file_as_text = file.get_as_text()
	var elements = file_as_text.split("\n")
	
	for element in elements:
		var variable = element.split("=")
		if variable[0] == Constants.WOOD:
			data_saved.wood = int(variable[1])
		elif variable[0] == Constants.STONE:
			data_saved.stones = int(variable[1])
		elif variable[0] == "Workers":
			var workers_num = int(variable[1])
			data_saved.workers = []
			for i in range(workers_num):
				data_saved.workers.append(WorkerDataToSave.new())
		elif variable[0].begins_with("Worker_"):
			var var_worker_index = int(variable[0].split("_")[1])
			var att = variable[0].split("_")[2]
			if att == "Name":
				data_saved.workers[var_worker_index-1].name = variable[1]
			elif att == "Position":
				var positions = variable[1].split(",")
				data_saved.workers[var_worker_index-1].position = Vector3(float(positions[0]), float(positions[1]), float(positions[2]))
			elif att == "Home":
				data_saved.workers[var_worker_index-1].home = variable[1]
		elif variable[0] == "Buildings":
			var buildings_num = int(variable[1])
			data_saved.buildings = []
			for i in range(buildings_num):
				data_saved.buildings.append(BuildingDataToSave.new())
		elif variable[0].begins_with("Building_"):
			var var_building_index = int(variable[0].split("_")[1])
			var att = variable[0].split("_")[2]
			if att == "Name":
				var length = data_saved.buildings.size()
				data_saved.buildings[var_building_index-1].name = variable[1]
			elif att == "Position":
				var positions = variable[1].split(",")
				data_saved.buildings[var_building_index-1].position = Vector3(float(positions[0]), float(positions[1]), float(positions[2]))
			
	return data_saved
