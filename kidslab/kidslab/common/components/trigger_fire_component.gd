class_name TriggerFireComponent extends Node


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)
signal fired
signal num_projectiles_changed(amount: int)

@export var number_of_projectiles: int = 1
@export var projectile_template: PackedScene
@export var vertical_offset: float
@export var autoaim_region: Area3D

var direction: Vector3
var can_fire: bool
var autoaim_badguy_list: Array[Node3D]


func _ready() -> void:
	assert(autoaim_region, "Missing auto aim region (Area3D)!")
	assert(projectile_template, "Missing projectile scene!")

	InstantiationStation.register_instantiator(self)


func _physics_process(_delta: float) -> void:
	if can_fire:
		if Input.is_action_pressed("fire_projectile"):
			var spread_angle = 30.0
			var angle_step = spread_angle / (number_of_projectiles - 1) if number_of_projectiles > 1 else 0.0
			var start_angle = -spread_angle / 2.0

			for i in number_of_projectiles:
				var angle = 0.0 if number_of_projectiles == 1 else deg_to_rad(start_angle + i * angle_step)
				var parent_basis = get_parent().global_transform.basis
				var direction = parent_basis.z.rotated(Vector3.UP, angle)

				node_instantiated.emit(
					projectile_template.instantiate(),
					get_parent().position + (Vector3.UP * vertical_offset),
					direction.normalized()
				)

				fired.emit()


# TODO: Bring back autoaim.
func spawn(template: PackedScene) -> void:
	var spawn_point = get_parent().position + (Vector3.UP * vertical_offset)
	var autoaim_direction = get_autoaim_direction(spawn_point)
	node_instantiated.emit(template.instantiate(), spawn_point, autoaim_direction)
	fired.emit()


func set_num_projectiles(n: int) -> void:
	number_of_projectiles = n
	num_projectiles_changed.emit(n)


func get_autoaim_direction(projectile_origin: Vector3) -> Vector3:
	var shortest_distance = 1000.0
	var autoaim_direction = get_parent().basis.z

	for overlapping in autoaim_region.get_overlapping_bodies():
		# TODO: We shouldn't be checking specific groups here.
		if overlapping.is_in_group("badguys"):
			Log.info("Overlapping: [%s]" % overlapping.name)
			var distance = projectile_origin.distance_to(overlapping.global_position)
			if distance < shortest_distance:
				# HACK: WHY DOES THIS HAVE TO BE NEGATIVE???
				autoaim_direction = -projectile_origin.direction_to(overlapping.global_position)
				shortest_distance = distance
				Log.info("Closest direction: [%s]" % autoaim_direction)

	return autoaim_direction
