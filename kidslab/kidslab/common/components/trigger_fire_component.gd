class_name TriggerFireComponent extends Node


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)
signal ammo_requested
signal fired

@export var projectile_template: PackedScene
@export var vertical_offset: float
@export var autoaim_region: Area3D

var ability_template: PackedScene
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
			spawn(projectile_template)
		elif Input.is_action_pressed("trigger_ability"):
			ammo_requested.emit()


func use_current_ability() -> void:
	spawn(ability_template)


func spawn(template: PackedScene) -> void:
	var spawn_point = get_parent().position + (Vector3.UP * vertical_offset)
	var autoaim_direction = get_autoaim_direction(spawn_point)

	node_instantiated.emit(
		template.instantiate(),
		get_parent().position + (Vector3.UP * vertical_offset),
		autoaim_direction
	)

	fired.emit()
	#Log.info("Triggered projectile -- pos: [%s] - dir: [%s]" %
		#[spawn_point, autoaim_direction])


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
