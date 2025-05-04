extends Node2D


signal laserBeamCollision(body)
signal spikeCollision(body)



func _on_LaserBeamColl_body_entered(body):
	emit_signal("laserBeamCollision", body) # Use this once enemies are refined 
	if body.name == "Player": 
		GlobalVariables.player_died = true



func _on_Spike_colliders_body_entered(body):
	emit_signal("spikeCollision", body) # Use this once enemies are refined
	if body.name == "Player": 
		GlobalVariables.player_died = true
