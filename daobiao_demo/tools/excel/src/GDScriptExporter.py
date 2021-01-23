import json, os
from .Exporter import Exporter

class GDScriptExporter(Exporter):
	def __init__(self, config):
		super(GDScriptExporter, self).__init__(config)
		self.name = "gdscript"

	def export_table(self, tabel):
		return tabel

	def detect_type(self, value):
		if isinstance(value, str):
			return "String"
		elif isinstance(value, int):
			return "int"
		elif isinstance(value, float):
			return "float"
		elif isinstance(value, bool):
			return "bool"
		elif isinstance(value, dict):
			return "Dictionary"
		elif isinstance(value, list):
			return "Array"
		else:
			return None

	def is_tool(self):
		return self.config["exporter"]["gdscript"]["tool"]

	def is_autoload(self):
		return self.config["exporter"]["gdscript"]["autoload"]

	def convert_value(self, value, valueType):
		if  valueType=="String":
			return '"' + value.replace('"', '\\"') + '"'
		elif valueType=="int" or valueType=="float" or valueType=="bool":
			return str(value)
		elif valueType=="Dictionary" or valueType=="Array":
			jsonStr=json.dumps(value, ensure_ascii=False, sort_keys=True)
			return "JSON.parse({}).result".format(jsonStr)
		elif  isinstance(value, str):
			return '"' + value.replace('"', '\\"') + '"'
		elif isinstance(value, dict) or isinstance(value, list):
			jsonStr=json.dumps(value, ensure_ascii=False, sort_keys=True)
			return "JSON.parse({}).result".format(jsonStr)
		elif value is None:
			return "null"
		return str(value)

	def get_class_name(self, table_name):
		class_name = "{}{}{}".format(
			self.config["exporter"]["gdscript"]["type_prefix"],
			table_name,
			self.config["exporter"]["gdscript"]["type_extention"],
		)
		return class_name

	def dump_script(self, name, data):
		out_path = os.path.join(self.config['output'], self.name, name + '.gd')
		print("Sheet", name, "==>", out_path)
		if not os.path.isdir(os.path.dirname(out_path)): os.makedirs(os.path.dirname(out_path))
		class_name = self.get_class_name(name)
		script_text = self.line("# Tool generated file DO NOT MODIFY")
		if self.is_tool(): script_text += self.line("tool")
		script_text += self.line()
		script_text += self.line("class {}:".format(class_name))
		first_line = data[0]
		second_line = data[1]
		props = sorted(data[1].keys())
		idx = 0
		params = ""
		initializers = ""
		key_name = "id"
		for key in props:
			# declear
			key_list = key.split("_")
			cur_key = key
			if key_list[-1] == "key":
				key_list.pop()
				cur_key = "_".join(key_list)

			gd_type = first_line[key] or self.detect_type(second_line[key])
			gd_type = ": " + gd_type if gd_type else ""
			declear = self.line("var {}{}".format(cur_key, gd_type), 1)
			script_text += declear
			# parms
			param = "p_" + cur_key
			if idx > 0: params += ", "
			params +=  param
			# initialize
			initializer = self.line("{} = {}".format(cur_key, param), 2)
			initializers += initializer
			idx += 1
			if cur_key != key:
				# 只取最后一个以_key作为字典的key
				key_name = key

		constructor_func = self.line("func _init({}):".format(params), 1)
		script_text += constructor_func
		script_text += initializers

		script_text += self.line()
		script_text += self.line("static func load_configs():")
		script_text += self.line("return {", 1)
		for row in data[1:]:
			args = ""
			idx = 0
			for key in props:
				if idx > 0: args += ", "
				args += self.convert_value(row[key],first_line[key])
				idx += 1
			key_id = self.convert_value(row[key_name], first_line[key_name])
			line = self.line("{}: {}.new({}),".format(key_id,class_name, args), 2)
			script_text += line
		script_text += self.line("}", 1)
		file = open(out_path, 'w', encoding="utf8")
		file.write(script_text)

	def parse_tables(self, tables):
		for name in tables:
			self.tables[name] = self.export_table(tables[name])

	def dump(self):
		index_file_content = self.line("# Tool generated file DO NOT MODIFY")
		if self.is_tool(): index_file_content += self.line("tool")
		if self.is_autoload(): index_file_content += self.line("extends Node")
		index_file_content += self.line()
		scripts_consts = ""
		classes_consts = ""

		depot = self.line("var unique_id_depot = {}")
		functions = self.line("func get_config_by_uid(id: int):")
		functions += self.line("return unique_id_depot[id] if id in unique_id_depot else null", 1)
		functions += self.line()
		functions += self.line("func get_table_configs(table: GDScript):")
		functions += self.line("return configs[table] if table in configs else null", 1)
		functions += self.line()
		functions += self.line("func get_table(table_name: String):")
		functions += self.line("return get_table_configs(get(table_name + 'Data'))", 1)
		functions += self.line()
		functions += self.line("func get_table_by_key(table_name: String, key):")
		functions += self.line("return get_table(table_name)[key]", 1)
		functions += self.line()

		configs = self.line("var configs = {")
		configs_initializers = self.line("func _init():")
		unique_id_depot_setup = ""
		for name in self.tables:
			self.dump_script(name, self.tables[name])
			script_const_name = name + "Script"
			scripts_consts += self.line('const {} = preload("{}.gd")'.format(script_const_name, name))
			classes_consts += self.line('const {0} = {1}.{0}'.format(self.get_class_name(name), script_const_name))
			configs += self.line("{}: ".format(self.get_class_name(name))+"{},", 1)
			configs_initializers += self.line("configs[{}] = {}.load_configs()".format(self.get_class_name(name), script_const_name), 1)
			unique_id_depot_setup += self.line(
				"for d in configs[{}]: unique_id_depot[configs[{}][d].get_instance_id()] = d".format(self.get_class_name(name), self.get_class_name(name)), 1)
		configs += self.line("}")

		index_file_content += scripts_consts
		index_file_content += classes_consts
		index_file_content += self.line()
		index_file_content += depot
		index_file_content += configs
		index_file_content += self.line()
		index_file_content +=  functions
		index_file_content += self.line()
		index_file_content += configs_initializers
		# index_file_content += self.line()
		index_file_content += unique_id_depot_setup

		out_path = os.path.join(self.config['output'], self.name, self.config['exporter']['gdscript']['index_file'] + '.gd')
		if not os.path.isdir(os.path.dirname(out_path)): os.makedirs(os.path.dirname(out_path))
		file = open(out_path, 'w', encoding="utf8")
		file.write(index_file_content)
