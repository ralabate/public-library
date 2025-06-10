extends FSMState
class_name BadguyDeathState


func enter() -> void:
	super.enter()
	Log.info("[%s] is dead" % get_parent().name)
