extends Reference
var util = load("util.gd").new()

var API = util.get_api()

func get_channel_info_by_tid(tid):
	var file = File.new()
	file.open(util.get_project_path()+"data/channel.json", file.READ)
	var data = file.get_as_text()
	var channel = JSON.parse(data)
	file.close()
	for main_ch in channel:
		if not ("tid" in main_ch):
			continue
		if tid == int(main_ch["tid"]):
			return [main_ch,null]
		for sub_ch in main_ch["sub"]:
			if tid == sub_ch["tid"]:
				return [main_ch,sub_ch]
	return [null,null]

func get_channel_info_by_name(name):
	var file = File.new()
	file.open(util.get_project_path()+"data/channel.json", file.READ)
	var data = file.get_as_text()
	var channel = JSON.parse(data)
	file.close()
	for main_ch in channel:
		if name in main_ch["name"]:
			return [main_ch,null]
		for sub_ch in main_ch["sub"]:
			if name in sub_ch["name"]:
				return [main_ch,sub_ch]
	return [null,null]


func get_top10(http_request,tid,day=7,verify=null):
	if not verify:
		verify = util.Verify()
	if not (day in [3,7]):
		push_error("day只能是3，7")

	var api = API["channel"]["ranking"]["get_top10"]
	var params = {
		"rid": tid,
		"day": day
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp
