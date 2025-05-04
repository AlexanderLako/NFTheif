extends Node

var music = load("res://soundEffects/music/Ghostrifter-Official-Deflector.mp3")

func play_bg_music():
	$bgMusic.stream = music
	$bgMusic.play()

func stop_bg_music():
	$bgMusic.stop()
