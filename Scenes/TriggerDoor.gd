extends StaticBody2D

export var enemies : Array
export var camera : NodePath
export var shake_amount : float = 2.0

onready var open_timer = $OpenTimer
onready var open_sound = $OpenSound

var _enemies : Array
var _camera : Node
var enemy_death_count : int
var opening = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_camera = get_node(camera)
	print(camera, _camera)
	for e in enemies:
		var enemy : Zombie = get_node(e)
		_enemies.append(enemy)
		enemy.connect("die", self, "_on_Enemy_die")

func _process(_delta):
	if !open_timer.is_stopped():
		_camera.set_offset(Vector2( \
			(randf() * 2 - 1) * shake_amount, \
			(randf() * 2 - 1) * shake_amount \
		))
		if !open_sound.playing:
			open_sound.play()

func _on_Enemy_die(enemy : Zombie):
	if enemy in _enemies:
		enemy_death_count += 1
		if enemy_death_count >= _enemies.size():
			open_door()

func open_door():
	open_timer.start()

func _on_OpenTimer_timeout():
	queue_free()
