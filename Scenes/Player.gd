extends KinematicBody2D

class_name Player

signal hit
signal heal
signal die
signal pickup

onready var pickup_timer : Timer = $PickupTimer
onready var hit_timer : Timer = $HitTimer
onready var throw_timer : Timer = $ThrowTimer
onready var held_weapon : Sprite = $"weapon_cleaver"
onready var aim_line : Line2D = $Line2D
onready var throw_stream : AudioStreamPlayer2D = $ThrowStreamPlayer
onready var hurt_stream : AudioStreamPlayer2D = $HurtStreamPlayer
onready var drink_stream : AudioStreamPlayer2D = $DrinkStreamPlayer
onready var blood_particles : Particles2D = $Bleeding
onready var camera : Camera2D = $Camera2D

var weapon = preload("res://Scenes/Boomerang.tscn")
var sounds : Array = [preload("res://Assets/sfx/swing1.wav"),preload("res://Assets/sfx/swing2.wav"),preload("res://Assets/sfx/swing3.wav")]

enum PlayerState {
	ALIVE,
	HIT,
	DEAD
}

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
export var shake_amount = 2

var throwing_state = ThrowingState.CAN_PICK_UP
var health = max_health
var state = PlayerState.ALIVE

func _ready():
	$AnimatedSprite.play()
	held_weapon.visible = false

func _physics_process(delta):
	if state != PlayerState.DEAD:
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
			velocity = velocity.normalized() * speed
			if state != PlayerState.HIT:
				$AnimatedSprite.animation = "move"
			$AnimatedSprite.flip_h = velocity.x < 0
		else:
			if state != PlayerState.HIT:
				$AnimatedSprite.animation = "idle"
		var col : KinematicCollision2D = move_and_collide(velocity * delta)
		if col:
			var is_wall : bool = col.collider.get_collision_layer_bit(2)
			if is_wall:
				velocity = velocity.slide(col.normal).normalized() * speed
				col = move_and_collide(velocity * delta)
			handle_collision(col)

func _process(_delta):
	if state != PlayerState.DEAD:
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

	if !hit_timer.is_stopped():
		camera.set_offset(Vector2( \
			(randf() * 2 - 1) * shake_amount, \
			(randf() * 2 - 1) * shake_amount \
		))

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
	if col && col.collider.has_method("player_collide"):
		# a bit silly...but whatever
		col.collider.player_collide(self)

func _on_Timer_timeout():
	throwing_state = ThrowingState.CAN_PICK_UP

func hit(normal : Vector2, damage):
	if state == PlayerState.ALIVE:
		state = PlayerState.HIT
		$AnimatedSprite.animation = "hit"
		hit_timer.start()
		health = max(health - damage, 0)
		if (health == 0): die()
		hurt_stream.play()
		emit_signal("hit")

func heal(_health):
	if state == PlayerState.ALIVE:
		health = min(_health + health, max_health)
		# TODO this is kinda spaghetti... the potion should probably determine what sound to play, or just play it. but whatevs.
		drink_stream.play()
		emit_signal("heal")


func die():
	emit_signal("die")
	state = PlayerState.DEAD
	blood_particles.emitting = true

func pickup(body : Boomerang):
	if throwing_state == ThrowingState.CAN_PICK_UP:
		held_weapon.show()
		throwing_state = ThrowingState.HOLDING
		body.queue_free()
		emit_signal("pickup")

func _on_HitTimer_timeout():
	if state == PlayerState.HIT:
		state = PlayerState.ALIVE
