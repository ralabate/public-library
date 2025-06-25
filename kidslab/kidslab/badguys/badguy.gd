extends CharacterBody3D
class_name Badguy


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)
signal death(location: Vector3)

@export var movement_speed: float = 50.0
@export var wake_delay_min: float = 0.5
@export var wake_delay_max: float = 1.0
@export var idle_delay_min: float = 0.5
@export var idle_delay_max: float = 1.0
@export var attack_damage: int = 1
@export var use_detection_area: bool = false
@export var spawn_on_death: PackedScene

@onready var detection_area: Area3D = %DetectionArea
@onready var player_damage_area: Area3D = %PlayerDamageArea
@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_component: NavigationComponent = %NavigationComponent
@onready var fsm_component: FSMComponent = %FSMComponent
@onready var animated_sprite: AnimatedSprite3D = %AnimatedSprite3D

var is_moving = false
var movement_direction: Vector3


func _ready():
	InstantiationStation.register_instantiator(self)

	add_to_group("badguys")
	add_to_group("triggerable")

	player_damage_area.body_entered.connect(_on_body_entered_attack_area)
	
	if use_detection_area:
		detection_area.body_entered.connect(_on_body_entered_detection_area)
		#detection_area.body_exited.connect(_on_body_exited_detection_area)

	health_component.damage_received.connect(_on_damage_received)
	health_component.death.connect(_on_death)

	navigation_component.navigation_started.connect(_on_navigation_started)
	navigation_component.navigation_stopped.connect(_on_navigation_stopped)
	navigation_component.next_position.connect(_on_navigation_position)

	fsm_component.transitioned.connect(_on_fsm_transitioned_state)
	fsm_component.transition("BadguyIdleState")


func _physics_process(delta):
	if is_moving:
		velocity = movement_direction * movement_speed * delta
		var nav_target = navigation_component.target
		look_at(transform.origin - nav_target.transform.basis.z)
	
	move_and_slide()


func trigger() -> void:
	await get_tree().create_timer(
		randf_range(wake_delay_min, wake_delay_max)
	).timeout
	var player = get_tree().get_first_node_in_group("player")
	_enter_chase_state(player)


func hear_sound_at(location: Vector3) -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, location)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty() and result.collider.is_in_group("player"):
		trigger()


func _enter_chase_state(target: Node3D) -> void:
	if navigation_component.target == null:
		navigation_component.target = target
		fsm_component.transition("BadguyChaseState")


func _on_body_entered_attack_area(body: Node3D) -> void:
	if body.has_node("HealthComponent"):
		var health_component = body.get_node("HealthComponent") as HealthComponent
		health_component.damage(attack_damage)


func _on_body_entered_detection_area(body: Node3D) -> void:
	if body.is_in_group("player"):
		_enter_chase_state(body)


func _on_body_exited_detection_area(body: Node3D) -> void:
	if body.is_in_group("player"):
		fsm_component.transition("BadguyIdleState")


func _on_damage_received(_amount: int) -> void:
	if health_component.current_health > 0:
		fsm_component.transition("BadguyHurtState")


func _on_death() -> void:
	fsm_component.transition("BadguyDeathState")


func _on_navigation_started(_target: Node3D) -> void:
	is_moving = true


func _on_navigation_stopped() -> void:
	is_moving = false
	velocity = Vector3.ZERO


func _on_navigation_position(location: Vector3) -> void:
	movement_direction = global_position.direction_to(location)


func _on_fsm_transitioned_state(to: String) -> void:
	match to:
		"BadguyIdleState":
			await get_tree().create_timer(
				randf_range(idle_delay_min, idle_delay_max)
			).timeout
			animated_sprite.play("idle")
		"BadguyChaseState":
			animated_sprite.play("chase")
		"BadguyAttackState":
			animated_sprite.play("attack")
		"BadguyHurtState":
			animated_sprite.play("hurt")
		"BadguyDeathState":
			animated_sprite.play("death")
			await animated_sprite.animation_finished
			node_instantiated.emit(
				spawn_on_death.instantiate(),
				global_position,
				global_basis.z
			)
			death.emit(position)
			queue_free()
