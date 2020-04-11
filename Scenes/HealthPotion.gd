extends Area2D

export var healing_amount = 30

func player_collide(player: Player):
	player.heal(healing_amount)
	queue_free()

func _on_HealthPotion_body_entered(body: Node):
	var is_player : bool = body.get_collision_layer_bit(0)
	if is_player:
		player_collide(body)

