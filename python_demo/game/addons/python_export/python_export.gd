tool
extends EditorPlugin


class PythonExportPlugin:
	extends EditorExportPlugin
	var exclude_list = ["res://addons/python_export"]
	var end_exclude_list = ["py"]
	func scan(path:String) -> Array:
		var file_name := ""
		var files := []
		var dir := Directory.new()
		if dir.open(path) != OK:
			print("Failed to open:"+path)
		else:
			dir.list_dir_begin(true)
			file_name = dir.get_next()
			while file_name!="":
				if dir.current_is_dir():
					var sub_path = path+"/"+file_name
					if sub_path in exclude_list:
						pass
					else:
						files += scan(sub_path)
				else:
					if file_name.get_extension() in end_exclude_list:
						pass
					else:
						var name := path+"/"+file_name
						files.push_back(name)
				file_name = dir.get_next()
			dir.list_dir_end()
		return files

	func _add_python_addons() -> void:
#		var compileall_py_instance = load("res://addons/python_export/compileall_py.tscn").instance()
#		var path_root = ProjectSettings.globalize_path("res://")
#		compileall_py_instance.path_root = path_root
#		compileall_py_instance._process()
		OS.execute(ProjectSettings.globalize_path("res://addons/pythonscript/windows-64/python.exe"),["-m", "compileall", "-b",ProjectSettings.globalize_path("res://")])
		var files = scan('res://addons/pythonscript/windows-64')
		for python_file in files:
			var file = File.new()
			file.open(python_file, File.READ)
			var buff = file.get_buffer(file.get_len())
			file.close()
			add_file(python_file,buff,false)
			
		files = scan('res://')
		for pyc_file in files:
			print(pyc_file.get_extension())
			if pyc_file.get_extension() == "pyc":
				print(pyc_file)
				var file = File.new()
				file.open(pyc_file, File.READ)
				var buff = file.get_buffer(file.get_len())
				file.close()
				add_file(pyc_file,buff,false)
		

	func _process_hooks(hooks_path: String, args: Array) -> void:
		var dir = Directory.new()
		if dir.open(hooks_path) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != '':
				if not dir.current_is_dir() and file_name.ends_with('.gd'):
					var hook = load(dir.get_current_dir() + "/" + file_name)
					hook.callv('process', args)
				file_name = dir.get_next()
		else:
			# ignore error
			pass

	func _process_start_hooks(features: PoolStringArray, debug: bool, path: String, flags: int) -> void:
		_process_hooks('res://addons/python-export/start_hook', [features, debug, path, flags])

	func _process_end_hooks() -> void:
		_process_hooks('res://addons/python-export/end_hook', [])

	func _export_begin(features: PoolStringArray, debug: bool, path: String, flags: int) -> void:
		_process_start_hooks(features, debug, path, flags)
		if 'Windows' in features:
			# Only handle the windows platform, ignore other platforms. Note that if you need to export to other platforms, you may need to close the plug-in and restart the client before exporting
			_add_python_addons()

	func _export_end() -> void:
		_process_end_hooks()
		pass
		
	func _export_file(path, type, features)->void:
		if path.get_extension() in end_exclude_list:
			skip()
		

func _init():
	add_export_plugin(PythonExportPlugin.new())

func _enter_tree():
	pass

func _exit_tree():
	pass
