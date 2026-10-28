extends Node




func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
