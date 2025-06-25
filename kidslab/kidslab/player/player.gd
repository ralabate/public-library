extends CharacterBody3D


@export var speed = 250
@export var sprint_speed = 500
@export var jump_velocity = 4.5
@export var mouse_turning_rate = 0.1
@export var keyboard_turning_rate = 2.0
@export var headbob_speed = 1.0
@export var headbob_amount = 0.05
@export var headbob_frequency = 10.0

@onready var health_component: HealthComponent = %HealthComponent
@onready var trigger_fire_component: TriggerFireComponent = %TriggerFireComponent
@onready var ability_inventory: AbilityInventory = %AbilityInventory
@onready var key_inventory_component: KeyInventoryComponent = %KeyInventoryComponent
@onready var uni_ammo_component: UniversalAmmoComponent = %UniversalAmmoComponent
@onready var audio_alert_region: Area3D = %AudioAlertRegion
@onready var camera: Camera3D = %Camera3D
@onready var hud = %HUD

var default_camera_pos: Vector3
var headbob_timer = 0.0


func _ready() -> void:
	add_to_group("player")

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	health_component.damage_received.connect(_on_damage_received)
	health_component.death.connect(_on_death)
	hud.set_health_bar_value(float(health_component.current_health) / health_component.MAX_HEALTH)

	key_inventory_component.key_acquired.connect(_on_key_acquired)

	trigger_fire_component.fired.connect(_on_weapon_fired)
	trigger_fire_component.can_fire = true

	if ability_inventory:
		var current_ability = ability_inventory.get_current_ability()
		ability_inventory.selected_ability.connect(_on_ability_selected)
		hud.set_ability_text(current_ability.resource_path)
	if uni_ammo_component:
		uni_ammo_component.amount_changed.connect(_on_ammo_amount_changed)
		hud.set_ammo(uni_ammo_component.amount)

	default_camera_pos = camera.position


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_pressed("turn_left"):
		rotate_y(deg_to_rad(keyboard_turning_rate))
	elif Input.is_action_pressed("turn_right"):
		rotate_y(-deg_to_rad(keyboard_turning_rate))

	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = direction.x * current_speed * delta
		velocity.z = direction.z * current_speed * delta
	else:
		velocity.x = 0
		velocity.z = 0

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if velocity.length() > 0.1:
		headbob_timer += delta * headbob_frequency
		camera.position = default_camera_pos + Vector3(
			0,
			sin(headbob_timer * headbob_speed) * headbob_amount,
			0
		)
	else:
		headbob_timer = 0.0
		camera.position = default_camera_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-deg_to_rad(event.screen_relative.x * mouse_turning_rate))
			trigger_fire_component.direction = global_transform.basis.z


func _on_damage_received(_amount: int) -> void:
	var health = float(health_component.current_health) / health_component.MAX_HEALTH
	hud.set_health_bar_value(health)
	hud.trigger_hurt_flash()


func _on_death() -> void:
	get_tree().reload_current_scene.call_deferred()


func _on_weapon_fired() -> void:
	for body in audio_alert_region.get_overlapping_bodies():
		if body.is_in_group("badguys"):
			body.hear_sound_at(global_position)

	trigger_fire_component.can_fire = false
	await hud.trigger_weapon_animation()
	trigger_fire_component.can_fire = true


func _on_ammo_requested() -> void:
	var amount_required = ability_inventory.get_ammo_required()
	if uni_ammo_component.has_ammo(amount_required):
		trigger_fire_component.spawn(ability_inventory.get_current_ability())
		uni_ammo_component.use_ammo(amount_required)


func _on_ammo_amount_changed(new_amount: int) -> void:
	hud.set_ammo(new_amount)


func _on_ability_selected(scene: PackedScene) -> void:
	trigger_fire_component.ability_template = scene
	hud.set_ability_text(trigger_fire_component.ability_template.resource_path)


func _on_key_acquired(key: DoorKey.Type) -> void:
	hud.set_key(key)
	hud.trigger_key_pickup_flash()
