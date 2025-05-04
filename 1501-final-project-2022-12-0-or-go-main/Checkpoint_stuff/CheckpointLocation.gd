extends Area2D

func _on_Checkpoint_body_entered(body):
	Checkpoints.last_position = global_position
	$flag.texture = load("sprites/checkpoint/checkpointReached.png")
