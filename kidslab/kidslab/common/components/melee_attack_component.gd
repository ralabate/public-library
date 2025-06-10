class_name MeleeAttackComponent extends BaseAttackComponent


@export var attack_area: Area3D

var collision_shape: CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape = attack_area.get_node("CollisionShape3D") as CollisionShape3D
	assert(collision_shape != null, "Where's the collsion shape?")
	collision_shape.disabled = true


func attack() -> void:
	Log.info("[%s] attacking" % get_parent().name)
	collision_shape.set_deferred("disabled", false)
	await get_tree().create_timer(1.0).timeout
	collision_shape.set_deferred("disabled", true)
