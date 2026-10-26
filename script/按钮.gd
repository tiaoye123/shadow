extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D

signal open_door()


func _ready() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("can_pick_up"):
		open_door.emit()
		queue_free()
