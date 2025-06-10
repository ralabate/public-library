@tool
extends Area3D


@export var node_list: Array[Node3D]:
	set(new_list):
		node_list = new_list
		build_meshes()

@export var ingame_debug_info = false
@export var default_line_color = Color.MAGENTA
@export var badguy_line_color = Color.RED
@export var door_line_color = Color.AQUAMARINE

var mesh_instances: Array[MeshInstance3D]
var _triggered = false
var line_material: StandardMaterial3D
var debug_label: Label3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if ingame_debug_info or Engine.is_editor_hint():
		build_meshes()
		line_material = StandardMaterial3D.new()
		line_material.vertex_color_use_as_albedo = true

		debug_label = Label3D.new()
		debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		debug_label.pixel_size = 0.001
		debug_label.fixed_size = true
		debug_label.no_depth_test = true
		add_child(debug_label)


func _process(_delta: float) -> void:
	if ingame_debug_info or Engine.is_editor_hint():
		draw_all_lines()

		# This can be null if in editor, but not as a subscene.
		if debug_label:
			debug_label.text = self.name


func draw_all_lines() -> void:
	for idx in node_list.size():
		var node = node_list[idx]
		if node:
			var from = Vector3.ZERO
			var to = node.global_position - self.global_position
			var immediate_mesh = mesh_instances[idx].mesh as ImmediateMesh
			var color = default_line_color

			if node is Badguy:
				color = badguy_line_color
			elif node is Door:
				color = door_line_color

			draw_line(immediate_mesh, from, to, color)


func build_meshes() -> void:
	for mesh_instance in mesh_instances:
		mesh_instance.queue_free()
	mesh_instances.clear()

	for node in node_list:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = ImmediateMesh.new()
		mesh_instances.append(mesh_instance)
		add_child(mesh_instance)


func draw_line(mesh: ImmediateMesh, from: Vector3, to: Vector3, color: Color) -> void:
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, line_material)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()


func _on_body_entered(body: Node3D) -> void:
	if not _triggered and body.is_in_group("player"):
		for node in node_list:
			if node == null or node.is_queued_for_deletion():
				continue
			if node.is_in_group("triggerable") and node.has_method("trigger"):
				node.trigger()
			_triggered = true
