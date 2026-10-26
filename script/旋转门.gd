extends Node2D


@export var button : Node2D


func _ready() -> void:
	if button:
		button.open_door.connect(open)




func open() -> void:
	var roat_tween = get_tree().create_tween()
	roat_tween.tween_property(self , "rotation" , rotation + deg_to_rad(-90) , 0.7)
