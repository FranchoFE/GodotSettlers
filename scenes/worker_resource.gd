extends CharacterBody3D

@export var speed = 3
var target = null
var mPlace_to_work = null
var mResources = 0
var mResource_type: String

func _ready():
	print("Creando trabajador")


func _physics_process(delta):
	if target != null:
		velocity = position.direction_to(target) * speed
		look_at(target)
		if position.distance_to(target) > 1:
			move_and_slide()
		else:
			$Area3D/GobotSkin.idle()


func _on_timer_timeout():
	print("Worker timeout")
	
	
func go_to_work(position_to_work):
	print("Soy ", name, " y me mandan a currar a ", position_to_work)
	mPlace_to_work = position_to_work
	target = position_to_work
	$Area3D/GobotSkin.run()
	
	
func locked_worker():
	$WSI_Selected.visible = true
	

func unlocked_worker():
	$WSI_Selected.visible = false
	
	
func _go_to_start_point():
	$WSI_Working.visible = false
	var initial_position = get_node("/root/MainNode/InitialResourcesPosition").position
	initial_position.y = 0.5
	target = initial_position
	$Area3D/GobotSkin.run()
	

func add_resource(resource_type):
	mResource_type = resource_type
	mResources += 1
	if mResources == 5:
		_go_to_start_point()
	
	
func finished_resources():
	mPlace_to_work = null
	_go_to_start_point()
	
	
func start_work():
	$WSI_Working.visible = true
	$WSI_Selected.visible = false
	
	
func give_resources_to_town():
	var resources = mResources
	if mResources != 0:
		get_node("/root/MainNode").add_resources(resources, mResource_type)
		mResources = 0
		target = mPlace_to_work
		
	if mPlace_to_work == null:
		$Area3D/GobotSkin.idle()
		
	
	return resources
