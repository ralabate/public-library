extends StaticBody3D


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)

@export var explosion_template: PackedScene
@export var damage_amount: int

@onready var health_component: HealthComponent = %HealthComponent
@onready var explosion_area: Area3D = %ExplosionArea
@onready var animated_sprite: AnimatedSprite3D = %AnimatedSprite3D

var damage_list = []


func _ready() -> void:
	InstantiationStation.register_instantiator(self)

	explosion_area.body_entered.connect(_on_body_entered_explosion_area)
	explosion_area.body_exited.connect(_on_body_exited_explosion_area)
	
	health_component.death.connect(_on_death)

	animated_sprite.play("idle")


func _on_body_entered_explosion_area(node: Node3D) -> void:
	damage_list.append(node)


func _on_body_exited_explosion_area(node: Node3D) -> void:
	damage_list.erase(node)


func _on_death() -> void:
	for badguy in damage_list:
		if badguy.has_node("HealthComponent"):
			var health_component = badguy.get_node("HealthComponent") as HealthComponent
			health_component.damage(damage_amount)

	node_instantiated.emit(
		explosion_template.instantiate(),
		global_position,
		global_basis.z
	)

	queue_free()
