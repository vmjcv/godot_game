extends Node2D


func _ready():
	init_label()

func init_label():
	var temp_item_1 = Configs.get_table_by_key("item_info",1)
	$info.text = temp_item_1.info
	
	var temp_table = Configs.get_table("item_info")
	$name.text = temp_table[1].name
