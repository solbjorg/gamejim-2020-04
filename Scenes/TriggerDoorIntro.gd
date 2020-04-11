extends TriggerDoor

export var player : NodePath

var _player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	shake_amount = 4
	_player = get_node(player)
	_player.connect("pickup", self, "_on_Player_pickup")

func _on_Player_pickup():
	if open_timer.is_stopped():
		open_door()
