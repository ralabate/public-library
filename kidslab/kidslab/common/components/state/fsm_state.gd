extends Node
class_name FSMState


signal transitioned(from: FSMState, to: String)

var active = false


func enter() -> void:
	active = true


func exit() -> void:
	active = false


func update(_delta: float) -> void:
	pass


func transition(to: String) -> void:
	if active == true:
		transitioned.emit(self, to)
