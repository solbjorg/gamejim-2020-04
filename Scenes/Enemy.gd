extends KinematicBody2D

class_name Enemy

onready var player : Player = $"../Player"
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var hit_timer : Timer = $HitTimer

export var acceleration : float = 4
export var max_speed : float = 2

var velocity = Vector2()

func _ready():
	animated_sprite.animation = "move"
	animated_sprite.play()

func _process(delta):
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
			velocity.slide(col.normal)

func player_collide(_player : Player):
	var direction = (_player.global_position - self.global_position).normalized()
	_player.hit(direction)
	position -= direction
	velocity = velocity.bounce(-direction) 
	hit_timer.start()

func weapon_collide(_weapon: Boomerang):
	queue_free()

func _on_HitTimer_timeout():
	pass