extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func switch_scene(new_scene):
	call_deferred("_deferred_switch_scene", new_scene)
	
func _deferred_switch_scene(new_scene):
	current_scene.free()
	var s = load(new_scene)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
