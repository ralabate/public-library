class_name AbilityInventory extends Node


signal selected_ability(scene: PackedScene)


@export var abilities: Array[PackedScene]
@export var ammo_required: Array[int]

var _current_ability = 0


func _ready() -> void:
	assert(abilities.size() == ammo_required.size(), "Hack hack hack")
	InstantiationStation.register_instantiator(self)


func _process(_delta: float) -> void:
	var previous = _current_ability
	if Input.is_action_just_pressed("ability_1"):
		_current_ability = 0
	elif Input.is_action_just_pressed("ability_2"):
		_current_ability = 1
	elif Input.is_action_just_pressed("ability_3"):
		_current_ability = 2

	if _current_ability != previous:
		var selected = abilities[_current_ability]
		Log.info("New ability selected: [%s]" % selected.resource_path)
		selected_ability.emit(selected)


func get_current_ability() -> PackedScene:
	return abilities[_current_ability]


func get_ammo_required() -> int:
	return ammo_required[_current_ability]
