class_name DoorKey extends Area3D


enum Type {
	RED,
	YELLOW,
	BLUE,
	NONE = -1,
}

@export var type: Type = Type.NONE

@onready var animated_sprite: AnimatedSprite3D = %AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(type != Type.NONE, "Type not assigned!")
	body_entered.connect(_on_body_entered)
	
	match type:
		DoorKey.Type.RED:
			animated_sprite.play("red")
		DoorKey.Type.YELLOW:
			animated_sprite.play("yellow")
		DoorKey.Type.BLUE:
			animated_sprite.play("blue")


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("KeyInventoryComponent"):
		var key_inventory = body.get_node("KeyInventoryComponent") as KeyInventoryComponent
		key_inventory.add_key(type)
		Log.info("Picked up key: [%s]" % type)
		queue_free()
