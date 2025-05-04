extends Area2D

export (int) var speed = 600

onready var kill_timer = $Timer

var orginX
var orginY
var destinationX
var destinationY

var dir

func _ready() -> void:
	kill_timer.start()

func _physics_process(delta):
	position = position + (dir * delta * speed)


func _on_Bullet_body_entered(body):
	if body.name == "Player":
		GlobalVariables.player_died = true
		queue_free()
	elif(not "Enemy".is_subsequence_of(body.name)):
		
		queue_free()


func _on_Timer_timeout():
	queue_free()

func set_dir(vector):
	dir = vector
	$Sprite.flip_h = dir.x < 0
