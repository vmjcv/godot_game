extends Reference
var util = load("util.gd").new()
var user = load("user.gd").new()
var API = util.get_api()

const COMMENT_TYPE_MAP = {
	"video": 1,
	"article": 12,
	"dynamic_draw": 11,
	"dynamic_text": 17,
	"audio": 14,
	"audio_list": 19
}
const COMMENT_SORT_MAP = {
	"like": 2,
	"time": 0
}


func send_comment(http_request,text,oid,type_,root=null,parent=null,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	type_ = COMMENT_TYPE_MAP.get(type_, null)

	if not type_:
		push_error("不支持的评论类型")

	var data = {
		"oid": oid,
		"type": type_,
		"message": text,
		"plat": 1,
		"csrf": verify.csrf
	}

	if parent and not root:
		data["root"]=oid
		data["parent"]=parent
	elif not parent and  root:
		data["root"]=root
		data["parent"]=root
	elif  parent and  root:
		data["root"]=root
		data["parent"]=parent

	var api = API["common"]["comment"]["send"]
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func operate_comment(http_request,action,oid,type_,rpid,status,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	type_ = COMMENT_TYPE_MAP.get(type_, null)

	if not type_:
		push_error("不支持的评论类型")


	var comment_api = API["common"]["comment"]
	var api = comment_api.get(action, null)
	if not api:
		push_error("不支持的评论操作方式")
	var data = {
		"oid": oid,
		"type": type_,
		"rpid": rpid,
		"csrf": verify.csrf
	}
	if action != "del":
		data["action"] = 1 if status else 0
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func get_comments_raw(http_request,oid,type_,order="time",pn=1, verify=null):
	if not verify:
		verify = util.Verify()
	type_=COMMENT_TYPE_MAP.get(type_,null)
	if not type_:
		push_error("不支持的评论类型")

	order=COMMENT_SORT_MAP.get(order,null)
	if not order:
		push_error("不支持的排序方式，支持：time（时间倒序），like（热度倒序）")

	var comment_api = API["common"]["comment"]
	var api = comment_api.get("get", null)
	var params = {
		"oid": oid,
		"type": type_,
		"sort": order,
		"pn": pn
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_comments(http_request,oid,type_,order="time",verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var resp = get_comments_raw(http_request,oid,type_,order,page,verify)
		if not resp["replies"]:
			break
		for v in resp["replies"]:
			result_data.append(v)
		page +=1
	return result_data


func get_sub_comments_raw(http_request,oid,type_,root,ps=100,pn=1, verify=null):
	if not verify:
		verify = util.Verify()
	type_=COMMENT_TYPE_MAP.get(type_,null)
	if not type_:
		push_error("不支持的评论类型")

	var comment_api = API["common"]["comment"]
	var api = comment_api.get("sub_reply", null)
	var params = {
		"oid": oid,
		"type": type_,
		"ps": ps,
		"pn": pn,
		"root": root
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp




func get_sub_comments(http_request,oid,type_,root,ps=10,verify=null):
	if not verify:
		verify = util.Verify()
	var page =1
	var result_data = []
	while true:
		var resp = get_sub_comments_raw(http_request,oid,type_,root,ps,page,verify)
		if not resp["replies"]:
			break
		for v in resp["replies"]:
			result_data.append(v)
		page +=1
	return result_data


func get_vote_info(http_request,vote_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["common"]["vote"]["info"]["get_info"]

	var params = {
		"vote_id": vote_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


const MEDIA_TYPE_MAP = {
	"audio": 12,
	"video": 2
}

func get_favorite_list_old(http_request,up_mid,rid,type_,ps=100,pn=1, verify=null):
	if not verify:
		verify = util.Verify()
	type_=MEDIA_TYPE_MAP.get(type_,null)
	if not type_:
		push_error("不支持的类型")

	var api = API["common"]["favorite"]["get_favorite_list_old"]

	var params = {
		"up_mid": up_mid,
		"type": type_,
		"pn": pn,
		"ps": ps,
		"rid": rid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func get_favorite_list(http_request,up_mid,rid,type_, verify=null):
	if not verify:
		verify = util.Verify()
	if rid:
		if not type_:
			push_error("请指定type_")
		type_=MEDIA_TYPE_MAP.get(type_,null)
		if not type_:
			push_error("不支持的类型")

	if not up_mid:
		var self_info = user.get_self_info(verify)
		up_mid  = self_info["mid"]

	var api = API["common"]["favorite"]["get_favorite_list"]

	var params = {
		"up_mid": up_mid
	}
	if rid:
		params["type"]=type_
		params["rid"]=rid

	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func operate_favorite(http_request,rid,type_, add_media_ids,del_media_ids,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if not add_media_ids:
		add_media_ids = []

	if not del_media_ids:
		del_media_ids = []

	if len(add_media_ids) ==0 and len(del_media_ids)==0:
		push_error("add_media_ids和del_media_ids至少提供一个")

	type_ = MEDIA_TYPE_MAP.get(type_, null)

	if not type_:
		push_error("不支持的类型")

	var api = API["common"]["favorite"]["operate_favorite"]
	var add_media_ids_list = []
	for i in add_media_ids:
		add_media_ids_list.append(str(i))

	var del_media_ids_list = []
	for i in del_media_ids:
		del_media_ids_list.append(str(i))
	var data = {
        "rid": rid,
        "type": type_,
        "add_media_ids": add_media_ids_list.join(","),
        "del_media_ids":  del_media_ids_list.join(","),
        "csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func dynamic_share(http_request,rid,type_, content,title,cover_url,target_url,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var TYPE_MAP = {
		"video": 8,
		"article": 64,
		"audio": 256,
		"custom": 2048,
		"bangumi": 4097
	}
	type_ = TYPE_MAP.get(type_, null)

	if not type_:
		push_error("不支持的分享类型")

	var api = API["common"]["dynamic_share"]

	var data = {
		"type": type_,
		"content": content,
		"rid": rid,
		"csrf": verify.csrf,
		"csrf_token": verify.csrf,
		"uid": 0,
		"share_uid": 0
	}

	if type_==TYPE_MAP["custom"]:
		if title and cover_url and target_url:
			push_error("自定义分享卡片需要传入完整参数")
		else:
			data["sketch[title]"] = title
			data["sketch[biz_type]"] = 131
			data["sketch[cover_url]"] = cover_url
			data["sketch[target_url]"] = target_url

	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func web_search(http_request,keyword):
	var api = API["common"]["search"]["web_search"]

	var params = {
		"keyword": keyword
	}
	var resp = util.bilibili_get(http_request,api["url"], params)
	return resp

func web_search_by_type(http_request,keyword,search_type):
	var api = API["common"]["search"]["web_search_by_type"]

	var params = {
		"keyword": keyword,
		"search_type": search_type
	}
	var resp = util.bilibili_get(http_request,api["url"], params)
	return resp
