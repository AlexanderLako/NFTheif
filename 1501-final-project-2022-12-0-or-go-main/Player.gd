extends KinematicBody2D

export var gravity = 3750
export var accel = 5000
export var standing_friction = 3000
export var curr_friction = 3000
export var max_velocity = 600
export var max_fall_velocity = 1200
export var jump_strength = -1200
export var ceiling_bounce = 20
export var slide_friction = 500
export var dash_speed = 1000
export var dash_duration = 0.15
export var dash_cd = 2
export var wall_jump_height = -1200
export var wall_jump_push = 1500
export var wall_slide_speed_coefficient = 0.8
export var wall_slide_gravity = 1200

var on_ground = false
var on_wall = false
var jumping = false
var coyote_time = false
var coyote_time_length = 0.1
var can_slide = false
var sliding = false
var wallsliding = false
var just_died = true
var paused = false
var can_wj_right = true
var can_wj_left = true
var can_dash = true

var dash_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var UP = Vector2(0,-1)
var x_dir
var menu = deathScreen.instance()

onready var sprite = $AnimatedSprite
onready var ground = $collision_detection/ground
onready var left = $collision_detection/left
onready var right = $collision_detection/right
onready var head = $collision_detection/head

const deathScreen = preload("res://menus/deathScreen.tscn")
const fadein = preload("res://menus/fadein.tscn")

func _ready():
	add_child(fadein.instance())
	sprite.animation = "Standing"
	
func _physics_process(delta):
	pause_handler()
	if GlobalVariables.player_died:
		sprite.offset = Vector2(0,-64)
		velocity.x = 0
		
		sprite.play("knockout")
		if just_died:
			just_died = false
			$runningSound.set_volume_db(-100)
			yield(get_tree().create_timer(1.5), "timeout")
			menu = deathScreen.instance()
			add_child(menu)
		
	else:
		collision_handler()
		hitbox_handler()
		if not paused:
			dashing_handler()
			input_handler(delta)
	physics_handler(delta)
	
	

func collision_handler():
	# handles case if you just fell off a platform, lets you jump for another split second
	if(on_ground and not ground.is_colliding()):
		coyote_time = true
		on_ground = false
		yield(get_tree().create_timer(coyote_time_length), "timeout")
		coyote_time = false
	
	on_wall = left.is_colliding() or right.is_colliding()
	on_ground = ground.is_colliding()
	
	if on_ground:
		velocity.y = 0
		jumping = false
		can_wj_right = true
		can_wj_left = true
		can_dash = true
	
	if on_wall and !on_ground and velocity.y > 0:
		wallsliding =  Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")
	else:
		wallsliding = false

func input_handler(delta):
	sliding_handler()
	
	# calculates your net left/right input as your direction, accelerates you in that direction unless it's 0, then it decellerates you to a standstill
	x_dir = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if x_dir < 0 and not sliding:
		if velocity.x > -max_velocity:
			velocity.x -= accel * delta
				
	elif x_dir > 0 and not sliding: 
		if velocity.x < max_velocity:
			velocity.x += accel * delta
	else:
		if on_ground:
			velocity.x -= min(abs(velocity.x), curr_friction * delta) * sign(velocity.x)
	
	#snaps velocity to the max when it goes over
	velocity.x = min(max_velocity, abs(velocity.x)) * sign(velocity.x)
	
	# animation handler for ground
	if on_ground:
		if abs(velocity.x) < 1:
			sprite.offset = Vector2(0,-70)
			$runningSound.set_volume_db(-100)
			sprite.animation = "Standing"
		else:
			if sliding:
				$runningSound.set_volume_db(-100)
				sprite.animation = "Sliding"
				sprite.offset = Vector2(0,-70)
			else:
				$runningSound.set_volume_db(10)
				sprite.animation = "Running"
				sprite.offset = Vector2(0,-42)
			#sprite.flip_h = velocity.x < 0
			
	
	# handles airborne situations
	else:
		# modulates jump strength if you do not hold jump
		if velocity.y < 0 and not Input.is_action_pressed("jump") and not GlobalVariables.is_dashing and jumping:
			velocity.y = max(velocity.y, jump_strength/2)
		
		#airborne animation handler
		if velocity.y < 0:
			sprite.play("Jump(start)")
		else:
			$runningSound.set_volume_db(-100)
			sprite.animation = "Fall"
			
		#walljump handler
		if Input.is_action_just_pressed("jump"):
			if right.is_colliding() and can_wj_right:
				$wallJumpSound.play() #wall jump sound effect
				can_wj_left = true
				can_wj_right = false
				sprite.frame = 0
				sprite.play("Jump(start)")
				velocity = Vector2(-wall_jump_push, wall_jump_height)
				#sprite.flip_h = true
			elif left.is_colliding() and can_wj_left:
				$wallJumpSound.play() #wall jump sound effect
				can_wj_left = false
				can_wj_right = true
				sprite.frame = 0
				sprite.play("Jump(start)")
				velocity = Vector2(wall_jump_push, wall_jump_height)
				#sprite.flip_h = false
	
	#jump handler. should factor in coyote time
	if (!jumping and (on_ground or coyote_time)) and Input.is_action_just_pressed("jump"):
		$runningSound.set_volume_db(-100)
		$jumpSound.play() #jump sound effect
		velocity.y = jump_strength
		jumping = true

func physics_handler(delta):
	if is_on_ceiling():
		velocity.y = ceiling_bounce
	
	if not wallsliding:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_velocity)
	
	else:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, max_fall_velocity * wall_slide_speed_coefficient)
	
	#movement handler
	if not paused:
		if GlobalVariables.is_dashing:
			$runningSound.set_volume_db(-100)
			sprite.animation = "Dash"
			velocity = move_and_slide(dash_dir*dash_speed, UP)
		else:
			velocity = move_and_slide(velocity, UP)
			
		if velocity.x < 0:
			sprite.flip_h = true
		if velocity.x > 0:
			sprite.flip_h = false

func hitbox_handler():
	#toggles betweeen standing and sliding hitbox
	if sliding and $SlidingHB.disabled:
		$StandingHB.disabled = true
		$SlidingHB.disabled = false
	elif (not sliding) and $StandingHB.disabled:
		$StandingHB.disabled = false
		$SlidingHB.disabled = true

func sliding_handler():
	# checks if you are moving at max speed to allow you to slide
	if abs(velocity.x) >= max_velocity and on_ground:
		if not sliding:
			can_slide = true
	else:
		can_slide = false
	
	#only slides while you hold the button
	if can_slide and Input.is_action_pressed("slide"):
		$slideSound.play() #slide sound effect
		sliding = true
		can_slide = false
	if (sliding and not Input.is_action_pressed("slide") and not head.is_colliding()) or velocity.x == 0 or not on_ground:
		sliding = false
		
	#reduces friction to allow for slide, sets sliding animation
	if sliding and on_ground:
		curr_friction = slide_friction if not head.is_colliding() else 0
	else:
		curr_friction = standing_friction

func dashing_handler():
	if Input.is_action_just_pressed("Dash") and GlobalVariables.can_dash and not sliding:
		$DashHB.disabled = false
		$StandingHB.disabled = true
		GlobalVariables.is_dashing = true
		GlobalVariables.can_dash = false
		dash_dir = get_local_mouse_position().normalized()
		var angle = (acos(dash_dir.x) * 180 / PI) # angle from positive x axis
		var angle_offset = -35 # apparent angle of the dash sprite
		
		if dash_dir.y < 0: # flips angle for flipped sprite
			angle *= -1
			
		#makes sprite point at cursor, shifts dash hitbox position to match offset angle
		if dash_dir.x > 0:
			sprite.rotation_degrees = angle + angle_offset 
			$DashHB.position = rotate_vector(dash_dir, -1.3*angle_offset) * 30 # -1.3 and 30 are bullshit trial and error values that made it line up
		else:
			sprite.rotation_degrees = angle + 180 - angle_offset
			$DashHB.position = rotate_vector(dash_dir, +1.3*angle_offset) * 30
			
		
		$DashHB.rotation_degrees = angle + 90 
				
		sprite.offset = Vector2(-13,-42) # i honestly have no idea how this lines it up anymore, the values dont make sense after i shifted everything around but ok
		yield(get_tree().create_timer(dash_duration), "timeout")
		
		$DashHB.disabled = true
		$StandingHB.disabled = false
		
		sprite.rotation_degrees = 0
		sprite.offset = Vector2.ZERO
		
		GlobalVariables.is_dashing = false
		yield(get_tree().create_timer(dash_cd), "timeout")
		GlobalVariables.can_dash = true

func restart():
	get_tree().reload_current_scene()
	GlobalVariables.player_died = false
	GlobalVariables.elapsedTime = 0
	GlobalVariables.can_dash = true
	queue_free()

func mainmenu(): #TODO add main menu functionality
	print("Main Menu")
	pass

func pause_handler():
	if Input.is_action_just_pressed("ui_cancel"):
		paused = not paused
		print(paused)
		if paused:
			$runningSound.set_volume_db(-100)
			sprite.stop()
			menu = deathScreen.instance()
			add_child(menu)
		else:
			sprite.play()
			menu.queue_free()
			menu = null
		
		
#rotates vector v by angle a using the R2 rotation matrix. takes angle in degrees
func rotate_vector(v, a):
	a *= PI/180
	var x = (v.x * cos(a)) - (v.y * sin(a))
	var y = (v.x * sin(a)) + (v.y * cos(a))
	return Vector2(x,y)

