extends FSMState
class_name BadguyHurtState


@export var hit_stun_length: float


func enter() -> void:
	super.enter()
	await get_tree().create_timer(hit_stun_length).timeout
	transition("")
