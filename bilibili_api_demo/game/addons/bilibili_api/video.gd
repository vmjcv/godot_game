extends Reference
var util = load("util.gd").new()
var user = load("user.gd").new()
var common = load("common.gd").new()
var API = util.get_api()


func get_video_info(http_request,bvid=null,aid=null,is_simple=false,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")

	var api =API["video"]["info"]["info_detail"]
	if is_simple:
		api = API["video"]["info"]["info_simple"]

	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func get_tags(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")
	if not verify:
		verify = util.Verify()
	var api =API["video"]["info"]["tags"]
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_chargers(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")
	if not verify:
		verify = util.Verify()
	var api =API["video"]["info"]["charge"]
	var info = get_video_info(http_request,bvid,aid,false,verify)
	var mid =info["owner"]["mid"]
	var params = {
		"aid": aid,
		"mid": mid,
		"bvid": bvid
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp

func get_pages(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")
	if not verify:
		verify = util.Verify()
	var api = API["video"]["info"]["pages"]
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var get = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return get

func get_download_url(http_request,bvid=null,aid=null,page=0,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")
	if not verify:
		verify = util.Verify()

	var video_info = get_video_info(http_request, bvid,aid,false, verify)
	if page+1>len(video_info["pages"]):
		push_error("不存在该分P（page）")
	var url
	if bvid:
		url = "https://www.bilibili.com/video/%s" % bvid
	else:
		url = "https://www.bilibili.com/video/av%s" % aid
	var params = {
		"p": page+1
	}
	var req = util.bilibili_get(http_request,url, params, verify.get_cookies(),util.DEFAULT_HEADERS)
	var regex = RegEx.new()
	regex.compile("<script>window.__playinfo__=(.*?)</script>")
	var regex_result = regex.search_all(req.text)
	var text
	var data
	var playurl
	if regex_result:
		text = regex_result[0].get_string(1)
		data = parse_json(text)
		if data["code"] !=0:
			push_error("%s  %s"%[data['code'], data['messsage']])
		playurl = data['data']
	else:
		var page_id = video_info["pages"][page]["cid"]
		url = API["video"]["info"]["playurl"]["url"]
		params = {
			"bvid": bvid,
			"avid": aid,
			"qn": 120,
			"cid": page_id,
			"otype": 'json',
			"fnval": 16
		}
		playurl = util.bilibili_get(http_request,url, params, verify.get_cookies())
	return playurl