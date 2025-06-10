extends Node
class_name FSMComponent


signal transitioned(to: String)

var current_state: FSMState
var states: Dictionary[String, FSMState]
var stack: Array[FSMState]


func _ready() -> void:
	for child in get_children():
		var state = child as FSMState
		if state != null:
			state.transitioned.connect(_on_state_transitioned)
			states[state.name.to_lower()] = state


func _physics_process(delta: float) -> void:
	current_state.update(delta)


func transition(to: String, push: bool = true) -> void:
	var new_state = states[to.to_lower()]
	if new_state != null:
		if current_state:
			if push:
				stack.append(current_state)
			current_state.exit()
		new_state.enter()
		current_state = new_state
		transitioned.emit(to)
		#Log.info("[%s] Entering: [%s]" % [get_parent().name, to])


func return_to_previous_state() -> void:
	if not stack.is_empty():
		var previous_state = stack.pop_back()
		Log.info("[%s] Returning to: [%s]" %
			[get_parent().name, previous_state.name])
		transition(previous_state.name, false)
	else:
		Log.error("Previous state does not exist!")


func _on_state_transitioned(from: FSMState, to: String) -> void:
	Log.info("From: [%s] --> To: [%s]" % [from.name, to])
	if not to.is_empty():
		transition(to)
	else:
		return_to_previous_state()
