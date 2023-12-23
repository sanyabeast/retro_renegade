extends Node

class_name DevScript

class RetroGizmo:
	var render_object: Node3D
	var id: String
	var owner: Node3D
	var material: Material
	
	func _init(_owner: Node3D, _render_object: Node3D, _id: String, _mat: Material):
		render_object = _render_object
		id = _id
		owner = _owner
		material = _mat
		

const TAG: String = "DevScript: "

var _debug_print: DebugPrint
var _debug_labels: DebugLabels

var _sphere_gizmo_template: SphereMesh = preload("res://scripts/_dev/_gizmo/_sphere_gizmo.tres")
var _cube_gizmo_template: BoxMesh = preload("res://scripts/_dev/_gizmo/_cube_gizmo.tres")
var _ray_gizmo_template: PrismMesh = preload("res://scripts/_dev/_gizmo/_ray_gizmo.tres")

var _active_gizmos = {}
var _queued_print_screen = {}

func logd(tag: String, data):
	print("%s: %s" % [tag, data])
	
func logr(tag: String, data):
	print("%s: [ERROR!] %s" % [tag, data])

func print_screen(topic: String, message: String):
	if _debug_print != null:
		_debug_print.print(topic, message)
	else:
		_queued_print_screen[topic] = message

func set_label(target: Node3D, lines: tools.DataContainer):
	if _debug_labels != null:
		_debug_labels.set_label(target, lines)
	
func remove_label(target: Node3D):
	_debug_labels.remove_label(target)
		
func set_debug_print(node: DebugPrint):
	_debug_print = node
	for key in _queued_print_screen.keys():
		print_screen(key, _queued_print_screen[key])
	_queued_print_screen = {}
	
func set_debug_labels(node: DebugLabels):
	_debug_labels = node

func _ready():
	logd(TAG, "ready")
	
	pass # Replace with function body.

func draw_gizmo_sphere(owner: Node3D, id: String, center: Vector3, radius: float, color: Color = Color.REBECCA_PURPLE):
	id = id + str(owner.get_instance_id())
	
	var gizmo: RetroGizmo = _active_gizmos.get(id)
	if gizmo == null:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = _sphere_gizmo_template.duplicate(true)
		var mat: ShaderMaterial = mesh_instance.mesh.surface_get_material(0)
		mat.set_shader_parameter("wire_color", color)
		
		gizmo = RetroGizmo.new(
			owner,
			mesh_instance,
			id,
			mat
		)
		
		_active_gizmos[id] = gizmo
		tools.get_scene().add_child(gizmo.render_object)
	
	gizmo.render_object.global_position = center
	gizmo.render_object.scale = Vector3.ONE * radius
	gizmo.material.set_shader_parameter("wire_color", color)
	gizmo.render_object.visible = true
	
	pass

func draw_gizmo_cube(owner: Node3D, id: String, origin: Vector3, size: Vector3, direction: Vector3, color: Color = Color.REBECCA_PURPLE):
	id = id + str(owner.get_instance_id())
	
	var gizmo: RetroGizmo = _active_gizmos.get(id)
	if gizmo == null:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = _cube_gizmo_template.duplicate(true)
		var mat: ShaderMaterial = mesh_instance.mesh.surface_get_material(0)
		mat.set_shader_parameter("wire_color", color)
		
		gizmo = RetroGizmo.new(
			owner,
			mesh_instance,
			id,
			mat
		)
		
		_active_gizmos[id] = gizmo
		tools.get_scene().add_child(gizmo.render_object)
	
	gizmo.render_object.scale = size
	gizmo.render_object.global_position = origin
	gizmo.render_object.look_at_from_position(origin, origin + direction)
	gizmo.material.set_shader_parameter("wire_color", color)
	gizmo.render_object.visible = true
	
	
	pass

func draw_gizmo_ray(owner: Node3D, id: String, origin: Vector3, destination: Vector3, color: Color = Color.REBECCA_PURPLE):
	id = id + str(owner.get_instance_id())
	
	var gizmo: RetroGizmo = _active_gizmos.get(id)
	if gizmo == null:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = _ray_gizmo_template.duplicate(true)
		var mat: ShaderMaterial = mesh_instance.mesh.surface_get_material(0)
		mat.set_shader_parameter("albedo", color)
		
		
		gizmo = RetroGizmo.new(
			owner,
			mesh_instance,
			id,
			mat
		)
		
		_active_gizmos[id] = gizmo
		tools.get_scene().add_child(gizmo.render_object)
	
	
	# FIX IT
	if abs(destination.y - origin.y) < 0.1:
		destination.y += 0.1
	
	var length: float = origin.distance_to(destination)
	var direction = origin.direction_to(destination)
		
	gizmo.render_object.global_position = origin + (direction / 2)
	gizmo.render_object.global_basis.y = direction
	gizmo.render_object.visible = true
	
	gizmo.material.set_shader_parameter("albedo", color)
	
	pass

func hide_gizmo(owner: Node3D, id: String):
	id = id + str(owner.get_instance_id())
	var gizmo: RetroGizmo = _active_gizmos.get(id)
	if gizmo != null:
		gizmo.render_object.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("dev1"):
		RenderingServer.set_debug_generate_wireframes(true)
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 27
		dev.print_screen("devviewportmode", "Viewport Mode: %s" % vp.debug_draw)
	
	if tools.timer_gate.check('dev-check-orphaned-gizmo', 5):
		for id in _active_gizmos.keys():
			if _active_gizmos[id].owner == null:
				if _active_gizmos[id].render_object != null:
					_active_gizmos[id].render_object.queue_free()
				_active_gizmos.erase(id)
	
	pass
