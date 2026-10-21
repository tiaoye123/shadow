extends PointLight2D

@export var base_energy : float = 0.7
@export var base_position : Vector2 = Vector2.ZERO
@export var flicker_amount : float = 0.2 #噪点强度
@export var pos_amount : float = 3.0 #光斑晃动像素  
@export var follow_one : Node

#一快一慢两种噪声用来控制呼吸和频闪
var fast : FastNoiseLite
var slow : FastNoiseLite
var move : FastNoiseLite
var t : float = randf_range(0 , 10)


func _ready() -> void:
	#三种噪声的生成
	fast = FastNoiseLite.new()
	fast.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fast.frequency = 2.6
	
	slow = FastNoiseLite.new()
	slow.noise_type = FastNoiseLite.TYPE_SIMPLEX
	slow.frequency = 0.15
	
	move = FastNoiseLite.new()
	move.noise_type = FastNoiseLite.TYPE_SIMPLEX
	move.frequency = 0.4


func _process(delta: float) -> void:
	
	base_position = follow_one.position
	
	#噪声计时器计时
	t += delta
	
	#让快慢两噪声取噪声xy坐标图上的同一个点
	var f_x := fast.get_noise_1d(t)
	var s_x := slow.get_noise_1d(t)
	
	
	#利用取到的噪声修改energy
	energy = base_energy + (f_x * flicker_amount * 0.25 + s_x * flicker_amount)
	
	#利用另一条噪声修改position让火光微微晃动
	position.x = base_position.x + (move.get_noise_2d(t , 200) * pos_amount)
	position.y = base_position.y + (move.get_noise_2d(t , 100) * pos_amount)
