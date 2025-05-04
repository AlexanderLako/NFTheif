extends Node2D


func _enter_tree():
	if Checkpoints.last_position:
		$Player.global_position = Checkpoints.last_position
