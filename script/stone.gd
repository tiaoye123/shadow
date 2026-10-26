extends RigidBody2D

@export var light : Light2D

@export var radius : float = 2.5
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const light_classic : String = "fire"

enum State { NOT_FIRE , IS_FIRE }
var state : State = State.NOT_FIRE
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


#设置状态机
func set_state(value : State) -> void:
	if value == state:
		return
	state = value
	apply_state()


func apply_state() -> void:
	match state:
		State.NOT_FIRE:
			熄灭()
		State.IS_FIRE:
			点燃()


func 熄灭() -> void:
	pass


func 点燃() -> void:
	light.visible = true


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


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("can_light"):
		if state == State.IS_FIRE:
			body.set_state(body.State.IS_FIRE)
