extends CanvasLayer


#onready var timer := $dash_timers/dash_cd_timer
var time_elapsed = 0
var time2 = 0
var dash_time = -1
var gameTime
var dash_cd
var dash_duration

func _process(delta: float) -> void:
	dash_cd = get_parent().dash_cd
	dash_duration = get_parent().dash_duration
	time_elapsed += delta
	time2 += delta
	if(GlobalVariables.can_dash == false):
		if dash_time == dash_cd:
			yield(get_tree().create_timer(dash_duration), "timeout")
		dash_time = max(0, dash_cd - time_elapsed)
		$HBoxContainer/Score.set_text(str(stepify(dash_time, 0.01)))
	else:
		time_elapsed = 0
		$HBoxContainer/Score.set_text("Ready!")
		
	gameTime = "%.2f" % [time2]
	$HBoxContainer2/time.set_text(gameTime)
		


