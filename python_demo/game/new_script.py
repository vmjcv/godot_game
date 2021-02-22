from godot import exposed, export
from godot import *
from bilibili_api import live
from threading import Thread

@exposed
class new_script(Node):
	# member variables here, example:
	a = export(int)
	b = export(str, default='foo')
	
	def _ready(self):
		
