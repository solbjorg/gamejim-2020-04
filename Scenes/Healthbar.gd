extends MarginContainer

onready var texture_progress : TextureProgress = $Bar/TextureRect/TextureProgress
onready var tween : Tween = $Bar/TextureRect/TextureProgress/Tween
onready var player : Player = $"../../Player"

var animated_health : float 
var target_health : float 

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_max_health = player.max_health
	texture_progress.max_value = player_max_health
	texture_progress.value = player.health
	animated_health = player.health
	target_health = player.health

func _process(_delta):
	texture_progress.value = animated_health

func _on_Player_hit():
	update_health(player.health)
	
func update_health(health : float):
	if tween.is_active():
		tween.stop_all()
		texture_progress.value = target_health

	target_health = health
	tween.interpolate_property(self, "animated_health", animated_health, health, 0.3, tween.TRANS_LINEAR, tween.EASE_IN)
	if not tween.is_active():
		tween.start()
