extends Node2D

func _on_left_and_right_body_entered(body):
	$ControlInfo/left_right.visible = true

func _on_left_and_right_body_exited(body):
	$ControlInfo/left_right.visible = false

func _on_jump_body_entered(body):
	$ControlInfo/jump.visible = true

func _on_jump_body_exited(body):
	$ControlInfo/jump.visible = false

func _on_slide_body_entered(body):
	$ControlInfo/slide.visible = true

func _on_slide_body_exited(body):
	$ControlInfo/slide.visible = false

func _on_JumpHold_body_entered(body):
	$ControlInfo/higherJump.visible = true

func _on_JumpHold_body_exited(body):
	$ControlInfo/higherJump.visible = false

func _on_WallJump_body_entered(body):
	$ControlInfo/WallJump.visible = true

func _on_WallJump_body_exited(body):
	$ControlInfo/WallJump.visible = false

func _on_dash_body_entered(body):
	$ControlInfo/dash.visible = true

func _on_dash_body_exited(body):
	$ControlInfo/dash.visible = false

func _on_dashCD_body_entered(body):
	$ControlInfo/dashCD.visible = true

func _on_dashCD_body_exited(body):
	$ControlInfo/dashCD.visible = false

