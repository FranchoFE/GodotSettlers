extends Node3D

@export var mResource_type: String
var mPending_elements: int = 20
var mWait_time_timer = 1
var mWorkers_working_here = []


func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	mPending_elements = random.randi_range(20, 100) 


func _on_area_3d_body_entered(body):
	if body.has_meta("worker") and mPending_elements != 0 and body.mPlace_to_work == self:
		print("Entrando en el recurso por parte del trabajador ", body.name, ". Quedan ", mPending_elements, " elementos.")	
		mWorkers_working_here.append(body)
		print("Ahora tenemos aquí ", mWorkers_working_here.size()," trabajadores = ")
		body.start_work()
		
		if $Timer.is_stopped():
			$Timer.start(mWait_time_timer)
		
	elif body.has_meta("player"):
		print("es player")
		body.set_actual_resource(self)
		

func _on_area_3d_body_exited(body):
	if body.has_meta("worker"):
		print("STONE - Saliendo del recurso por parte del trabajador ", body.name)
		mWorkers_working_here.erase(body)
		print("Ahora tenemos ", mWorkers_working_here.size(), " trabajadores aquí")
		
		if mWorkers_working_here.is_empty() and not $Timer.is_stopped():
			$Timer.stop()
		
	elif body.has_meta("player"):
		body.set_actual_resource(null)


func _on_timer_timeout():
	print("Timer del recurso")
	if not mWorkers_working_here.is_empty() and mPending_elements > 0:
		print("Timer del recurso cumplido con recursos = ", mWorkers_working_here.size())
		
		for worker in mWorkers_working_here:
			mPending_elements -= 1;
			worker.add_resource(mResource_type)
		
			if mPending_elements == 0:
				break
		
		if mPending_elements == 0:
			for worker in mWorkers_working_here:
				worker.finished_resources()
				hide()
				queue_free()
		
