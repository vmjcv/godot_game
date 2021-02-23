from godot import exposed, export
from godot import *
from bilibili_api import live
from threading import Thread
import asyncio

@exposed
class bilibili(Node):
	# member variables here, example:
	room = None
	print_panel = None
	def _ready(self):
		pass

	async def on_danmu(self,msg):
		self.print_panel.get_msg(Dictionary({"text":msg["data"]["info"][1],"name":msg["data"]["info"][2][1]}))

	async def on_gift(self,msg):
		self.print_panel.get_msg(Dictionary({"name":msg["data"]["data"]["uname"],"gift":msg["data"]["data"]["giftName"]}))

	def connect_room(self,roomid):
		def target(loop):
			asyncio.set_event_loop(loop)
			coroutine = self.room.connect(return_coroutine=True)
			asyncio.get_event_loop().run_until_complete(coroutine)
		new_loop = asyncio.new_event_loop()
		self.room = live.LiveDanmaku(room_display_id=roomid)
		self.room.add_event_handler(event_name = "DANMU_MSG",func=self.on_danmu)
		self.room.add_event_handler(event_name = "SEND_GIFT",func=self.on_gift)
		t = Thread(target=target, daemon=True,args = (new_loop,))
		t.start()
