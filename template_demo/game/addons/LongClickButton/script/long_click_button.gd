extends Button
class_name LongClickButton
const CANVA_MATERIAL_SCENE = preload("res://addons/LongClickButton/shader/long_click_button.tres")
const  pow_16_value = pow(2, 16)
export (float, 0.1, 50.0, 0.1) var click_duration_threshold = 25.0
onready var canva_material = CANVA_MATERIAL_SCENE.duplicate(true)

signal long_pressed
signal long_released

var _signal_sent = false
var _current_duration = 0
var _button_pressed = false



func _init():
	set_process(true)

func _ready():
	connect("mouse_entered", self, "set_process_input", [true])
	connect("mouse_exited", self, "set_process_input", [false])
	set_material(canva_material)

func _process(delta):
	if is_disabled():
		return
	if _button_pressed:
		_current_duration = lerp(_current_duration, click_duration_threshold, 0.1)
		_update_button()
	elif _current_duration > 0.001:
		if _signal_sent:
			emit_signal("long_released")
		_signal_sent = false
		_current_duration = lerp(_current_duration, 0.0, 0.05)
		_update_button()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_button_pressed = event.pressed
		accept_event()
		get_tree().set_input_as_handled()

func set_disabled(value):
	.set_disabled(value)
	if value:
		_button_pressed = false
		_current_duration = 0
		_signal_sent = false
		_update_button()

func nearest_po2_decimal(value,min_value,max_value):
	if value<=min_value:
		return min_value
	if value>=max_value:
		return max_value
	return ceil(value*pow_16_value)/pow_16_value

func _update_button():
	if abs(_current_duration - click_duration_threshold) < 1.0 and not _signal_sent:
		_signal_sent = true
		emit_signal("long_pressed")

	var value = 1.0 - nearest_po2_decimal(_current_duration / click_duration_threshold, 0.0, 1.0)
	canva_material.set_shader_param("loading", value)
