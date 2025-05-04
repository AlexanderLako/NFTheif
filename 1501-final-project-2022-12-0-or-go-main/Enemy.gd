extends KinematicBody2D

signal died

var speed = 100

export var gravity = 3750
var on_ground = false
var paused = false
var obstructed = false

var velocity = Vector2.ZERO
var UP = Vector2(0,-1)
var state = "patrol"
var max_fall_velocity = 800
var player
var flipped

onready var sprite = $AnimatedSprite
onready var ground = $collision_detection/ground
onready var obs_left = $collision_detection/obs_left
onready var obs_right = $collision_detection/obs_right
onready var ledge_left = $collision_detection/ledge_left
onready var ledge_right = $collision_detection/ledge_right

func _ready():
	velocity.x = -speed
	sprite.flip_h = true
	change_state("patrol")
	
func _physics_process(delta):
	# pause handler
	if Input.is_action_just_pressed("ui_cancel"):
		paused = not paused
	if paused:
		sprite.stop()
		return
	else:
		sprite.play()
	
	#gravity handler
	if ground.is_colliding():
		velocity.y = 0
	else:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_velocity)
	
	if state == "patrol":
		if obs_left.is_colliding() or !ledge_left.is_colliding():
			sprite.flip_h = false
			velocity.x = speed
		elif obs_right.is_colliding() or !ledge_right.is_colliding():
			sprite.flip_h = true
			velocity.x = -speed
		
		$Weapon.rotation_degrees = 0
		$Weapon.position = Vector2(-32.480499, 5.69501) if sprite.flip_h else Vector2(32.480499, 5.69501)
		$Weapon.set_scale(Vector2(-0.4,0.4) if sprite.flip_h else Vector2(0.4,0.4))
		
	elif state == "shooting":
		var aim_vector = (player.global_position - global_position).normalized()
		var angle = (acos(aim_vector.x) * 180 / PI)
		flipped = global_position.x > player.global_position.x
		sprite.flip_h = flipped
		$arms.flip_h = flipped
		if aim_vector.y < 0: # flips angle for flipped sprite
			angle *= -1
		if flipped: # adjusts angle for flipped sprite
			$arms.rotation_degrees = angle + 180
			$Weapon.set_scale(Vector2(-0.4,0.4))
			$Weapon.rotation_degrees = angle + 180
			$Weapon.position = rotate_vector(aim_vector, -10) * 33
		else:
			$arms.rotation_degrees = angle
			$Weapon.set_scale(Vector2(0.4,0.4))
			$Weapon.rotation_degrees = angle
			$Weapon.position = rotate_vector(aim_vector, 10) * 33
		$Weapon.set_dir(aim_vector)
		#print($arms.rotation_degrees)
	elif state == "knocked up":
		pass
	velocity = move_and_slide(velocity, UP)
	
	
func change_state(s):
	state = s
	match(s):
		"patrol":
			$Weapon.disable()
			# TODO disable weapon
			sprite.animation = "EnemyHoldingGun"
			$arms.visible = false
			velocity.x = -speed if sprite.flip_h else speed
			
		"shooting":
			$Weapon.enable()
			# TODO enable weapon
			velocity.x = 0
			sprite.animation = "shooting"
			$arms.visible = true
			
		"dead":
			$Hitbox.set_deferred("disabled", true)
			emit_signal("died")
			state = "dead"
			sprite.animation = "shooting"
			velocity.x = 0
			$collision/body.set_deferred("disabled", true)
			$arms.visible = false
			$Weapon.queue_free()
			
			#TODO proper death animation
			sprite.rotation_degrees = 80
			sprite.flip_h = 0
			sprite.offset = Vector2(175,0)
			sprite.stop()
			
		"knocked up":
			sprite.stop() # TODO add knockup animation
			$arms.visible = false

func _on_collision_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if state == "dead":
		return
	
	if(GlobalVariables.is_dashing):
		change_state("dead")
		print("ENEMY DIED")
		GlobalVariables.can_dash = true
		
	elif(!GlobalVariables.is_dashing and body.name == "Player"):
		GlobalVariables.player_died = true
	

func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	player = body
	if body.name != "Player" or state == "dead":
		return
	change_state("shooting")


func _on_Area2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.name != "Player" or state == "dead" or global_position.distance_to(player.global_position) < 512.5:
		return
	change_state("patrol")

#rotates vector v by angle a using the R2 rotation matrix. takes angle in degrees
func rotate_vector(v, a):
	a *= PI/180
	var x = (v.x * cos(a)) - (v.y * sin(a))
	var y = (v.x * sin(a)) + (v.y * cos(a))
	return Vector2(x,y)
