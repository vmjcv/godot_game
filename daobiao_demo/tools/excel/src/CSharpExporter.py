import json, os
from .Exporter import Exporter

class CSharpExporter(Exporter):
	def __init__(self, config):
		super(CSharpExporter, self).__init__(config)
		self.name = "csharp"
		self.declear_content = self.line("// Tool generated file DO NOT MODIFY")
		self.declear_content += self.line("using System;")
		self.declear_content += self.line()

	def detect_type(self, value):
		if isinstance(value, str):
			return "string"
		elif isinstance(value, int):
			return "int"
		elif isinstance(value, float):
			return "float"
		elif isinstance(value, bool):
			return "bool"
		elif isinstance(value, dict):
			ret = self.line("{")
			for key in value:
				if self.config['exporter']['csharp']['base_type'] and key == 'id': continue
				ret += self.line("public {} {};".format(self.detect_type(value[key]), key), 1)
			ret += self.line("}")
			return ret
		elif isinstance(value, list):
				if len(value) > 0:
					return self.detect_type(value[0]) + "[]"
				return "object[]"
		else:
			return "object"
		
	def parse_tables(self, tables):
		self.declear_content += self.line("namespace " + self.config['exporter']['csharp']['namespace'] + " {")
		for name in tables:
			data = tables[name]
			if len(data):
				body = self.detect_type(data[0])
				class_name = self.config['exporter']['csharp']['type_prefix'] + name + self.config['exporter']['csharp']['type_extention']
				base_type = self.config['exporter']['csharp']['base_type']
				text = 'public class {} : {} {}'.format(class_name, base_type, body)
				self.declear_content += text
				self.declear_content += self.line()
		self.declear_content += self.line("}")

	def dump(self):
		out_path = os.path.join(self.config['output'], self.name, self.config['exporter']['csharp']['file_name'] + ".cs")
		if not os.path.isdir(os.path.dirname(out_path)): os.makedirs(os.path.dirname(out_path))
		file = open(out_path, 'w', encoding="utf8")
		file.write(self.declear_content)