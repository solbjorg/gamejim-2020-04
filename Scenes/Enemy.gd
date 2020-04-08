extends KinematicBody2D

class_name Enemy

onready var player : Player = $"../../Player"
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var hit_timer : Timer = $HitTimer
onready var dead_timer : Timer = $DeadTimer
onready var particles : Particles2D = $Particles2D
onready var hurtbox : CollisionShape2D = $Hurtbox

export var acceleration : float = 4
export var max_speed : float = 2

var dead = false

var velocity = Vector2()

func _ready():
	animated_sprite.animation = "move"
	animated_sprite.play()

func _physics_process(delta):
	if !dead:
		if hit_timer.is_stopped():
			var direction = (player.global_position - self.global_position).normalized()
			var _velocity = velocity + direction * delta * acceleration
			if (_velocity.length() <= max_speed): velocity = _velocity
			else: velocity = _velocity.normalized() * max_speed
		var col : KinematicCollision2D = move_and_collide(velocity)
		if col:
			if col.collider.has_method("hit"):
				player_collide(col.collider)
			else:
				velocity = velocity.slide(col.normal)
	else:
		velocity = move_and_slide(velocity) * 0.9
		

func player_collide(_player : Player):
	var direction = (_player.global_position - self.global_position).normalized()
	_player.hit(direction)
	position -= direction
	velocity = velocity.bounce(-direction) 
	hit_timer.start()

func weapon_collide(_weapon: Boomerang):
	if !_weapon.hit_wall:
		dead = true
		velocity *= -1
		particles.emitting = true
		velocity = velocity.bounce((_weapon.global_position - self.global_position).normalized()) * _weapon.velocity * 40
		# only collide with walls
		collision_layer = 0
		collision_mask = 4
		dead_timer.start()

func _on_HitTimer_timeout():
	pass

func _on_DeadTimer_timeout():
	queue_free()
