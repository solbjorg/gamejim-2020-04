extends Area2D
class_name Boomerang

onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var particles : Particles2D = $Particles2D

export var max_speed : float = 50
export var acceleration : float = 5

var target : Vector2
var hit_wall : bool = false
var velocity : Vector2
var player 
var force : float

func _ready():
	player = get_parent().get_node("Player")
	pass 

func _process(delta):
	if !hit_wall:
		var direction : Vector2 = (player.global_position - global_position).normalized()
		var _velocity = velocity + acceleration * direction * delta
		if _velocity.length() > max_speed: velocity = _velocity.normalized() * max_speed
		else: velocity = _velocity
		position += velocity
		rotation += delta * force / 5

	
	#add_force(Vector2(0,0), Vector2(-direction.x, 0))

func throw(_target : Vector2, _force : float):
	#mode = MODE_RIGID
	target = _target
	force = _force
	var direction = (target - global_position).normalized()
	# var angle = PI / 4
	# 45deg on the line between mouse and player - might not use...
	# var impulse = Vector2(cos(angle * direction.x) - sin(angle * direction.y), sin(angle * direction.x) + cos(angle * direction.y)).normalized()
	#apply_central_impulse(force * 3.5 * direction)
	velocity = force * 0.05 * direction

func player_collide(_player ):
	_player.pickup(self)

func enemy_collide(_enemy ):
	_enemy.weapon_collide(self)

func wall_collide():
	hit_wall = true	
	particles.process_material.direction = Vector3(-velocity.x, -velocity.y, 0).normalized()
	particles.emitting = true
	audio.play()

#func reset():
	## completely reset the weapon
	#thrown = false
	#target = Vector2(0,0)
	#prev_force = Vector2(0,0)
	#linear_velocity *= 0
	#angular_velocity *= 0
	#applied_force = Vector2(0,0)
	#position = Vector2(0,0)

func _on_Boomerang_body_entered(body: Node):
	var is_player : bool = body.get_collision_layer_bit(0)
	var is_enemy : bool = body.get_collision_layer_bit(1)
	var is_wall : bool = body.get_collision_layer_bit(2)
	if is_player:
		player_collide(body)
	elif is_enemy:
		enemy_collide(body)
	elif is_wall:
		wall_collide()
