extends MarginContainer

onready var texture_progress : TextureProgress = $Bar/TextureRect/TextureProgress
onready var player : Player = $"../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_max_health = player.max_health
	texture_progress.max_value = player_max_health
	texture_progress.value = texture_progress.max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_hit():
	texture_progress.value = player.health
	