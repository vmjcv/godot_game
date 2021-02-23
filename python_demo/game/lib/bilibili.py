from godot import exposed, export
from godot import *
from bilibili_api import live
from threading import Thread
import asyncio

@exposed
class bilibili(Node):
	# member variables here, example:
	room = None
	def _ready(self):
		self.connect_room()

	async def on_danmu(self,msg):
		print(msg)

	async def on_gift(self,msg):
		print(msg)


	def connect_room(self):
		def target(loop):
			asyncio.set_event_loop(loop)
			coroutine = self.room.connect(return_coroutine=True)
			asyncio.get_event_loop().run_until_complete(coroutine)

		new_loop = asyncio.new_event_loop()
		self.room = live.LiveDanmaku(room_display_id=53849)
		self.room.add_event_handler(event_name = "DANMU_MSG",func=self.on_danmu)
		self.room.add_event_handler(event_name = "SEND_GIFT",func=self.on_gift)
		t = Thread(target=target, daemon=True,args = (new_loop,))
		t.start()
