extends Node2D


#export (PackedScene) var Bullet

var current_ammo = 0
var max_ammo = 5
var create_bullet = 0
var is_reloading = 0 
var enabled = false
var dir

onready var cooldown = $Cooldown


func _ready() -> void:
	$WeaponFlash.hide()
	current_ammo = max_ammo
	
func _physics_process(delta):
	if enabled:
		shoot()


func shoot():
	if current_ammo != 0 and cooldown.is_stopped() and is_reloading == 0:
		var level = get_parent().get_parent()
		var enemy = get_parent()
		var bullet_instance = preload("res://Bullet.tscn").instance()
		bullet_instance.position = enemy.position + position
		bullet_instance.scale = Vector2(0.4,0.4)
		bullet_instance.set_dir(dir)
		bullet_instance.rotation_degrees = rotation_degrees
		
		level.add_child(bullet_instance)
		cooldown.start()
		$AnimationPlayer.play("muzzle_flash")
		$Gunshot.play()
		current_ammo -= 1
	
	if current_ammo == 0:
		is_reloading = 1
		reload()
		
func reload():
	$reloadTimer.start()
	$Reload.play("ReloadAnimation")
	current_ammo = max_ammo


func _on_reloadTimer_timeout():
	is_reloading = 0

func enable():
	enabled = true

func disable():
	enabled = false

func set_dir(vector):
	dir = vector
