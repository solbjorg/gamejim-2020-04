extends Zombie

var bullet = preload("res://Scenes/EnemyBullet.tscn")

export var preferred_distance = 300

var clockwise = false

func _ready():
	if round(randf()) == 1.0:
		clockwise = true

func player_seen_behaviour(delta):
	var target_vec = (target - self.global_position)
	var direction = target_vec.normalized()
	if target_vec.length() < preferred_distance:
		if clockwise:
			direction = direction.rotated(PI/2)
		else:
			direction = direction.rotated(-PI/2)
	set_velocity(velocity + direction * delta * acceleration)

	move()

func searching_behaviour(delta):
	var target_vec = (target - self.global_position)
	var direction = target_vec.normalized()
	set_velocity(velocity + direction * delta * acceleration)
	
	move()

func _on_ShootTimer_timeout():
	shoot()

func shoot():
	if state == EnemyState.PLAYER_SEEN:
		var _bullet = bullet.instance()
		_bullet.global_position = global_position
		_bullet.direction = (target - self.global_position).normalized()
		get_parent().add_child(_bullet)
