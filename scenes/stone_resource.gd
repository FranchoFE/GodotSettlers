extends Node3D

var mPending_elements: int = 20
var mWait_time_timer = 1
var mWorker_working_here = null


func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	mPending_elements = random.randi_range(20, 100)


func _on_area_3d_body_entered(body):
	print("STONE - Entrando en el recurso por parte de ", body.name, ". Quedan ", mPending_elements, " elementos.")
	if body.has_meta("worker") and $Timer.is_stopped() and mPending_elements != 0:
		$Timer.start(mWait_time_timer)
		mWorker_working_here = body
		mWorker_working_here.start_work()
		

func _on_area_3d_body_exited(body):
	print("STONE - Saliendo del recurso por parte de ", body.name)
	if body.has_meta("worker"):
		if not $Timer.is_stopped():
			$Timer.stop()
		mWorker_working_here = null


func _on_timer_timeout():
	if mWorker_working_here != null:
		print("Timer del recurso cumplido")
		mPending_elements -= 1;
		mWorker_working_here.add_resource()
		
		if mPending_elements == 0:
			mWorker_working_here.finished_resources()
			hide()
			queue_free()
		
