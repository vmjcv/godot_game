import json, os
from .Exporter import Exporter
import colorama

class JSONExporter(Exporter):
	def __init__(self, config):
		super(JSONExporter, self).__init__(config)
		self.name = "json"
	
	def detect_type(self, value):
		if isinstance(value, str):
			return "string"
		elif isinstance(value, int) or isinstance(value, float):
			return "number"
		elif isinstance(value, bool):
			return "boolean"
		else:
			return "any"

	def export_json(self, tabel, name):
		new_tabel = []
		types = {}
		for row in tabel:
			new_row = {}
			for key in row:
				value = json.loads(json.dumps(row[key], ensure_ascii=False))
				if isinstance(value, list):
					while len(value) > 0 and (value[len(value)-1] is None):
						value.pop(len(value) - 1)
				if key not in types:
					types[key] = self.detect_type(value)
				if self.detect_type(value) != types[key]:
					print(colorama.Fore.RED + "  {table}表中{key}字段的值{value}与定义类型{type}不符:\n    {row}".format(
						table = name,
						key = key,
						value= value,
						type= types[key],
						row= row
					))
					if self.config['exporter']['json']['incompatible_as_default'] and types[key] in self.config['exporter']['json']['default']:
						value = self.config['exporter']['json']['default'][types[key]]
						display_value = str(value)
						if len(display_value) == 0: display_value = '<empty>'
						print(colorama.Fore.RED + "  该数据已被替换为默认值: " + display_value)
				new_row[key] = value
			new_tabel.append(new_row)
		return new_tabel

	def dump_json(self, name, data):
		out_path = os.path.join(self.config['output'], self.name, name + '.json')
		if not os.path.isdir(os.path.dirname(out_path)):
			os.makedirs(os.path.dirname(out_path))
		indent = self.config['exporter']['json']['indent']
		json.dump(
			data,
			open(out_path, 'w', encoding="utf8"),
			sort_keys=True, ensure_ascii=False,
			indent=indent
		)
		
	def parse_tables(self, tables):
		for name in tables:
			self.tables[name] = self.export_json(tables[name], name)
			
	def dump(self):
		for name in self.tables:
			self.dump_json(name, self.tables[name])