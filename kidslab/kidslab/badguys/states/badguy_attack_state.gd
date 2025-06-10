extends FSMState
class_name BadguyAttackState


@export var attack_component: BaseAttackComponent


func _ready() -> void:
	assert(attack_component != null, "Add an attack component!")


func enter() -> void:
	super.enter()
	await attack_component.attack()
	transition("")
