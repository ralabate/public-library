extends Control
class_name HUD


@export var hurt_flash_color: Color = Color.RED
@export var key_pickup_flash_color: Color = Color.WHITE

@onready var weapon_sprite: AnimatedSprite2D = %WeaponSprite
@onready var special_weapon_sprite: AnimatedSprite2D = %SpecialWeaponSprite
@onready var flash: ColorRect = %FlashRect
@onready var hurt_rect: ColorRect = %HurtRect
@onready var health_bar: ProgressBar = %HealthBar
@onready var key_inventory_container: HBoxContainer = %KeyInventoryContainer
@onready var ability_label: Label = %AbilityLabel
@onready var ammo_label: Label = %AmmoLabel

var current_weapon_sprite: AnimatedSprite2D

func _ready() -> void:
	flash.visible = false
	set_special_weapon(false)

	for key_icon in key_inventory_container.get_children():
		key_icon.visible = false


func set_health_bar_value(amount: float) -> void:
	health_bar.value = amount


func set_hurt_rect_value(amount: float) -> void:
	hurt_rect.color = Color(hurt_rect.color, lerpf(0.0, 0.75, amount))


func trigger_hurt_flash() -> void:
	_show_flash(0.1, hurt_flash_color)


func trigger_key_pickup_flash() -> void:
	_show_flash(0.1, key_pickup_flash_color)


func _show_flash(time: float, color: Color) -> void:
	flash.color = color
	flash.visible = true
	await get_tree().create_timer(time).timeout
	flash.visible = false


func set_special_weapon(active: bool) -> void:
	weapon_sprite.visible = false
	special_weapon_sprite.visible = false

	current_weapon_sprite = special_weapon_sprite if active else weapon_sprite
	current_weapon_sprite.visible = true
	current_weapon_sprite.play("idle")


func trigger_weapon_animation() -> void:
	current_weapon_sprite.play("fire")
	await current_weapon_sprite.animation_finished
	current_weapon_sprite.play("idle")


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
