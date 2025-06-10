class_name KeyInventoryComponent extends Node


signal key_acquired(key: DoorKey.Type) 


@export var key_chain: Array[DoorKey.Type]


func add_key(key: DoorKey.Type) -> void:
	key_chain.append(key)
	key_acquired.emit(key)


func has_key(key: DoorKey.Type) -> bool:
	return key_chain.has(key)
