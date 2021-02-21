extends Reference
var util = load("util.gd").new()
var common = load("common.gd").new()
var API = util.get_api()

func get_bangumi_meta(http_request,media_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["bangumi"]["info"]["meta"]
	var params = {
		"media_id": media_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_short_comments_raw(http_request,media_id,ps=20,sort="default",cursor=null,verify=null):
	if not verify:
		verify = util.Verify()
	var ORDER_MAP = {
			"default": 0,
			"time": 1
		}
	if not (sort  in ORDER_MAP):
		push_error("不支持的排序方式。支持：default（默认排序）time（时间倒序）")

	var api = API["bangumi"]["info"]["short_comment"]
	var params = {
		"media_id": media_id,
		"ps": ps,
		"sort": ORDER_MAP[sort]
	}
	if cursor:
		params["cursor"] = cursor
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_short_comments_g(http_request,media_id,order="default",verify=null):
	if not verify:
		verify = util.Verify()
	var cursor = null
	var result_data = []
	while true:
		var resp = get_short_comments_raw(http_request,media_id,20,order,cursor,verify)
		if not resp["list"]:
			break
		if len(resp["list"])==0:
			break
		for v in resp["list"]:
			result_data.append(v)
		if not ("next" in resp):
			break
		cursor = resp["next"]
	return result_data



func get_long_comments_raw(http_request,media_id,ps=20,sort="default",cursor=null,verify=null):
	if not verify:
		verify = util.Verify()
	var ORDER_MAP = {
			"default": 0,
			"time": 1
		}
	if not (sort  in ORDER_MAP):
		push_error("不支持的排序方式。支持：default（默认排序）time（时间倒序）")

	var api = API["bangumi"]["info"]["long_comment"]
	var params = {
		"media_id": media_id,
		"ps": ps,
		"sort": ORDER_MAP[sort]
	}
	if cursor:
		params["cursor"] = cursor
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_long_comments_g(http_request,media_id,order="default",verify=null):
	if not verify:
		verify = util.Verify()
	var cursor = null
	var result_data = []
	while true:
		var resp = get_long_comments_raw(http_request,media_id,20,order,cursor,verify)
		if not resp["list"]:
			break
		if len(resp["list"])==0:
			break
		for v in resp["list"]:
			result_data.append(v)
		if not ("next" in resp):
			break
		cursor = resp["next"]
	return result_data

func get_episodes_list(http_request,season_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["bangumi"]["info"]["episodes_list"]
	var params = {
		"season_id": season_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_interact_data(http_request,season_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["bangumi"]["info"]["season_status"]
	var params = {
		"season_id": season_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_episode_info(http_request,epid,verify=null):
	if not verify:
		verify = util.Verify()
	var url = "https://www.bilibili.com/bangumi/play/ep%s"%epid
	var resp = util.bilibili_get(http_request,url,null,verify.get_cookies(),util.DEFAULT_HEADERS)
	if resp.status_code!=200:
		push_error(resp.status_code)
	var regex = RegEx.new()
	regex.compile("window.__INITIAL_STATE__=({.*?});")
	var regex_result = regex.search_all(resp.content.percent_encode())
	if not regex_result:
		push_error("未找到番剧信息")
	var content = regex_result.get_string().to_json()
	return content


func get_collective_info(http_request,season_id,verify=null):
	if not verify:
		verify = util.Verify()
	var api = API["bangumi"]["info"]["collective_info"]
	var params = {
		"season_id": season_id
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp



func set_follow(http_request,season_id,status=true,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["bangumi"]["operate"]["follow_del"]
	if status:
		api = API["bangumi"]["operate"]["follow_add"]
	var data = {
		"season_id": season_id,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func set_follow_status(http_request,season_id,status=2,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if not (status in [1,2,3]):
		push_error("不支持的追番状态。1想看2在看3已看")


	var api = API["bangumi"]["operate"]["follow_status"]
	var data = {
		"season_id": season_id,
		"csrf": verify.csrf,
		"status": status
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func share_to_dynamic(http_request,epid,content,verify=null):
	var resp = common.dynamic_share(http_request,"bangumi",epid,content,null,null,null,verify)
	return resp