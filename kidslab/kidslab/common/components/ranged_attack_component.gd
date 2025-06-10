class_name RangedAttackComponent extends BaseAttackComponent


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)

@export var bullet_template: PackedScene


func _ready() -> void:
	InstantiationStation.register_instantiator(self)


func attack() -> void:
	var bullet = bullet_template.instantiate()
	var parent = get_parent()
	node_instantiated.emit(
		bullet,
		parent.transform.origin + parent.transform.basis.z + Vector3.UP * 0.5,
		-parent.transform.basis.z
	)
	await get_tree().create_timer(1.0).timeout
