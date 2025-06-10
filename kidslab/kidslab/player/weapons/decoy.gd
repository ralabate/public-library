extends Area3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var badguy_list: Array[Badguy] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.speed_scale = 0.1


func finished() -> void:
	for badguy in badguy_list:
		if badguy and not badguy.is_queued_for_deletion():
			badguy.navigation_component.target = get_tree().get_first_node_in_group("player")
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Badguy:
		var badguy = body as Badguy
		badguy.navigation_component.target = self
		badguy_list.append(badguy)
