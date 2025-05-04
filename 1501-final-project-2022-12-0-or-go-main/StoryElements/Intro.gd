extends Node2D


func _ready():
	yield(get_tree().create_timer(6), "timeout")
	$comic.animation = "pg 2"
	yield(get_tree().create_timer(5), "timeout")
	$comic.animation = "pg 3"
	yield(get_tree().create_timer(5), "timeout")
	$comic.animation = "pg 4"
	yield(get_tree().create_timer(7), "timeout")
	get_tree().change_scene("res://menus/TitleScreen.tscn")

