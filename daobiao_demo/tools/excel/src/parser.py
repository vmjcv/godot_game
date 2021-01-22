#!/usr/bin/env python
#coding=utf-8

import os, json, xlrd

SKIP_TAG = '@skip'
	
# 读取原始数据
def load_tabels(file, encode, configs):
	if os.path.isfile(file):
		tables = {}
		xlrd.Book.encoding = encode
		data = xlrd.open_workbook(file)
		for sheet_name in data.sheet_names():
			sheet_name = sheet_name.strip()
			# 忽略 @skip 表
			if str(sheet_name).strip().startswith(SKIP_TAG): continue
			table_data = []
			
			sheet = data.sheet_by_name(sheet_name)
			title_row = None
			for i in range(0, sheet.nrows):
				row = sheet.row_values(i)
				if not is_valid_row(row): continue
				if not title_row:
					title_row = row
					continue
				row_data = process_row(title_row, row, configs)
				if row_data: table_data.append(row_data)
			# 忽略空表
			if len(table_data) == 0: continue
			tables[sheet_name] = table_data
		return tables
	else:
		raise Exception("文件不存在: " + file)

def is_valid_row(row):
	if str(row[0]).strip() == SKIP_TAG: return False
	all_empty = True
	for v in row:
		all_empty = all_empty and isinstance(v, str) and len(v.strip()) == 0
		if not all_empty: break
	if all_empty: return False
	return True

def process_row(title_row, row, configs):
	data = {}
	for i in range(len(title_row)):
		key = title_row[i]
		if len(key.strip()) == 0:
			continue
		value = row[i]
		if isinstance(value, str) and len(value.strip()) == 0:
			value = None
		elif isinstance(value, float):
			if value == int(value) and not configs['floating_numbers']:
				value = int(value)
		if key in data:
			if isinstance(data[key], list):
				data[key].append(value)
			else:
				data[key] = [data[key], value]
		else:
			data[key] = value
	return data