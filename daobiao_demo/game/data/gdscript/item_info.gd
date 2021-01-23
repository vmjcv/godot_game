# Tool generated file DO NOT MODIFY
tool

class item_infoData:
	var id: int
	var info: String
	var name: String
	func _init(p_id, p_info, p_name):
		id = p_id
		info = p_info
		name = p_name

static func load_configs():
	return {
		1: item_infoData.new(1, "this is a pen", "pen"),
		2: item_infoData.new(2, "this is water", "water"),
	}
