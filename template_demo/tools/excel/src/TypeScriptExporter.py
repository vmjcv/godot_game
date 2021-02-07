import json, os
from .Exporter import Exporter

class TypeScriptExporter(Exporter):
	def __init__(self, config):
		super(TypeScriptExporter, self).__init__(config)
		self.name = "typescript"
		self.declear_content = self.line("// Tool generated file DO NOT MODIFY")
		self.declear_content += self.line()
		
	def detect_type(self, value):
		if isinstance(value, str):
			return "string"
		elif isinstance(value, int) or isinstance(value, float):
			return "number"
		elif isinstance(value, bool):
			return "boolean"
		elif isinstance(value, dict):
			ret = self.line("{")
			for key in value:
				ret += self.line("{}: {};".format(key, self.detect_type(value[key])), 1)
			ret += self.line("}")
			return ret
		elif isinstance(value, list):
				if len(value) > 0:
					return self.detect_type(value[0]) + "[]"
				return "any[]"
		else:
			return "any"

	def parse_tables(self, tables):
		for name in tables:
			data = tables[name]
			if len(data):
				body = self.detect_type(data[0])
				class_name = self.config['exporter']['typescript']['type_prefix'] + name + self.config['exporter']['typescript']['type_extention']
				text = 'interface {} {}'.format(class_name, body)
				self.declear_content += text
				self.declear_content += self.line()

	def dump(self):
		out_path = os.path.join(self.config['output'], self.name, self.config['exporter']['typescript']['file_name'] + ".d.ts")
		if not os.path.isdir(os.path.dirname(out_path)): os.makedirs(os.path.dirname(out_path))
		file = open(out_path, 'w', encoding="utf8")
		file.write(self.declear_content)