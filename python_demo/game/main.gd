extends Control



onready var roomid = $"VBoxContainer/HBoxContainer/LineEdit"
onready var connect_node = $"Node"
onready var msg_panel = $"VBoxContainer/ScrollContainer/VBoxContainer"
# Called when the node enters the scene tree for the first time.
func _ready():
	connect_node.print_panel = self


func _on_Button_pressed():
	connect_node.connect_room(int(roomid.text))

func get_msg(msg):
	var label = Label.new()
	label.text = var2str(msg)
	msg_panel.call_deferred("add_child",label)
