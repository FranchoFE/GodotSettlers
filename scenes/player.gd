extends CharacterBody3D

signal locked_worker_signal(worker)

@export var MOVE_SPEED: float = 20.0
@export var JUMP_SPEED: float = 35.0
var mSelected_worker = null
var mLocked_worker = null


func _physics_process(delta) -> void:
	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z) * MOVE_SPEED
	velocity.x = h_veloc.x
	velocity.z = h_veloc.y
	velocity.y -= 20 * delta
	
	
	if not is_on_floor():
		if velocity.y > 0:
			$SophiaSkin.jump()
		elif velocity.y < 0:
			$SophiaSkin.fall()
	else:
		if direction != Vector3.ZERO:
			$SophiaSkin.look_at(direction * 1000, Vector3.UP, true)
			$SophiaSkin.move()
		else:
			$SophiaSkin.idle()
	
	move_and_slide()
	
func vector3ToString(vector):
	return "" + str(vector.x) + ", " + str(vector.y) + ", " + str(vector.z) 

# Returns the input vector relative to the camera. Forward is always the direction the camera is facing
func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("left"):
		input_dir += $CameraManager.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_dir -= $CameraManager.global_transform.basis.x
	if Input.is_action_pressed("forward"):
		input_dir += $CameraManager.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		input_dir -= $CameraManager.global_transform.basis.z
	if Input.is_action_just_pressed("up") and self.is_on_floor():
		velocity.y += JUMP_SPEED
	if Input.is_action_pressed("down"):
		velocity.y -= JUMP_SPEED
	if Input.is_action_just_pressed("lock"):
		_lock_worker(mSelected_worker)
	if Input.is_action_just_pressed("work"):
		_send_worker_to_work(mLocked_worker)
	if Input.is_key_pressed(KEY_KP_ADD) or Input.is_key_pressed(KEY_EQUAL):
		MOVE_SPEED = clamp(MOVE_SPEED + .5, 0, 9999)
	if Input.is_key_pressed(KEY_KP_SUBTRACT) or Input.is_key_pressed(KEY_MINUS):
		MOVE_SPEED = clamp(MOVE_SPEED - .5, 0, 9999)
				
	return input_dir


func _lock_worker(worker_to_lock):
	if worker_to_lock != null:
		print("Se ha seleccionado el trabajador ", worker_to_lock.name)
		worker_to_lock.locked_worker()
		
		if mLocked_worker != null:
			mLocked_worker.unlocked_worker()
		
	elif mLocked_worker != null:
		print("Se deselecciona el trabajador ", mLocked_worker.name)
		mLocked_worker.unlocked_worker()
	mLocked_worker = worker_to_lock
	locked_worker_signal.emit(mLocked_worker)
	

func _send_worker_to_work(worker):
	if worker != null:
		print("Se manda a trabajar al trabajador ", worker.name)
		var position_to_work = position
		position_to_work.y = 0.5
		worker.go_to_work(position_to_work)
	else:
		print("No se puede mandar a nadie a trabajar porque no hay trabajador seleccionado")


func _on_resources_detector_body_entered(body):
	if body.has_meta("worker"):
		print("Colisión detectada con el trabajador ", body.name)
		mSelected_worker = body
	else:
		print("Colisión detectada con " + body.name + " por parte de " + name)


func _on_resources_detector_body_exited(body):
	print("se acabó la colisión detectada con " + body.name)
	if mSelected_worker == body:
		mSelected_worker = null
