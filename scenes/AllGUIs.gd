extends Control


func _ready():
	update_resources(get_parent().stones, get_parent().wood)
	selected_worker(null)


func _process(delta):
	$RightGUI/Label.text = "FPS: " + str(roundi(Engine.get_frames_per_second()))
	

func selected_worker(worker):
	if worker != null:
		$DownGUI/ActionLabel.set_text("Seleccionado trabajador " + str(worker.name))
	else:
		$DownGUI/ActionLabel.set_text("Ningún trabajador seleccionado")


func update_resources(stones, wood):
	$GUI/StoneLabel.text = str(stones)
	$GUI/WoodLabel.text = str(wood)
	
	
func show_message(message):
	$CentralGUI/Label.text = message
	$CentralGUI/Label.visible = true
	$CentralGUI/DisappearTimer.start(3)


func _on_disappear_timer_timeout():
	$CentralGUI/Label.visible = false
