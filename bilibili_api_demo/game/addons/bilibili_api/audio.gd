extends Reference
var util = load("util.gd").new()
var user = load("user.gd").new()
var common = load("common.gd").new()
var API = util.get_api()

func get_info(http_request,auid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["audio_info"]["info"]
	var params = {
		"sid": auid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_tags(http_request,auid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["audio_info"]["tag"]
	var params = {
		"sid": auid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_user_info(http_request,uid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["audio_info"]["user"]
	var params = {
		"uid": uid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_download_url(http_request,auid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["audio_info"]["download_url"]
	var params = {
		"sid": auid,
		"privilege": 2,
		"quality": 2
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_favorite_list(http_request,auid,verify=null):
	var resp = common.get_favorite_list(http_request,auid, verify)
	return resp



func add_coins(http_request,auid=null,num=2,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if num!=1 and num!=2:
		push_error("投币数量只能是1个或2个")

	var api =API["audio"]["audio_operate"]["coin"]
	var data = {
		"sid": auid,
		"multiply": num,
		"csrf": verify.csrf
	}
	var self_info = user.get_self_info(verify)
	var cookies = verify.get_cookies()
	cookies["DedeUserID"] = str(self_info["mid"])
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func operate_favorite(http_request,auid,add_media_ids=null,del_media_ids = null,verify=null):
	var resp = common.operate_favorite(http_request,auid,"audio",add_media_ids,del_media_ids, verify)
	return resp


func get_comments_g(http_request,auid,order="time",verify=null):
	var resp = common.get_comments(http_request,auid,"audio",order, verify)
	return resp

func get_sub_comments_g(http_request,auid,root,verify=null):
	var resp = common.get_sub_comments(http_request,auid,"audio",root, verify)
	return resp


func send_comment(http_request,text,auid,root=null,parent=null,verify=null):
	var resp = common.send_comment(http_request,text,auid,"audio",root,parent, verify)
	return resp


func set_like_comment(http_request,rpid,auid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"like", auid, "audio", rpid, status, verify)
	return resp


func set_hate_comment(http_request,rpid,auid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"hate", auid, "audio", rpid, status, verify)
	return resp


func set_top_comment(http_request,rpid,auid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"top", auid, "audio", rpid, status, verify)
	return resp


func del_comment(http_request,rpid,auid,verify=null):
	var resp = common.operate_comment(http_request,"del", auid, "audio", rpid, verify)
	return resp


func list_get_comments_g(http_request,amid,order="time",verify=null):
	var replies = common.get_comments(http_request,amid, "audio_list", "audio", order, verify)
	return replies


func list_get_sub_comments_g(http_request,amid,root,verify=null):
	var replies = common.get_sub_comments(http_request,amid, "audio_list",root, verify)
	return replies


func list_send_comment(http_request,text,amid,root=null,parent=null,verify=null):
	var resp = common.send_comment(http_request,text,amid, "audio_list",root,parent, verify)
	return resp

func list_set_like_comment(http_request,rpid,amid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"like",amid, "audio_list",rpid,status, verify)
	return resp

func list_set_hate_comment(http_request,rpid,amid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"hate",amid, "audio_list",rpid,status, verify)
	return resp

func list_set_top_comment(http_request,rpid,amid,status=true,verify=null):
	var resp = common.operate_comment(http_request,"top",amid, "audio_list",rpid,status, verify)
	return resp

func list_del_comment(http_request,rpid,amid,verify=null):
	var resp = common.operate_comment(http_request,"del",amid, "audio_list",rpid, verify)
	return resp

func list_get_info(http_request,amid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["list_info"]["info"]
	var params = {
		"sid": amid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func list_get_tags(http_request,amid=null,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["list_info"]["tag"]
	var params = {
		"sid": amid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func list_get_song_list_raw(http_request,amid=null,pn=1,ps=100,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["audio"]["list_info"]["song_list"]
	var params = {
		"sid": amid,
		"pn": pn,
		"ps": ps
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func list_get_song_list_g(http_request,amid=null,verify=null):
	var page =1
	var result_data = []
	while true:
		var data = list_get_song_list_raw(http_request,amid,page,100,verify)
		if not data:
			break
		for v in data["data"]:
			result_data.append(v)
		page +=1
	return result_data



func list_set_favorite(http_request,amid=null,status=true,verify=null):
	if not verify:
		push_error("请提供verify")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var self_info = user.get_self_info(verify)
	var cookies = verify.get_cookies()
	cookies["DedeUserID"] = str(self_info["mid"])
	var resp
	if status:
		var api = API["audio"]["list_operate"]["set_favorite"]
		var data = {
			"sid": amid,
			"csrf": verify.csrf
		}
		resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	else:
		var api = API["audio"]["list_operate"]["del_favorite"]
		var data = {
			"csrf": verify.csrf
		}
		var params = {
			"sid": amid
		}
		resp = util.bilibili_delete(http_request,api["url"], params,data,verify.get_cookies())
	return resp

func list_share_to_dynamic(http_request,amid,content,verify):
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])
	var info = list_get_info(amid,verify)
	var resp = common.dynamic_share(http_request,amid,"custom",content,info["title"],info["cover"],"https://www.bilibili.com/audio/am%s"%amid,verify)
	return resp