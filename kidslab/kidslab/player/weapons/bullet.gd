extends Area3D


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)

@export var speed = 2.5
@export var damage = 1
@export var apply_gravity = false
@export var spawn_on_collision: PackedScene

var velocity: Vector3
var dying = false

func _ready() -> void:
	InstantiationStation.register_instantiator(self)
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)

	if has_node("AnimatedSprite3D"):
		var animated_sprite = get_node("AnimatedSprite3D")
		animated_sprite.play("default")


func _physics_process(delta: float) -> void:
	if dying:
		return

	velocity = global_transform.basis.z * speed
	
	if apply_gravity:
		velocity += gravity_direction * gravity
	
	global_translate(velocity * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("HealthComponent"):
		var health_component = body.get_node("HealthComponent") as HealthComponent
		health_component.damage(damage)

	if spawn_on_collision:
		node_instantiated.emit(
			spawn_on_collision.instantiate(),
			global_position + global_basis.y,
			global_basis.z
		)

	dying = true

	# TODO: This should be moved out to a shortlived vfx node.
	if has_node("AnimatedSprite3D"):
		var animated_sprite = get_node("AnimatedSprite3D")
		animated_sprite.play("death")
		await animated_sprite.animation_finished

	queue_free()
