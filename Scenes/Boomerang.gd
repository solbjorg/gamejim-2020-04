extends RigidBody2D
class_name Boomerang

export var speed : float = 400

var target : Vector2
var prev_force : Vector2 = Vector2(0,0)
onready var player = $"../Player"

func _ready():
	pass 

func _integrate_forces(_state):
	var direction : Vector2 = (global_position - player.global_position).normalized()
	var force = 1000 * -direction
	add_central_force(-prev_force)
	add_central_force(force)
	prev_force = force
	#add_force(Vector2(0,0), Vector2(-direction.x, 0))

func throw(_target : Vector2, force : float):
	#mode = MODE_RIGID
	target = _target
	var weapon_mouse_vec = (target - global_position)
	var direction = weapon_mouse_vec.normalized()
	# var angle = PI / 4
	# 45deg on the line between mouse and player - might not use...
	# var impulse = Vector2(cos(angle * direction.x) - sin(angle * direction.y), sin(angle * direction.x) + cos(angle * direction.y)).normalized()
	apply_central_impulse(force * 3.5 * direction)
	angular_velocity = 10

#destroy boomerang
func pickup():
	self.queue_free()


#func reset():
	## completely reset the weapon
	#thrown = false
	#target = Vector2(0,0)
	#prev_force = Vector2(0,0)
	#linear_velocity *= 0
	#angular_velocity *= 0
	#applied_force = Vector2(0,0)
	#position = Vector2(0,0)

