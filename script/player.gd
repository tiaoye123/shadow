extends CharacterBody2D



@export var jump_speed : float
@export var speed_a : float
@export var max_speed : float = 70
var move_speed : float
var speed_tween : Tween
@export var G : float = 400
var player_face : float
@onready var speed: Label = $speed


func _physics_process(delta: float) -> void:
	
	#下落
	if not is_on_floor():
		velocity.y += G * delta
		velocity.y = clamp(velocity.y , 0 , 300)
	
	#移动速度计算
	player_face = Input.get_axis("left" , "right")
	if player_face != 0:
		if speed_tween and speed_tween.is_running():
			speed_tween.kill()
		move_speed += speed_a * player_face * delta
		move_speed = clamp(move_speed , -max_speed , max_speed)
	else:
		if not speed_tween or not speed_tween.is_running():
			speed_tween = create_tween()
			speed_tween.tween_property(self , "move_speed" , 0 , 0.05 )
	velocity.x = move_speed
	move_and_slide()
	debug_label()


#debug用label
func debug_label() -> void:
	speed.text =  "speed:" + str(move_speed)
