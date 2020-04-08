extends KinematicBody2D

class_name Enemy

enum EnemyState {
	IDLE,
	PLAYER_SEEN,
	DEAD
}


onready var player : Player = $"../../Player"
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var hit_timer : Timer = $HitTimer
onready var dead_timer : Timer = $DeadTimer
onready var search_timer : Timer = $SearchTimer
onready var particles : Particles2D = $Particles2D
onready var hurtbox : CollisionShape2D = $Hurtbox

export var acceleration : float = 4
export var max_speed : float = 2
export var raycast_length : float = 500

var state = EnemyState.IDLE
var target = Vector2()

var velocity = Vector2()

func _ready():
	animated_sprite.animation = "move"
	animated_sprite.play()

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var to = global_position + (player.global_position - global_position).normalized()  * raycast_length
	var result : Dictionary = space_state.intersect_ray(global_position, to, [self], 5)
	if result.collider is Player && state != EnemyState.DEAD:
		state = EnemyState.PLAYER_SEEN
		target = result.position
	else: 
		if state == EnemyState.PLAYER_SEEN:
			if search_timer.is_stopped(): search_timer.start()
			
	if state == EnemyState.PLAYER_SEEN:
		if hit_timer.is_stopped():
			search_timer.stop()
			var direction = (target - self.global_position).normalized()
			var _velocity = velocity + direction * delta * acceleration
			if (_velocity.length() <= max_speed): velocity = _velocity
			else: velocity = _velocity.normalized() * max_speed
		var col : KinematicCollision2D = move_and_collide(velocity)
		if col:
			if col.collider.has_method("hit"):
				player_collide(col.collider)
			else:
				velocity = velocity.slide(col.normal)
	elif state == EnemyState.IDLE:
		# TODO add idle stuff
		pass
	elif state == EnemyState.DEAD:
		velocity = move_and_slide(velocity) * 0.9
		

func player_collide(_player : Player):
	var direction = (_player.global_position - self.global_position).normalized()
	_player.hit(direction)
	position -= direction
	velocity = velocity.bounce(-direction) 
	hit_timer.start()

func weapon_collide(_weapon: Boomerang):
	if !_weapon.hit_wall:
		state = EnemyState.DEAD
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

func _on_SearchTimer_timeout():
	state = EnemyState.IDLE
