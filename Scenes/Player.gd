extends KinematicBody2D

class_name Player

signal hit

onready var pickup_timer : Timer = $PickupTimer
onready var hit_timer : Timer = $HitTimer
onready var throw_timer : Timer = $ThrowTimer
onready var held_weapon : Sprite = $"weapon_cleaver"
onready var aim_line : Line2D = $Line2D
onready var throw_stream : AudioStreamPlayer2D = $ThrowStreamPlayer

var weapon = preload("res://Scenes/Boomerang.tscn")
var sounds : Array = [preload("res://Assets/sfx/swing1.wav"),preload("res://Assets/sfx/swing2.wav"),preload("res://Assets/sfx/swing3.wav")]

enum ThrowingState {
	HOLDING,
	CHARGING,
	THROWN,
	CAN_PICK_UP
}

export var speed : float = 400
export var min_force = 30
export var max_force = 150
export var max_health = 100

var throwing_state = ThrowingState.HOLDING
var is_hit = false
var health = max_health

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
		if !is_hit:
			$AnimatedSprite.animation = "move"
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		if !is_hit:
			$AnimatedSprite.animation = "idle"
	var col : KinematicCollision2D = move_and_collide(velocity * delta)
	if col:
		handle_collision(col)

func _process(_delta):
	if throwing_state == ThrowingState.CHARGING:
		var mouse_pos = get_local_mouse_position()
		aim_line.width = 2
		var strength = range_lerp(throw_timer.wait_time - throw_timer.time_left, 0, throw_timer.wait_time, 0, 1)
		aim_line.set_point_position(0, Vector2(0,0))
		aim_line.set_point_position(1, mouse_pos.normalized() * 30 * strength)
		#aim_line.default_color = Color(range_lerp(clamp(mouse_pos.length(), min_force, max_force), min_force, max_force, 0, 1), 0, 0)
		aim_line.default_color = Color(strength, 0, 0)
	else:
		aim_line.width = 0

# shooty!
func _input(event):
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed and throwing_state == ThrowingState.HOLDING:
				throw_timer.start()
				throwing_state = ThrowingState.CHARGING
			if event.button_index == BUTTON_LEFT and !event.pressed and throwing_state == ThrowingState.CHARGING:
				var wep = weapon.instance()
				wep.global_position = global_position
				get_parent().add_child(wep)
				var target = get_global_mouse_position()
				var force = range_lerp(throw_timer.wait_time - throw_timer.time_left, 0, throw_timer.wait_time, min_force, max_force)
				wep.throw(target, force)
				held_weapon.hide()
				throwing_state = ThrowingState.THROWN
				pickup_timer.start()
				throw_timer.stop()

				#finally, play a throwing sound effect!
				sounds.shuffle()
				throw_stream.stream = sounds.front()
				throw_stream.play()

func handle_collision(col: KinematicCollision2D):
	if col.collider.has_method("player_collide"):
		# a bit silly...but whatever
		col.collider.player_collide(self)

func _on_Timer_timeout():
	throwing_state = ThrowingState.CAN_PICK_UP

func hit(normal : Vector2, damage):
	if (!is_hit):
		$AnimatedSprite.animation = "hit"
		hit_timer.start()
		is_hit = true
		print (health, damage)
		health = max(health - damage, 0)
		emit_signal("hit")

func pickup(body : Boomerang):
	if throwing_state == ThrowingState.CAN_PICK_UP:
		held_weapon.show()
		throwing_state = ThrowingState.HOLDING
		body.queue_free()

func _on_HitTimer_timeout():
	is_hit = false
