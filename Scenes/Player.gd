extends KinematicBody2D

class_name Player

onready var pickup_timer = $PickupTimer
onready var hit_timer = $HitTimer
var weapon = preload("res://Scenes/Boomerang.tscn")
onready var held_weapon : Sprite = $"weapon_cleaver"
onready var aim_line : Line2D = $Line2D

var thrown = false
var can_pick_up_weapon = true
var is_hit = false

export var speed : float = 400
export var min_force = 100
export var max_force = 300

func _ready():
	$AnimatedSprite.play()

func _physics_process(delta):
	# movement
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1;
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1;
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1;
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1;
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		$AnimatedSprite.animation = "move"
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		$AnimatedSprite.animation = "idle"
	var col : KinematicCollision2D = move_and_collide(velocity * delta)
	if col:
		handle_collision(col)

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	aim_line.set_point_position(0, Vector2(0,0))
	aim_line.set_point_position(1, mouse_pos)
	aim_line.default_color = Color(range_lerp(clamp(mouse_pos.length(), min_force, max_force), min_force, max_force, 0, 1), 0, 0)

# shooty!
func _input(event):
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed and !thrown:
				var wep = weapon.instance()
				wep.global_position = global_position
				get_parent().add_child(wep)
				var target = get_global_mouse_position()
				var weapon_mouse_vec = (target - global_position)
				var force = clamp(weapon_mouse_vec.length(), min_force, max_force)
				wep.throw(target, force)
				held_weapon.hide()
				can_pick_up_weapon = false
				thrown = true
				pickup_timer.start()

func handle_collision(col: KinematicCollision2D):
	if col.collider.has_method("player_collide"):
		# a bit silly...but whatever
		col.collider.player_collide(self)

func _on_Timer_timeout():
	can_pick_up_weapon = true

func hit():
	if (!is_hit):
		$AnimatedSprite.animation = "hit"
		hit_timer.start()
		is_hit = true

func pickup(body : Boomerang):
	if can_pick_up_weapon:
		held_weapon.show()
		thrown = false
		body.queue_free()

func _on_HitTimer_timeout():
	is_hit = false
