extends Area2D

export var damage = 30
export var velocity = 200

var direction = Vector2()

func _process(delta):
	position += direction * velocity * delta

func player_collide(_player : Player):	
	_player.hit((global_position - _player.global_position).normalized(), damage)

func _on_EnemyBullet_body_entered(body : Node):
	if body is Player:
		player_collide(body)
	queue_free()
