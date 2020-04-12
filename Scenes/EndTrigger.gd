extends Area2D

export var end_screen : NodePath

var _end_screen : EndScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	_end_screen = get_node(end_screen)

func _on_EndTrigger_body_entered(body: Node):
	var is_player : bool = body.get_collision_layer_bit(0)
	if is_player:
		_end_screen.fade_out()

func player_collide(player : Player):
	player.win()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
