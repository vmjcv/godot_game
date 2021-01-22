# Tool generated file DO NOT MODIFY
tool
extends Node

const item_infoScript = preload("item_info.gd")
const item_infoData = item_infoScript.item_infoData

var unique_id_depot = {}
var configs = {
	item_infoData: [],
}

func get_config_by_uid(id: int):
	return unique_id_depot[id] if id in unique_id_depot else null

func get_table_configs(table: GDScript):
	return configs[table] if table in configs else null

func _init():
	configs[item_infoData] = item_infoScript.load_configs()
	for d in configs[item_infoData]: unique_id_depot[d.get_instance_id()] = d
