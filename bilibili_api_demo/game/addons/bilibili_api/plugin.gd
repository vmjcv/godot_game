tool
extends EditorPlugin

var plugin

func get_name():
	return 'Bilibili'

func _enter_tree():
	add_autoload_singleton("Bilibili", 'res://addons/bilibili_api/core/anima.gd')

func _exit_tree():
	remove_autoload_singleton('Bilibili')
