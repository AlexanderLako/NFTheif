extends Node2D

signal spikeCollision(body)


func _on_spike_colliders_body_entered(body):
	emit_signal("spikeCollision", body) # Use this once enemies are refined
	if body.name == "Player": 
		GlobalVariables.player_died = true
