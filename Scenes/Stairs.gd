extends Area2D

export var player : NodePath
export var destination : Vector2

var _player : Player

func _ready():
	_player = get_node(player)

func _on_Stairs_body_entered(body: Node):
	var is_player : bool = body.get_collision_layer_bit(0)
	if is_player:
		_player.position = destination
		# set player to be holding a weapon; this is very hacky, but the end is coming
		_player.throwing_state = 0
		_player.held_weapon.visible = true
