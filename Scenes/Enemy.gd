extends KinematicBody2D

class_name Enemy

onready var player : Player = $"../Player"
onready var animated_sprite : AnimatedSprite = $AnimatedSprite

export var speed : float = 100

func _ready():
	animated_sprite.animation = "move"
	animated_sprite.play()

func _process(delta):
	var direction = (self.global_position - player.global_position).normalized()
	var col : KinematicCollision2D = move_and_collide(-direction * delta * speed)
	if (col && col.collider.has_method("hit")):
		player_collide(col.collider)

func player_collide(_player : Player):
	_player.hit()

func weapon_collide(_weapon: Boomerang):
	queue_free()