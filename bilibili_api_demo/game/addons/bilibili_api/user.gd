extends Reference
var util = load("util.gd").new()
var common = load("common.gd").new()
var API = util.get_api()


const MEDIA_TYPE_MAP = {
	"audio": 12,
	"video": 2
}

func get_user_info(http_request,uid,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["app"]["info"]["info"]
	var params = {
		"mid": uid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data


func get_self_info(http_request,verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error("需要验证：SESSDATA")
	var url = "https://api.bilibili.com/x/web-interface/nav"
	var resp = util.bilibili_get(http_request,url, null, verify.get_cookies())
	return resp

func get_relation_info(http_request,uid,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["app"]["info"]["relation"]
	var params = {
		"vmid": uid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data


func get_up_info(http_request,uid,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error("no_sess")
	var api = API["app"]["info"]["upstat"]
	var params = {
		"mid": uid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_live_info(http_request,uid,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["app"]["info"]["live"]
	var params = {
		"mid": uid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_videos_g(http_request,uid,order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_videos_raw(http_request,uid,30,0,page,"",order,verify)
		if not data["list"]["vlist"]:
			break
		for v in data["list"]["vlist"]:
			result_data.append(v)
		page +=1
	return result_data

func get_videos_raw(http_request,uid,ps=30,tid=0,pn=1,keyword="",order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()

	var  ORDER_MAP = {
		"pubdate": "pubdate",
		"view": "click",
		"favorite": "stow"
	}

	if not (order  in ORDER_MAP):
		push_error("排序方式无效，可用值：pubdate（上传日期）、view（播放量）、favorite（收藏量）")

	var api = API["user"]["info"]["video"]

	var params = {
		"mid": uid,
		"ps": ps,
		"tid": tid,
		"pn": pn,
		"keyword": keyword,
		"order": ORDER_MAP[order]
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data




func get_audios_g(http_request,uid,order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_audios_raw(http_request,uid,30,page,order,verify)
		if not data["data"]:
			break
		for v in data["data"]:
			result_data.append(v)
		page +=1
	return result_data

func get_audios_raw(http_request,uid,ps=30,pn=1,order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()

	var  ORDER_MAP = {
		"pubdate": 1,
		"view": 2,
		"favorite": 3
	}

	if not (order  in ORDER_MAP):
		push_error("排序方式无效，可用值：pubdate（上传日期）、view（播放量）、favorite（收藏量）")

	var api = API["user"]["info"]["audio"]

	var params = {
		"uid": uid,
		"ps": ps,
		"pn": pn,
		"order": ORDER_MAP[order]
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data




func get_articles_g(http_request,uid,order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_articles_raw(http_request,uid,30,page,order,verify)
		if not data["articles"]:
			break
		for v in data["articles"]:
			result_data.append(v)
		page +=1
	return result_data

func get_articles_raw(http_request,uid,ps=30,pn=1,order= "pubdate",verify=null):
	if not verify:
		verify = util.Verify()

	var  ORDER_MAP = {
		"pubdate": "publish_time",
		"view": "view",
		"favorite": "fav"
	}

	if not (order  in ORDER_MAP):
		push_error("排序方式无效，可用值：pubdate（上传日期）、view（播放量）、favorite（收藏量）")

	var api = API["user"]["info"]["article"]

	var params = {
		"mid": uid,
		"ps": ps,
		"pn": pn,
		"sort": ORDER_MAP[order]
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data


func get_article_list(http_request,uid,order= "latest",verify=null):
	if not verify:
		verify = util.Verify()

	var  ORDER_MAP = {
		"latest": 0,
		"view": 1
	}

	if not (order  in ORDER_MAP):
		push_error("排序方式无效，可用值：\'latest\'（最近更新），\'view\'（最多阅读）")

	var api = API["user"]["info"]["article_lists"]

	var params = {
		"mid": uid,
		"sort": ORDER_MAP[order]
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data



func get_dynamic_raw(http_request,uid,offset = 0,need_top=false,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["user"]["info"]["dynamic"]

	var params = {
		"host_uid": uid,
		"offset_dynamic_id": offset,
		"need_top": 1 if need_top else 0
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())

	if data['has_more'] != 1:
		return data
	for card in data["cards"]:
		card["card"] = JSON.parse(card["card"])
		card["extend_json"] = JSON.parse(card["extend_json"])
	return data


func get_dynamic_g(http_request,uid,verify=null):
	var offset = "0"
	var result_data = []
	while true:
		var data = get_dynamic_raw(http_request,uid, offset,false, verify)
		if not data["cards"]:
			break
		for v in data["cards"]:
			result_data.append(v)
		if data["has_more"]!=1:
			break
		offset = data["next_offset"]
	return result_data



func get_bangumi_g(http_request,uid,type_ =  "bangumi",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_bangumi_raw(http_request,uid,15,page,type_,verify)
		if len(data["list"])==0:
			break
		for v in data["list"]:
			result_data.append(v)
		page +=1
	return result_data

func get_bangumi_raw(http_request,uid,ps=15,pn=1,type_= "bangumi",verify=null):
	if not verify:
		verify = util.Verify()

	var  TYPE_MAP = {
		"bangumi": 1,
		"drama": 2
	}

	if not (type_  in TYPE_MAP):
		push_error("type_类型错误。接受：bangumi（番剧），drama（追剧）")

	var api = API["user"]["info"]["bangumi"]

	var params = {
		"vmid": uid,
		"pn": pn,
		"ps": ps,
		"type": TYPE_MAP[type_]
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data


func get_favorite_list_content_raw(http_request,media_id,ps=15,pn=1,keyword="",order= "mtime",type_=0,tid=0,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["common"]["favorite"]["get_favorite_list_content"]

	var params = {
		"media_id": media_id,
		"pn": pn,
		"ps": ps,
		"keyword": keyword,
		"order": order,
		"type": type_,
		"tid": tid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_favorite_list_content_g(http_request,media_id,order =  "mtime",verify=null):
	var page =1
	var result_data = []
	while true:
		var data = get_favorite_list_content_raw(http_request,media_id,15,page,"",order,0,0,verify)
		if not data["medias"]:
			break
		for v in data["medias"]:
			result_data.append(v)
		page +=1
	return result_data


func get_favorite_list(http_request,uid,verify=null):
	var resp = common.get_favorite_list(http_request,uid,verify)
	return resp




func get_followings_raw(http_request,uid,ps=20,pn=1,order= "desc",verify=null):
	if not verify:
		verify = util.Verify()
	if order!="desc" and order!="asc":
		push_error("不支持的排序方式")
	var api = API["user"]["info"]["followings"]

	var params = {
		"vmid": uid,
		"ps": ps,
		"pn": pn,
		"order": order
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_followings_g(http_request,uid,order =  "desc",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_followings_raw(http_request,uid,20,page,order,verify)
		if len(data["list"])==0:
			break
		for v in data["list"]:
			result_data.append(v)
		page +=1
	return result_data




func get_followers_raw(http_request,uid,ps=20,pn=1,order= "desc",verify=null):
	if not verify:
		verify = util.Verify()
	if order!="desc" and order!="asc":
		push_error("不支持的排序方式")
	var api = API["user"]["info"]["followers"]

	var params = {
		"vmid": uid,
		"ps": ps,
		"pn": pn,
		"order": order
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_followers_g(http_request,uid,order =  "desc",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var data = get_followers_raw(http_request,uid,20,page,order,verify)
		if len(data["list"])==0:
			break
		for v in data["list"]:
			result_data.append(v)
		page +=1
	return result_data




func get_overview(http_request,uid,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["user"]["info"]["overview"]

	var params = {
		"mid": uid,
		"jsonp": "jsonp",
		"callback": "__jp8"
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func set_subscribe(http_request,uid,status=true, whisper=false,verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["modify"]

	var data = {
		"fid": uid,
		"act": 1 if status else 2,
		"re_src": 11,
		"csrf": verify.csrf
	}
	if status and whisper:
		data["act"] = 3
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp



func set_black(http_request,uid,status=true, verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["modify"]

	var data = {
		"fid": uid,
		"act": 5 if status else 6,
		"re_src": 11,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func remove_fans(http_request,uid, verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["modify"]

	var data = {
		"fid": uid,
		"act": 7,
		"re_src": 11,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func send_msg(http_request,uid,text,self_uid=null, verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["send_msg"]
	var sender_uid
	if not self_uid:
		var self_info = get_self_info(verify)
		sender_uid = self_info["mid"]
	else:
		sender_uid = self_uid

	var data = {
		"msg[sender_uid]": sender_uid,
		"msg[receiver_id]": uid,
		"msg[receiver_type]": 1,
		"msg[msg_type]": 1,
		"msg[msg_status]": 0,
		"msg[content]": to_json({"content": text}),
		"msg[dev_id]": "1369CA35-1771-4B80-B6D4-D7EB975B7F8A",
		"msg[new_face_version]": "0",
		"msg[timestamp]": int(OS.get_unix_time()),
		"csrf_token": verify.csrf,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp



func get_self_subscribe_group(http_request,verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])
	var api = API["user"]["info"]["self_subscribe_group"]
	var data = util.bilibili_get(http_request,api["url"], null, verify.get_cookies())
	return data


func get_user_in_which_subscribe_groups(http_request,uid,verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])
	var api = API["user"]["info"]["get_user_in_which_subscribe_groups"]
	var params = {
		"fid": uid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data


func add_subscribe_group(http_request,name, verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["add_subscribe_group"]

	var payload = {
		"tag": name,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),payload)
	return resp


func del_subscribe_group(http_request,group_id, verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["del_subscribe_group"]

	var payload = {
		"tagid": group_id,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),payload)
	return resp


func rename_subscribe_group(http_request,group_id,new_name, verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["rename_subscribe_group"]

	var payload = {
		"tagid": group_id,
		"name": new_name,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),payload)
	return resp


func move_user_subscribe_group(http_request,uid,group_ids, verify=null):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["user"]["operate"]["move_user_subscribe_group"]

	var tagids = "0"
	var group_ids_list=[]
	for i in group_ids:
		group_ids_list.append(str(i))

	if len(group_ids) != 0:
		tagids = group_ids_list.join(",")


	var payload = {
		"fids": uid,
		"tagids":tagids,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),payload)
	return resp