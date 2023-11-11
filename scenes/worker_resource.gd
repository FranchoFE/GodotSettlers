extends CharacterBody3D

@export var speed = 3
var target = null
var mPlace_to_work = null
var mResources = 0
var mResource_type: String
var random = RandomNumberGenerator.new()
var mHome: Node3D = null

func _ready():
	print("Creando trabajador")
	random.randomize()


func _physics_process(delta):
	if target != null:
		velocity = position.direction_to(target) * speed
		look_at(target)
		if position.distance_to(target) > 2:
			move_and_slide()
		else:
			$Area3D/GobotSkin.idle()


func _on_timer_timeout():
	# Ahora sí vamos al lugar de trabajo
	if mPlace_to_work != null:
		target = mPlace_to_work.global_position
		target.y = 0
		$Area3D/GobotSkin.run()
	
	
func go_to_work(resource):
	print("Soy ", name, " y me mandan a currar a ", resource)
	mPlace_to_work = resource
	if resource != null:
		_calc_intermediate_to_work()
	
	
func locked_worker():
	$WSI_Selected.visible = true
	

func unlocked_worker():
	$WSI_Selected.visible = false
	

func set_home(building):
	mHome = building
	
	
func _go_to_start_point():
	$WSI_Working.visible = false
	target = mHome.global_position
	target.y = 0.5
	target.x = target.x + 2
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
	
	
func _calc_intermediate_to_work():
	if mPlace_to_work != null:
		var pos_x_add = random.randi_range(-10, 10) 
		var pos_z_add = random.randi_range(-10, 10) 
		$Timer.start(5)
		target = mPlace_to_work.global_position
		target.x = target.x + pos_x_add
		target.z = target.z + pos_z_add
		target.y = 0
		$Area3D/GobotSkin.run()
	
func give_resources_to_town():
	print("trabajador ", self.name, " entregando recursos en el edificio")
	var resources = mResources
	if mResources != 0:
		get_node("/root/MainNode").add_resources(resources, mResource_type)
		mResources = 0
		_calc_intermediate_to_work()
			
	if mPlace_to_work == null:
		$Area3D/GobotSkin.idle()
	
	return resources
