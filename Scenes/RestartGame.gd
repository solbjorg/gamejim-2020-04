extends Panel

onready var tween : Tween = $Tween

export var pos_x_goal = 800

var pos_x : float = -100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	rect_position.x = pos_x

func _on_Player_die():
	tween.interpolate_property(self, "pos_x", pos_x, pos_x_goal, 1, tween.TRANS_LINEAR, tween.EASE_IN)
	if not tween.is_active():
		tween.start()
	visible = true

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Quit_pressed():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
