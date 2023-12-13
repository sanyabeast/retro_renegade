extends Control

class_name DebugLabels

var _containers: Dictionary = {}
var _targets: Dictionary = {}
var _labels: Dictionary = {}
var _lines: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	dev.set_debug_labels(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_labels()
	pass

func set_label(target: Node3D, lines: tools.DataContainer):
	var label_id: String = target.name
	var container: VBoxContainer
	if label_id in _containers:
		container = _containers[label_id]
		pass
	else:
		container = VBoxContainer.new()
		container.anchors_preset
		_containers[label_id] = container
		_labels[label_id] = {}
		_targets[label_id] = target
		add_child(container)
		
	for i in lines.data.keys().size():
		var line_id = lines.data.keys()[i]
		var text = lines.data[line_id]
		var label: Label
		
		if line_id in _labels[label_id]:
			label = _labels[label_id][line_id]
		else:
			label = Label.new()
			label.add_theme_font_size_override("font_size", 12)
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			_labels[label_id][line_id] = label
			container.add_child(label)
		
		label.text = text
		
	_lines[label_id] = lines	
		
	_update_labels()

func _update_labels():
	var camera: Camera3D = tools.get_active_camera()
	if camera != null:
		for label_id in _containers.keys():
			var target: Node3D = _targets[label_id]
			var container: VBoxContainer = _containers[label_id]
			var distance: float = target.global_position.distance_to(camera.global_position)
			
			if distance > app.config.dev_labels_view_distance or camera.is_position_behind(target.global_transform.origin):
				container.visible = false
			else:
				container.visible = true
				var screen_pos: Vector2 = camera.unproject_position(target.global_transform.origin)
				container.position = screen_pos
			pass
			
			for line_id in _labels[label_id].keys():
				var label: Label = _labels[label_id][line_id]
				label.text = _lines[label_id].data[line_id]
		pass
		

func remove_label(target: Node3D):
	var label_id: String = target.name
	
	if label_id in _containers:
		remove_child(_containers[label_id])
		_containers[label_id].queue_free()
		for key in _labels[label_id]:
			var label = _labels[label_id][key]
			label.queue_free()
		
	_containers.erase(label_id)
	_targets.erase(label_id)
	
	
	_labels.erase(label_id)
	pass
