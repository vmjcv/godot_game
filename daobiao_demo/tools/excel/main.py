#!/usr/bin/env python
#coding=utf-8

import os, json, xlrd
import glob
import colorama
colorama.init(autoreset=True)
from src.JSONExporter import JSONExporter
from src.TypeScriptExporter import TypeScriptExporter
from src.GDScriptExporter import GDScriptExporter
from src.CSharpExporter import CSharpExporter
from src.parser import load_tabels

CONFIG = json.load(open('config.json', 'r',  encoding='utf8'))
def main():
	exporters = []
	for name in CONFIG['exporter']:
		if name == 'json' and CONFIG['exporter'][name]['enabled']: exporters.append(JSONExporter(CONFIG))
		if name == 'typescript' and CONFIG['exporter'][name]['enabled']: exporters.append(TypeScriptExporter(CONFIG))
		if name == 'gdscript' and CONFIG['exporter'][name]['enabled']: exporters.append(GDScriptExporter(CONFIG))
		if name == 'csharp' and CONFIG['exporter'][name]['enabled']: exporters.append(CSharpExporter(CONFIG))
	if not os.path.isdir(CONFIG['output']): os.makedirs(CONFIG['output'])

	if CONFIG['input_dir']:
		file_glob = os.path.join(CONFIG['input_dir']['file'],'**/*.'+'xls')
		print(file_glob)
		for filename in glob.glob(file_glob,recursive=True):
			print(filename)
			print("Parsing file", filename, "with encoding", CONFIG['input_dir']['encode'])
			tables = load_tabels(filename, CONFIG['input_dir']['encode'], CONFIG['parser'])
			for exporter in exporters:
				exporter.parse_tables(tables)
	else:
		for input in CONFIG['input']:
			print("Parsing file", input['file'], "with encoding", input['encode'])
			tables = load_tabels(input['file'], input['encode'], CONFIG['parser'])
			for exporter in exporters:
				exporter.parse_tables(tables)
	for exporter in exporters:
		print("Exporting for", exporter.name)
		exporter.dump()
	print(colorama.Fore.GREEN + "All Done!")

if __name__ == '__main__':
	main()
