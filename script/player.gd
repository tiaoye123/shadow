extends CharacterBody2D



@export var jump_speed : float
@export var speed_a : float
@export var max_speed : float = 70
var move_speed : float
var speed_tween : Tween
@export var G : float = 400
var player_face : float
@onready var speed: Label = $speed

#拾取检测和手持物品
var item_can_pick_up : Array[Node2D]
var item_in_hand : RigidBody2D

#扔球相关
@onready var 扔球箭头_line: Line2D = $扔球箭头_line
@onready var 扔球箭头_头: Polygon2D = $扔球箭头_头
var 箭头goal_position : Vector2
@export var 箭头R : float = 18
@export var 扔球speed : float = 100



func _physics_process(delta: float) -> void:
	
	#鼠标和玩家位置的方向向量
	var dir := (get_global_mouse_position() - global_position).normalized()
	
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
	
	#拾取
	if not item_can_pick_up.is_empty() and Input.is_action_just_pressed("pick"):
		pick_up()
	
	#扔他妈的球
	if item_in_hand:
		item_in_hand.global_position = global_position
		if Input.is_action_just_pressed("扔"):
			扔球(dir)
		if Input.is_action_just_pressed("light"):
			$"../火光2".visible = true

	
	#扔球箭头相关
	箭头goal_position = global_position + dir * 箭头R
	#扔球箭头控制
	if item_in_hand:
		扔球箭头_头.visible = true
		扔球箭头_line.set_point_position(0 , global_position)
		扔球箭头_line.set_point_position(1 , 箭头goal_position)
		扔球箭头_头.global_position = 箭头goal_position
		扔球箭头_头.rotation = dir.angle()


func 扔球(dir : Vector2) -> void:
	var item = item_in_hand
	item_in_hand = null
	item.被扔(dir , 扔球speed , global_position)
	扔球箭头_line.set_point_position(0 , Vector2.ZERO)
	扔球箭头_line.set_point_position(1 , Vector2.ZERO)
	扔球箭头_头.visible = false


#debug用label
func debug_label() -> void:
	speed.text =  "speed:" + str(move_speed)


#拾取身边可拾取item
func pick_up() -> void:
	if not item_in_hand:
		item_in_hand = item_can_pick_up[0]
		item_in_hand.set_collision_layer_value(1 , false)
		item_in_hand.set_collision_mask_value(1 , false)
		item_in_hand.freeze = true
		item_in_hand.sleeping = true


#将进入拾取范围的可拾取物品依次加入数组
func _on_拾取范围_body_entered(body: Node2D) -> void:
	if body.is_in_group("can_pick_up"):
		item_can_pick_up.append(body)


#同上，但是删除
func _on_拾取范围_body_exited(body: Node2D) -> void:
	if body.is_in_group("can_pick_up"):
		item_can_pick_up.erase(body)
