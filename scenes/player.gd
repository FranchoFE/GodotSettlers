extends CharacterBody3D

@export var MOVE_SPEED: float = 20.0
@export var JUMP_SPEED: float = 2.0

func _physics_process(delta) -> void:
	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z) * MOVE_SPEED
	velocity.x = h_veloc.x
	velocity.z = h_veloc.y
	velocity.y -= 20 * delta
	move_and_slide()

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
	if Input.is_action_pressed("up"):
		velocity.y += JUMP_SPEED
	if Input.is_action_pressed("down"):
		velocity.y -= JUMP_SPEED
	if Input.is_key_pressed(KEY_KP_ADD) or Input.is_key_pressed(KEY_EQUAL):
		MOVE_SPEED = clamp(MOVE_SPEED + .5, 0, 9999)
	if Input.is_key_pressed(KEY_KP_SUBTRACT) or Input.is_key_pressed(KEY_MINUS):
		MOVE_SPEED = clamp(MOVE_SPEED - .5, 0, 9999)
	return input_dir		


func _on_resources_detector_body_entered(body):
	print("colisión detectada con " + body.name)


func _on_resources_detector_body_exited(body):
	print("se acabó la colisión detectada con " + body.name)
