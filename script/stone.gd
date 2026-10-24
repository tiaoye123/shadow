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


#球被扔出
func 被扔(dir : Vector2 , speed : float , start_position : Vector2) -> void:
	var rid := get_rid()
	PhysicsServer2D.body_set_state(rid, PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D(global_rotation, start_position))
	PhysicsServer2D.body_set_state(rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, dir * speed)
	freeze = false
	sleeping = false
	await get_tree().create_timer(0.2).timeout
	set_collision_layer_value(1 , true)
	set_collision_mask_value(1 , true)
