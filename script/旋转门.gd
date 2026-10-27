extends Node2D

@export var angel : float = -90
@export var button : Node2D


func _ready() -> void:
	if button:
		button.open_door.connect(open)




func open() -> void:
	var roat_tween = get_tree().create_tween()
	roat_tween.tween_property(self , "rotation" , rotation + deg_to_rad(angel) , 0.4)
