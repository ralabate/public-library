extends Node
class_name AutofireComponent


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)

@export var TIME_BETWEEN_SHOTS = 1.0

@export var bullet_template: PackedScene
var firing_rate_timer: Timer


func _ready() -> void:
	InstantiationStation.register_instantiator(self)

	firing_rate_timer = Timer.new()
	firing_rate_timer.wait_time = TIME_BETWEEN_SHOTS
	firing_rate_timer.autostart = true
	firing_rate_timer.timeout.connect(_on_firing_rate_timer_timeout)
	add_child(firing_rate_timer)


func _on_firing_rate_timer_timeout() -> void:
	var bullet = bullet_template.instantiate()
	var parent = get_parent()
	node_instantiated.emit(
		bullet,
		parent.transform.origin - parent.transform.basis.z,
		parent.rotation
	)
