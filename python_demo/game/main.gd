extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var room = $"Node"
var thread
# Called when the node enters the scene tree for the first time.
func _ready():
	print("22222222222")
	thread = Thread.new()
	thread.start(room,"connect_room")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
