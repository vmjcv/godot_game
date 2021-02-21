extends Reference
var util = load("util.gd").new()
var user = load("user.gd").new()
var API = util.get_api()

func get_room_play_info(http_request,room_display_id,stream_config=null,verify=null):
	if not verify:
		verify = util.Verify()
	if not stream_config:
		stream_config = {
			"protocol": 0,
			"format": 0,
			"codec": 1,
			"qn": 10000
		}
	var api = API["live"]["info"]["room_play_info_v2"]
	var params = {
		"room_id": room_display_id,
		"platform": "web",
		"ptype": "16",
	}
	if stream_config:
		for key in stream_config:
			params[key] = stream_config[key]
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func get_room_play_url(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["room_play_url"]
	var params = {
		"cid": room_real_id,
		"platform": "web",
		"qn": 10000,
		"https_url_req": "1",
		"ptype": "16"
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_chat_conf(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["chat_conf"]
	var params = {
		"room_id": room_real_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_room_info(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["room_info"]
	var params = {
		"room_id": room_real_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_user_info_in_room(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])
	var api = API["live"]["info"]["user_info_in_room"]
	var params = {
		"room_id": room_real_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_self_info(http_request,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])
	var api = API["live"]["info"]["user_info"]
	var resp = util.bilibili_get(http_request,api["url"], null, verify.get_cookies())
	return resp

func get_black_list(http_request,room_real_id,limit=114514,callback=null,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api = API["live"]["info"]["black_list"]
	var params = {
		"room_id": room_real_id
	}
	var users = []
	var count = 0
	var page = 1
	var resp
	while count<limit:
		resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies(),null,"form",{"page":page})
		if len(resp) ==0:
			break
		if callback:
			callback.call(resp)
		users.append(resp)
		page+=1
		count+=len(resp)
	return resp.slice(0,limit)

func get_dahanghai_raw(http_request,room_real_id,ruid,page=1,page_size=29,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["dahanghai"]
	var params = {
		"roomid": room_real_id,
		"ruid": ruid,
		"page_size": page_size,
		"page": page
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_dahanghai(http_request,room_real_id,limit=114514,callback=null,verify=null):
	if not verify:
		verify = util.Verify()
	var ruid = get_room_play_info(http_request,room_real_id)["uid"]
	var users = []
	var count = 0
	var page = 1
	var resp
	while count<limit:
		resp = get_dahanghai_raw(http_request,room_real_id,ruid,page,29,verify)
		if page ==1:
			if len(resp["top3"])!=0:
				count +=len(resp["top3"])
				user.append_array(resp["top3"])
		if len(resp["list"]) ==0:
			break
		count +=len(resp["list"])
		user.append_array(resp["list"])
		if callback:
			callback.call(resp["list"])
		page+=1
	return users.slice(0,limit)

func get_seven_rank(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["seven_rank"]
	var ruid = get_room_play_info(http_request,room_real_id)["uid"]
	var params = {
		"roomid": room_real_id,
		"ruid": ruid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_fans_medal_rank(http_request,room_real_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["live"]["info"]["fans_medal_rank"]
	var ruid = get_room_play_info(http_request,room_real_id)["uid"]
	var params = {
		"roomid": room_real_id,
		"ruid": ruid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func send_danmaku(http_request,room_real_id,danmaku,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["live"]["operate"]["send_danmaku"]
	var data = {
		"mode": danmaku.mode,
		"msg": danmaku.text,
		"roomid": room_real_id,
		"bubble": 0,
		"csrf": verify.csrf,
		"csrf_token": verify.csrf,
		"rnd": int(OS.get_unix_time()),
		"color": danmaku.color.get_dec_color(),
		"fontsize": danmaku.font_size
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func ban_user(http_request,room_real_id,uid,hour =1,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["live"]["operate"]["add_block"]
	var data = {
		"roomid": room_real_id,
		"block_uid": uid,
		"hour": hour,
		"csrf": verify.csrf,
		"csrf_token": verify.csrf,
		"visit_id": ""
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func unban_user(http_request,room_real_id,block_id,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["live"]["operate"]["del_block"]
	var data = {
		"roomid": room_real_id,
		"id": block_id,
		"visit_id": "",
		"csrf": verify.csrf,
		"csrf_token": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func connect_all_LiveDanmaku(livedanmaku_classes_list):
	for room in livedanmaku_classes_list:
		room.connect(True)


class LiveDanmaku:
	# TODO: 需要注意这块没完成
	const PROTOCOL_VERSION_RAW_JSON = 0
	const PROTOCOL_VERSION_HEARTBEAT = 1
	const PROTOCOL_VERSION_ZLIB_JSON = 2
	const DATAPACK_TYPE_HEARTBEAT = 2
	const DATAPACK_TYPE_HEARTBEAT_RESPONSE = 3
	const DATAPACK_TYPE_NOTICE = 5
	const DATAPACK_TYPE_VERIFY = 7
	const DATAPACK_TYPE_VERIFY_SUCCESS_RESPONSE = 8
	var verify
	var room_real_id
	var room_display_id
	var __use_wss
	var __event_handlers
	var __websocket
	var __connected_status
	var __conf
	var should_reconnect
	var __heartbeat_task
	var __is_single_room
	func _init(room_display_id,debug=false,use_wss=true,should_reconnect=true,verify=null):
		self.verify = verify
		self.room_real_id = room_real_id
		self.__use_wss = __use_wss
		self.__event_handlers={}
		self.__websocket=null
		self.__connected_status=0
		self.__conf=null
		self.should_reconnect=should_reconnect
		self.__heartbeat_task = null
		self.__is_single_room = false

	func connect_room(http_request,return_coroutine=false):
		if self.__connected_status ==1:
			push_error("已连接直播间，不可重复连接")
		if return_coroutine:
			self.__is_single_room = false
			return self.__main(http_request)
		else:
			self.__is_single_room = true
			self.__main(http_request)

	func disconnect_room():
		self.__connected_status = 2
		self.__ws.close()

	func get_connect_status():
		return self.__connected_status

	func __main(http_request):
		self.room_real_id = get_room_play_info(http_request,self.room_real_id,null,self.verify)["room_id"]
		self.__conf =get_chat_conf(http_request,self.room_real_id,self.verify)
		for host in self.__conf["host_server_list"]:
			var port = host['wss_port'] if self.__use_wss else host['ws_port']
			var protocol = "wss" if self.__use_wss else "ws"
			var uri = "%s://%s:%s/sub"%[protocol,host,port]
			self.__ws = WebSocketClient.new()
			var err = self.__ws.connect_to_url(uri)
			var uid = null
			if self.verify:
				if self.verify.has_sess():
					var self_info = user.get_self_info(self.verify)
					uid = self_info["mid"]
			var verifyData = {
					"uid":0  if uid is None else uid,
					"roomid":self.room_real_id,
					"protover":2,
					"platform":"web",
					"clientver":"1.17.0",
					"type":2,
					"key":self.__conf["token"]
			}
			var data = to_json(verifyData)
			self.__send(data,PROTOCOL_VERSION_HEARTBEAT,DATAPACK_TYPE_VERIFY)
			self.__connected_status =1
			if self.__connected_status >=0:
				return
			if not self.should_reconnect:
				return
		self.__connected_status =-1
		push_error("所有主机连接失败，程序终止")

	func __loop():
		self.__heartbeat_task = self.__heartbeat()
		while true:
			var data = self.__recv()
			for info in data:
				var callback_info = {
					'room_display_id': self.room_display_id,
					'room_real_id': self.room_real_id
				}
				if info["datapack_type"] == LiveDanmaku.DATAPACK_TYPE_VERIFY_SUCCESS_RESPONSE:
					# 认证反馈
					pass
				elif info["datapack_type"] == LiveDanmaku.DATAPACK_TYPE_HEARTBEAT_RESPONSE:
					# 心跳包反馈，返回直播间人气
					callback_info["type"] = 'VIEW'
					callback_info["data"] = info["data"]["view"]
				elif info["datapack_type"] == LiveDanmaku.DATAPACK_TYPE_NOTICE:
					# 直播间弹幕、礼物等信息
					callback_info["type"] = info["data"]["cmd"]
					callback_info["data"] = info["data"]
					handlers = self.__event_handlers.get(info["data"]["cmd"], []) + self.__event_handlers.get("ALL", [])
	func __heartbeat():
		var HEARTBEAT = "AAAAHwAQAAEAAAACAAAAAVtvYmplY3QgT2JqZWN0XQ==".base64_to_raw()
		while self.__connected_status == 1:
			self.__ws.send(HEARTBEAT)

	func __send(data,protocol_version,datapack_type):
		var pack_data = self.__pack(data, protocol_version, datapack_type)
		self.__ws.send(pack_data)


	func __recv():
		var raw_data =self.__ws.recv()
		var unpack_data =self.__unpack(raw_data)
		return unpack_data

	func __pack(data,protocol_version,datapack_type):
		sendData = PoolByteArray()
		sendData += struct