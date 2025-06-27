extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("TriggerFireComponent"):
		var component = body.get_node("TriggerFireComponent") as TriggerFireComponent
		component.set_num_projectiles(5)
		queue_free()
