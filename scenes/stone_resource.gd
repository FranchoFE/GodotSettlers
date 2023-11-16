extends Node3D

const CONST = preload("res://scenes/constants.gd")

@export var mResource_type: String
var mPending_elements: int = 5
var mWait_time_timer = 1
var mWorkers_working_here = []


func _ready():
	print("inicializando ", name)
	for resource_type in $StaticBody3D/CollisionShape3D.get_children():
		if resource_type.name == mResource_type:
			resource_type.visible = true
		else:
			resource_type.visible = false
	
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
		print("Saliendo del recurso ", mResource_type, " por parte del trabajador ", body.name)
		mWorkers_working_here.erase(body)
		print("Ahora tenemos ", mWorkers_working_here.size(), " trabajadores aquí")
		
		if mWorkers_working_here.is_empty() and not $Timer.is_stopped():
			$Timer.stop()
		
	elif body.has_meta("player"):
		body.set_actual_resource(null)
		_goodby_animation()


func _on_timer_timeout():
	print("Timer del recurso")
	if not mWorkers_working_here.is_empty() and mPending_elements > 0:
		print("Timer del recurso cumplido con trabajadores = ", mWorkers_working_here.size())
		
		for worker in mWorkers_working_here:
			mPending_elements -= 1;
			worker.add_resource(mResource_type)
		
			if mPending_elements == 0:
				break
		
		if mPending_elements == 0:
			for worker in mWorkers_working_here:
				worker.finished_resources()
				_goodby_animation()
					
		print("Quedan de recursos = ", mPending_elements)
		
		
func _goodby_animation():
	var tween = get_tree().create_tween()
	if mResource_type == CONST.WOOD:
		tween.tween_property($StaticBody3D/CollisionShape3D/WOOD, "rotation", Vector3(0, 0, PI/2), 3)
	else:
		tween.tween_property($StaticBody3D/CollisionShape3D/STONE, "scale", Vector3(), 3)
		tween.tween_property($StaticBody3D/CollisionShape3D/STONE, "position", Vector3(0, -15, 0), 3)
	tween.tween_callback(self.hide)
	tween.tween_callback(self.queue_free)
	
		
