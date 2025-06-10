extends Area3D


@export var attraction_threshold: float = 2.0
@export var speed: float = 10.0
@export var ammo_amount: int = 0

var player: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	assert(player != null, "Can't find the player!")

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if position.distance_to(player.position) < attraction_threshold:
		position = position.move_toward(player.position, speed * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("UniversalAmmoComponent"):
		var ammo_component = body.get_node("UniversalAmmoComponent") as UniversalAmmoComponent
		ammo_component.add_ammo(ammo_amount)

	queue_free()
