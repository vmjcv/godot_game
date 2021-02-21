extends Reference
var util = load("util.gd").new()
var user = load("user.gd").new()
var common = load("common.gd").new()

var API = util.get_api()

func __parse_at(text):
	var regex = RegEx.new()
	regex.compile("(?<=@)\\d*(?=\\s)")
	var regex_result = regex.search_all(text)
	var uid
	var name
	var uid_list=[]
	var names=[]
	var new_text = text
	for result in regex_result:
		uid = result.get_string()
		var user_info = user.get_user_info(int(uid))
		name = user_info["name"]
		uid_list.append(uid)
		names.append(name)
		new_text = new_text.replace("@%s"%uid,"@%s"%name)
	var at_uids = uid_list.join(",")
	var ctrl = []
	for i in range(len(names)):
		name = names[i]
		var index = new_text.index("@%s"%name)
		var length = 2+len(name)
		ctrl.append({
			"location": index,
			"type": 1,
			"length": length,
			"data": int(uid_list[i])
		})
	return [new_text,at_uids,to_json(ctrl)]

func __get_text_data(text,verify):
	var parse_at_data = __parse_at(text)
	var new_text = parse_at_data[0]
	var at_uids = parse_at_data[1]
	var ctrl = parse_at_data[2]
	var data = {
		"dynamic_id": 0,
		"type": 4,
		"rid": 0,
		"content": new_text,
		"extension": '{\"emoji_type\":1}',
		"at_uids": at_uids,
		"ctrl": ctrl,
		"csrf_token": verify.csrf
	}
	return data

func pic(image):
	return {"img_src": image["image_url"], "img_width": image["image_width"],
			"img_height": image["image_height"]}


func __get_draw_data(http_request,text,images_path,verify):
	var parse_at_data = __parse_at(text)
	var new_text = parse_at_data[0]
	var at_uids = parse_at_data[1]
	var ctrl = parse_at_data[2]
	var images_info = []
	for path in images_path:
		var i = util.upload_image(http_request,path,verify)
		images_info.append(i)
	var pictures = []
	for i in images_info:
		pictures.append(pic(i))


	var data = {
		"biz": 3,
		"category": 3,
		"type": 0,
		"pictures": to_json(pictures),
		"title": "",
		"tags": "",
		"description": new_text,
		"content": new_text,
		"from": "create.dynamic.web",
		"up_choose_comment": 0,
		"extension": to_json({"emoji_type": 1, "from": {"emoji_type": 1}, "flag_cfg": {}}),
		"at_uids": at_uids,
		"at_control": ctrl,
		"setting": to_json({
			"copy_forbidden": 0,
			"cachedTime": 0
		}),
		"csrf_token": verify.csrf
	}
	return data

func instant_text(http_request,text,verify):
	var api = API["dynamic"]["send"]["instant_text"]
	var data = __get_text_data(text, verify)
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func instant_draw(http_request,text,images_path,verify):
	var api = API["dynamic"]["send"]["instant_draw"]
	var data = __get_text_data(text, verify)
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func schedule(http_request,type_,text,images_path,verify):
	var api = API["dynamic"]["send"]["schedule"]
	var request
	if type_==4:
		request =__get_draw_data(text, images_path, verify)
		request.pop("setting")
	elif type_==2:
		request =__get_text_data(text, verify)
	else:
		push_error("暂不支持的动态类型")

	var data = {
		"type": type_,
		"publish_time": int(send_time.timestamp()),
		"request": to_json(request),
		"csrf_token": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func send_dynamic(http_request,text,images_path=null,send_time=null,verift=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if not images_path:
		images_path = []
	var ret
	if len(images_path)==0:
		if not send_time:
			ret = instant_text(http_request,text,verify)
		else:
			ret = schedule(http_request,2,text,images_path,verify)
	else:
		if len(images_path)>9:
			push_error("最多上传9张图片")
		if not send_time:
			ret = instant_draw(http_request,text,images_path,verify)
		else:
			ret = schedule(http_request,4,text,images_path,verify)
	return ret

func get_schedules_list(http_request,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api = API["dynamic"]["schedule"]["list"]
	var resp = util.bilibili_get(http_request,api["url"], null, verify.get_cookies())
	return resp


func send_schedule_now(http_request,draft_id,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["dynamic"]["schedule"]["publish_now"]
	var data = {
		"draft_id": draft_id,
		"csrf_token": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func delete_schedule(http_request,draft_id,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["dynamic"]["schedule"]["delete"]
	var data = {
		"draft_id": draft_id,
		"csrf_token": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func get_info(http_request,dynamic_id,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["dynamic"]["info"]["detail"]
	var params = {
		"dynamic_id": dynamic_id
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	data["card"]["card"] = to_json(data["card"]["card"])
	data["card"]["extend_json"] = to_json(data["card"]["extend_json"])
	return data["card"]

func get_reposts_raw(http_request,dynamic_id,offset="0",verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["dynamic"]["info"]["repost"]
	var params = {
		"dynamic_id": dynamic_id,
		"offset": offset
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_reposts_r(http_request,dynamic_id,verify=null):
	if not verify:
		verify = util.Verify()
	var offset =""
	var result_data = []
	while true:
		var data = get_reposts_raw(http_request,dynamic_id, offset, verify)
		if not ("items" in data):
			break
		var items = data["items"]
		for v in items:
			i["card"] = to_json(i["card"])
			i["extend_json"] = to_json(i["extend_json"])
			result_data.append(i)
		if not ("offset" in data):
			break
		offser = data["offset"]
	return result_data


func set_like(http_request,dynamic_id,status=true, verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["dynamic"]["operate"]["like"]

	var data = {
		"dynamic_id": dynamic_id,
		"up": 1 if status else 2,
		"uid": self_uid,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func delete(http_request,dynamic_id, verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["dynamic"]["operate"]["delete"]

	var data = {
		"dynamic_id": dynamic_id,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func repost(http_request,dynamic_id,text="转发动态", verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["dynamic"]["operate"]["repost"]

	var data = {
		"dynamic_id": dynamic_id,
		"content": text,
		"extension": '{\"emoji_type\":1}',
		"csrf_token": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

const TYPE_MAP = {
    2: "dynamic_draw",
    4: "dynamic_text"
}

func __get_type_and_rid(dynamic_id):
	var dy_info = get_info(dunamic_id)
	var type_ = TYPE_MAP.get(dy_info["desc"]["type"],TYPE_MAP[4])
	var rid =  dynamic_id
	if type_ == "dynamic_draw":
		rid = dy_info["desc"]["rid"]
	return [type_,rid]

func get_comments_g(http_request,dynamic_id,order="time",verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var replies = common.get_comments(http_request,rid,type_,order,verify)
	return replies

func get_sub_comments_g(http_request,dynamic_id,root,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var replies = common.get_sub_comments(http_request,rid,type_,root,verify)
	return replies

func send_comment(http_request,text,dynamic_id,root=null,parent=null,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var resp = common.send_comment(http_request,text, rid, type_, root, parent,verify)
	return resp

func set_like_comment(http_request,rpid,dynamic_id,status=true,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var resp = common.operate_comment(http_request,"like", rid, type_, rpid, status, verify)
	return resp

func set_hate_comment(http_request,rpid,dynamic_id,status=true,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var resp = common.operate_comment(http_request,"hate", rid, type_, rpid, status, verify)
	return resp

func set_top_comment(http_request,rpid,dynamic_id,status=true,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var resp = common.operate_comment(http_request,"top", rid, type_, rpid, status, verify)
	return resp


func del_comment(http_request,rpid,dynamic_id,verify=null):
	var type_and_rid = __get_type_and_rid(dynamic_id)
	var type_=type_and_rid[0]
	var rid=type_and_rid[1]
	var resp = common.operate_comment(http_request,"del", rid, type_, rpid, verify)
	return resp
