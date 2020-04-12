extends Zombie

export(String, FILE) var to_spawn
export var min_spawn_time = 1.3
export var max_spawn_time = 1.7

onready var spawn_timer : Timer = $SpawnTimer

var _to_spawn : Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.wait_time = max_spawn_time
	_to_spawn = load(to_spawn)


func _on_SpawnTimer_timeout():
	spawn_timer.wait_time = range_lerp(randf(), 0, 1, min_spawn_time, max_spawn_time)
	if state == EnemyState.PLAYER_SEEN:
		spawn()
		animated_sprite.animation = "spawn"
		animated_sprite.play()

func spawn():
	var enemy = _to_spawn.instance()
	enemy.position = global_position + Vector2(randf(), randf()).normalized() * 32
	get_parent().add_child(enemy)

func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "spawn":
		animated_sprite.animation = "idle"
		animated_sprite.play()
