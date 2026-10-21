extends RigidBody2D

@export var radius : float = 2.5
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const light_classic : String = "fire"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw() -> void:
	draw_circle(Vector2.ZERO , radius , Color.GRAY)
