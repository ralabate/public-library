extends Node


func register_instantiator(instantiator: Node) -> void:
	if instantiator.has_signal("node_instantiated"):
		instantiator.node_instantiated.connect(_on_node_instantiated)


func _on_node_instantiated(node: Node3D, location: Vector3, direction: Vector3):
	get_tree().root.add_child(node)
	node.position = location
	node.look_at(node.global_transform.origin + direction)
	
	#Log.info("Node instantiated -- position [%s] - direction [%s]" % [node.position, node.rotation])
