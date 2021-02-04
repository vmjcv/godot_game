extends ReferenceRect

const BUTTON_SCENE = preload('res://scene/techtree-item.tscn')

export(float, 32, 256) var radius = 96
export(Vector2) var box_min_size = Vector2(128, 32)
export(float, 0, 360) var starting_angle = 0
export(float, 0, 360) var total_angle = 360

onready var tween_node = get_node('tween')
onready var tree_size = get_size()
onready var center_point = tree_size / 2.0

var current_data = []
var current_nb_root = 0
var current_rotation_angle = 90

signal button_pressed(node_data)

func _ready():
	tween_node.start()

func clear():
	# Reset current tween
	tween_node.remove_all()
	tween_node.stop_all()

	for node_data in current_data:
		if node_data.has('node'):
			node_data.node.queue_free()

	current_data = []
	update()

func initialize(data, nb_root):
	clear()

	current_data = data
	current_nb_root = nb_root
	current_rotation_angle = total_angle / nb_root
	var current_angle_index = 0

	for node_data in current_data:
		var button_scene_instance = BUTTON_SCENE.instance()

		add_child(button_scene_instance)

		button_scene_instance.initialize(node_data)
		node_data.node = button_scene_instance
		node_data.node.connect('pressed', self, 'button_pressed', [node_data], CONNECT_DEFERRED)

		if node_data.root:
			var string_size = button_scene_instance.get_size()
			var box_size = Vector2(max(string_size.x, box_min_size.x), max(string_size.y, box_min_size.y))
			var node_center_point = center_point - box_size / 2.0

			node_data.angle = current_rotation_angle * current_angle_index + starting_angle - current_rotation_angle / 2.0
			print(node_data.angle)
			node_center_point = node_center_point + Vector2(0.0, radius).rotated(deg2rad(node_data.angle))
			node_data.node.rect_position = node_center_point
			node_data.deep = 1
			node_data.pos = node_center_point
			current_angle_index += 1
		else:
			var node_parent = node_data.parent

			if not node_parent.has('child'):
				node_parent.child = []

			node_data.deep = node_parent.deep + 1
			node_parent.child.append(node_data)

	for node_data in current_data:
		if not node_data.root:
			var parent_node = node_data.parent
			var nb_child = parent_node.child.size()
			var parent_pos = parent_node.pos
			var parent_angle = parent_node.angle
			var node_center_point = parent_pos
			var angle_index = parent_node.child.find(node_data)
			var base_angle = current_rotation_angle / max(node_data.deep - 1.0, 1.0)
			var side_angle = (180 - base_angle) / 2.0
			var base_length = nb_child * node_data.node.get_size().x * 1.05
			var current_radius = max(radius, base_length * sin(deg2rad(side_angle)) / sin(deg2rad(base_angle)))
			print("---------")
			var angle_decal = angle_index * base_angle / nb_child
			printt(angle_decal,angle_index)
			if nb_child > 1:
				angle_decal -= current_rotation_angle / (node_data.deep * 2.0)
			printt(parent_angle,base_angle,angle_decal)
			node_data.angle = parent_angle + angle_decal
			node_center_point = node_center_point + Vector2(0.0, current_radius).rotated(deg2rad(node_data.angle))
			node_data.pos = node_center_point

			tween_node.interpolate_property(node_data.node, 'rect_position', parent_pos, node_center_point, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	tween_node.interpolate_method(self, '_update_draw', 0.0, 1.0, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween_node.start()

func button_pressed(node_data):
	emit_signal('button_pressed', node_data)

func button_updated(node_data):
	node_data.node.initialize(node_data)

	if node_data.has('child'):
		for child in node_data.child:
			child.node.initialize(child)

	update()

func _update_draw(object = null):
	update()

func _draw():
	for node_data in current_data:
		if not node_data.root:
			var node_pos = node_data.node.rect_position + node_data.node.get_size() / 2.0
			var parent_node = node_data.parent
			var parent_pos = parent_node.node.rect_position + parent_node.node.get_size() / 2.0
			var color = parent_node.line.color.enabled

			if parent_node.disabled:
				color = parent_node.line.color.disabled

			draw_line(node_pos, parent_pos, color, node_data.line.width)
