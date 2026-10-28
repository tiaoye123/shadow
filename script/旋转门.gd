extends Node2D

@export var angel : float = -90
@export var button : Node2D #和门联动按钮
@onready var 按钮相连激光: Line2D = $按钮相连激光


func _ready() -> void:
	#和门联动and连线
	if button:
		button.open_door.connect(open)	
		按钮相连激光.set_point_position(0 , global_position)
		按钮相连激光.set_point_position(1 , button.global_position)


#开门
func open() -> void:
	按钮相连激光.queue_free()
	var roat_tween = get_tree().create_tween()
	roat_tween.tween_property(self , "rotation" , rotation + deg_to_rad(angel) , 0.4)
