extends Area3D


@export var damage_amount = 5
@onready var collision_shape := %CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	assert(player != null, "Where's the player?!")

	var overlapping_bodies = get_overlapping_bodies()
	overlapping_bodies.sort_custom(
		func(a, b): return a.distance_to(player.global_position)
	)

	# TODO: Scale the damage on subsequent hits.
	for body in overlapping_bodies:
		if body.has_node("HealthComponent"):
			var health_component = body.get_node("HealthComponent") as HealthComponent
			health_component.damage(5)
			await get_tree().create_timer(1.0).timeout

	#queue_free()
