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
	return [
		item_infoData.new(1, "陪我熬过整个高中生活的笔，已经快没水了..", "钢笔"),
		item_infoData.new(2, "虽然红色的花看起来很有生命力，但其实很快就枯萎了..", "红花"),
	]
