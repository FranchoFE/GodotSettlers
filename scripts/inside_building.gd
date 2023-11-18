extends Node3D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("go_home"):
		SceneSwitcher.switch_scene("res://scenes/main_node.tscn")
