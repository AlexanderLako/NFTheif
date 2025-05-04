extends Node2D

signal restart
signal mainmenu

func _ready():
	connect("restart", get_parent(), "restart")
	connect("mainmenu", get_parent(), "mainmenu")
	pass

func _physics_process(delta):
	$bg.color = lerp($bg.color, Color(0,0,0,0.4), 0.1)


func _on_restart_pressed():
	emit_signal("restart")

func _on_menu_pressed():
	BgMusic.stop_bg_music()
	get_tree().change_scene("res://menus/TitleScreen.tscn")

