extends AnimatableBody2D


@export var 移动动画 : AnimationPlayer
@export var 引信 : Node2D


func _ready() -> void:
	if 引信:
		引信.open_door.connect(start_move)


func start_move() -> void:
	if 移动动画:
		移动动画.play("移动")
