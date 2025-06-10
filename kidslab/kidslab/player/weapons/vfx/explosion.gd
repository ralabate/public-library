extends Node3D


@onready var animated_sprite: AnimatedSprite3D = %AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.pixel_size = randf_range(0.01, 0.025)
	animated_sprite.play("default")
	await animated_sprite.animation_finished
	queue_free()
