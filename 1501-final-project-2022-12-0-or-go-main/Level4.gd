extends Node2D

signal spikeCollision(body)
signal laserBeamCollision(body)

func _on_spike_colliders_body_entered(body):
	emit_signal("spikeCollision", body) # Use this once enemies are refined
	if body.name == "Player": 
		GlobalVariables.player_died = true


func _on_laser_beam_colliders_body_entered(body):
	emit_signal("laserBeamCollision", body) # Use this once enemies are refined 
	if body.name == "Player": 
		GlobalVariables.player_died = true
