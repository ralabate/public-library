extends Control
class_name HUD


@onready var weapon_sprite: AnimatedSprite2D = %WeaponSprite
@onready var hurt_flash: ColorRect = %HurtFlashRect
@onready var health_bar: ProgressBar = %HealthBar
@onready var key_inventory_container: HBoxContainer = %KeyInventoryContainer
@onready var ability_label: Label = %AbilityLabel
@onready var ammo_label: Label = %AmmoLabel


func _ready() -> void:
	hurt_flash.visible = false
	weapon_sprite.play("idle")
	for key_icon in key_inventory_container.get_children():
		key_icon.visible = false


func set_health_bar_value(amount: float) -> void:
	health_bar.value = amount


func trigger_hurt_flash() -> void:
	hurt_flash.visible = true
	await get_tree().create_timer(0.1).timeout
	hurt_flash.visible = false


func trigger_weapon_animation() -> void:
	weapon_sprite.play("fire")
	await weapon_sprite.animation_finished
	weapon_sprite.play("idle")


func set_ability_text(ability: String) -> void:
	ability_label.text = ability


func set_ammo(amount: int) -> void:
	ammo_label.text = str(amount)


func set_key(key: DoorKey.Type) -> void:
	var node_name: String
	match key:
		DoorKey.Type.RED:
			node_name = "RedKeyIcon"
		DoorKey.Type.YELLOW:
			node_name = "YellowKeyIcon"
		DoorKey.Type.BLUE:
			node_name = "BlueKeyIcon"
			
	var key_icon = key_inventory_container.get_node(node_name)
	if key_icon:
		key_icon.visible = true
