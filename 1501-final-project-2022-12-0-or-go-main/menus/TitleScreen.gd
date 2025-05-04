extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_startGame_pressed():
	$MenuMusic.stop()
	BgMusic.play_bg_music()
	get_tree().change_scene("res://Main.tscn")
	
	
func _on_Exit_pressed():
	get_tree().quit()
	

func _on_Cutscene_pressed():
	get_tree().change_scene("res://StoryElements/Intro.tscn")
