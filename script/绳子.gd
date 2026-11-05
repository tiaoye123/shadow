extends Line2D

#可调整参数
@export var segment_count : int #绳子的分段数
@export var max_sgements : int = 56 #绳子最大节点数
@export var segment_length : float = 1.0 #每段的长度s
@export var interations : int = 1 #每帧的迭代数，越多，每帧计算出的绳子间距越接近设置值，就越硬
@export var gravity := Vector2(0 , 980) #重力
@export var damping : float = 0.98 #每帧速度衰减，或称阻尼
@export var anchor : Node2D #固定端，同时也是起点
@export var end_body : Node2D #终点端
@export var wall_mask := 1 #物理遮罩
@export var point_radius : float = 1 #每个点的半径
var probe := CircleShape2D.new() #形状
var q := PhysicsShapeQueryParameters2D.new() #查询用参数
var inited : bool = false
#点数据记录
var pos : PackedVector2Array
var prepos : PackedVector2Array
#点燃和燃烧相关变量
@export var burn_speed := 80
var burning : bool = false
var fuse : float
var fire_shape_circle := CircleShape2D.new()
var fire_shape := PhysicsShapeQueryParameters2D.new()
#尾端火焰
@export var fire : Node2D





#初始化,绳子从上至下垂下
func _ready() -> void:
	#设置点的物理碰撞检测
	probe.radius = point_radius
	q.shape = probe
	q.collision_mask = wall_mask
	q.collide_with_areas = false #关闭对area的查询
	#创建着火点检测
	fire_shape_circle.radius = 1.0
	fire_shape.shape = fire_shape_circle
	fire_shape.collision_mask = 2
	fire_shape.collide_with_areas = false


func init_rope() -> void:
	#获取固定点位置,和两点间连线
	var start := anchor.global_position
	var target := end_body.global_position
	#计算绳子应具有的结点数
	var span := start.distance_to(target)
	segment_count = clampi(int(ceil(span / segment_length)) , 2 , max_sgements)
	#反算一下，进行一个精度的提升
	segment_length = span / segment_count
	#创建分段数＋1个绳结,垂直防止，距离等于每段长度
	pos.clear()
	prepos.clear()
	for i in segment_count + 1:
		pos.append(start.lerp(target , float(i) / segment_count))
	#初始pre和初始位置相同
	points = pos.duplicate()
	prepos = pos.duplicate()
	fuse = segment_length


func _physics_process(delta: float) -> void:
	
	#隔一帧待所有节点加载好后初始化绳子
	if not inited:
		inited = true
		init_rope()
		return
	
	#燃烧状态时减少绳结最后一段的长度
	if burning:
		
		#尾焰
		if fire:
			fire.position = get_point_position(pos.size() - 1)
		
		fuse -= burn_speed * delta
		#逐级减少到结点，而后删除结点
		while fuse <= 0.0 and pos.size() >= 2:
			pos.remove_at(pos.size() - 1)
			prepos.remove_at(prepos.size() - 1)
			remove_point(points.size() - 1)
			fuse = segment_length
		#烧完了
		if pos.size() < 2:
			burning = false
			anchor.start_move()
			if fire:
				fire.visible = false
	else:
		#更新火焰检测位置
			fire_shape.transform =  Transform2D(0.0 , to_global(get_point_position(pos.size() - 1)))
			var hits := get_world_2d().direct_space_state.intersect_shape(fire_shape , 4)
			for h in hits:
				var body = h.collider
				if body != null and body.is_in_group("can_light") and body.state == body.State.IS_FIRE:
					burning = true
	
	
	var dmp := pow(damping , delta * 60)
	
	#利用prepos和pos计算每一帧的速度，这里跳过序号为0的点，因其为锚点
	for i in range(1 , pos.size()):
		#利用pos和pre算出这一帧该点速度并乘阻尼
		var v := ((pos[i] - prepos[i]) * dmp) 
		#覆盖
		prepos[i] = pos[i] 
		#利用重力加速度和先前算出速度计算出下一个点所在位置
		pos[i] += v + gravity * delta * delta 
	
	#利用q查询点是否碰到物理体
	var space := get_world_2d().direct_space_state
	for i in range(1 , pos.size()):
		q.transform = Transform2D(0.0 , prepos[i])
		q.motion = pos[i] - prepos[i]
		var safe := space.cast_motion(q)[0]
		pos[i] = prepos[i] + (pos[i] - prepos[i]) * safe
	
	#约束计算
	#约束次数。次数越多，点之间的距离越严格接近规定距离
	for i in interations:
		#0点始终位于固定点
		pos[0] = anchor.global_position
		#计算前后两点距离然后计算约束，并用约束更新点的位置。
		for j in pos.size() - 1 :
			var target_lenth := segment_length
			var a := pos[j]
			var b := pos[j + 1]
			var d = b - a
			#计算前后两点距离
			var dist := d.length()
			if dist <= 0.0001:
				#两点重合时，直接跳过
				continue
			#计算需要缩放的比例
			if burning  and  j == pos.size() - 2:
				target_lenth = fuse
			var diff := (dist - target_lenth) / dist
			if j == 0:
				#固定点不动，用比例计算更新每个点约束后的位置
				pos[1] = a + d * (1.0 - diff)
			else:
				a += d * diff * 0.5
				pos[j] = a
				pos[j + 1] -= d * diff * 0.5
	
	#again
	for i in range(1 , pos.size()):
		q.transform = Transform2D(0.0 , prepos[i])
		q.motion = pos[i] - prepos[i]
		var safe := space.cast_motion(q)[0]
		pos[i] = prepos[i] + (pos[i] - prepos[i]) * safe
	
	
	
	#将计算出的数据填入line2d的points
	for i in pos.size():
		set_point_position(i , to_local(pos[i]))
