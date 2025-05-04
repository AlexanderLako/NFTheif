extends Node2D

signal laserBeamCollision(body)
signal spikeCollision(body)


func _on_dashInfo_body_entered(body):
	$info/dash.visible = false
	$info/dash2.visible = false
	$info/dashReset.visible = true
	yield(get_tree().create_timer(4), "timeout")
	$info/dashReset.visible = false


func _on_dashInfo2_body_entered(body):
	$info/dash.visible = false
	$info/dash2.visible = false
	$info/dashReset2.visible = true
	yield(get_tree().create_timer(4), "timeout")
	$info/dashReset2.visible = false


func _on_LaserBeamColl_body_entered(body):
	emit_signal("laserBeamCollision", body) # Use this once enemies are refined 
	if body.name == "Player": 
		GlobalVariables.player_died = true

