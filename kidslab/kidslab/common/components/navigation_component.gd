extends Node
class_name NavigationComponent


signal navigation_started
signal navigation_stopped
signal next_position(position: Vector3)

@export var navigation_agent: NavigationAgent3D

var target: Node3D


func _ready() -> void:
	assert(navigation_agent != null, "Add a NavigationAgent3D node!")


func start_navigation() -> void:
	Log.info("[%s] Starting navigation to target: [%s]" %
		[get_parent().name, target])
	
	navigation_agent.target_position = target.global_position
	navigation_started.emit(self.target)


func stop_navigation() -> void:
	Log.info("[%s] Stopped navigation" % get_parent().name)
	navigation_stopped.emit()


func distance_to_target() -> float:
	return navigation_agent.distance_to_target()


func update_target_position() -> void:
	if target == null or \
			(navigation_agent.is_navigation_finished() and \
			navigation_agent.is_target_reached()):
		return

	navigation_agent.target_position = target.global_position
	next_position.emit(navigation_agent.get_next_path_position())
