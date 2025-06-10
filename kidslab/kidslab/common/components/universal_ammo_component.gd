class_name UniversalAmmoComponent extends Node


signal amount_changed(new_amount: int)

@export var amount: int


func has_ammo(amount: int) -> bool:
	return self.amount >= amount


func add_ammo(amount: int) -> void:
	self.amount += amount
	amount_changed.emit(self.amount)


func use_ammo(amount: int) -> void:
	self.amount -= amount
	amount_changed.emit(self.amount)
