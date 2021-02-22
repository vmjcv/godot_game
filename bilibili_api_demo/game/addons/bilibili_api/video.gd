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


func get_related(http_request,bvid,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()


	var api = API["video"]["info"]["related"]
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var data = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return data

func get_added_coins(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api = API["video"]["info"]["is_coins"]
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var get = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	var value = get["multiply"]
	return value

func get_favorite_list(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not aid:
		aid = util.bvid2aid(bvid)

	var resp = common.get_favorite_list(http_request,null,aid,"video",verify)
	return resp


func is_liked(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api = API["video"]["info"]["is_liked"]
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var get = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	if get==1:
		return true
	else:
		return false

func is_favoured(http_request,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api = API["video"]["info"]["is_favoured"]
	if not aid:
		aid = util.bvid2aid(bvid)
	var params = {
		"aid": aid,
		"bvid": bvid
	}
	var get = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	var value = get["favoured"]
	return value

func set_like(http_request,status=true, bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var api = API["video"]["operate"]["like"]

	var data = {
		"aid": aid,
		"like": 0,
		"csrf": verify.csrf,
		"bvid": bvid
	}
	if status:
		data["like"] = 1
	else:
		data["like"] = 2
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func add_coins(http_request,num=1, like=true,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if num !=1 and num!=2:
		push_error("硬币必须是1个或2个")

	var api = API["video"]["operate"]["coin"]

	var data = {
		"aid": aid,
		"multiply": num,
		"select_like": 1 if like else 0,
		"csrf": verify.csrf,
		"bvid": bvid
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func operate_favorite(http_request,bvid=null,aid=null,add_media_ids=null,del_media_ids=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.operate_favorite(http_request,aid,"video", add_media_ids, del_media_ids, verify)
	return resp

func get_danmaku_view(http_request,page_id,bvid=null,aid=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if not aid:
		aid = util.bvid2aid(bvid)

	var api = API["video"]["danmaku"]["view"]['url']
	var params = {
		"type": 1,
		"oid": page_id,
		"pid": aid
	}
	var resp = util.bilibili_get(http_request,api,params,verify.get_cookies(),util.DEFAULT_HEADERS)
	var resp_data = resp.content
	var json_data = {}
	var pos = 0
	var length = len(resp_data)
	var data
	var d
	var l
	var str_len
	var type_
	while pos<length:
		type_ = resp_data[pos]>>3
		pos += 1
		if type_ == 1:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			d = data[0]
			l = data[1]
			json_data['state'] = int(d)
			pos += l
		elif type_==2:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			str_len = data[0]
			l = data[1]
			pos += l
			json_data['text'] = resp_data.slice(pos,pos+str_len).percent_decode()
			pos += str_len
		elif type_==3:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			str_len = data[0]
			l = data[1]
			pos += l
			json_data['textSide'] = resp_data.slice(pos,pos+str_len).percent_decode()
			pos += str_len
		elif type_==4:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			json_data['dmSge'] = read_dmSge(resp_data.slice(pos,pos+data_len))
			pos += data_len
		elif type_==5:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			json_data['flag'] = read_flag(resp_data.slice(pos,pos+data_len))
			pos += data_len
		elif type_==6:
			if not ( 'specialDms'  in json_data):
				json_data['specialDms'] = []
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			json_data['specialDms'].append(resp_data.slice(pos,pos+data_len))
			pos += data_len
		elif type_==7:
			json_data['checkBox'] = false
			if resp_data[pos] == '0x01':
				json_data['checkBox'] = true
			pos += l
		elif type_==8:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			json_data['count'] = int(d)
		elif type_== 9:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			if not ( 'commandDms'  in json_data):
				json_data['commandDms'] = []

			json_data['commandDms'].append(read_commandDms(resp_data.slice(pos,pos+data_len)))
			pos += data_len
		elif type_==9:
			data = util.read_varint(resp_data.slice(pos,len(resp_data)))
			data_len = data[0]
			l = data[1]
			pos += l
			json_data['dmSetting'] = read_dmSetting(resp_data.slice(pos,pos+data_len))
			pos += data_len
		else:
			continue
	return json_data

func read_dmSge(stream):
	var length_ = len(stream)
	var pos =0
	var data = {}
	var read_varint_data
	var d
	var l
	while pos<length_:
		var t = stream[pos]>>3
		pos +=1
		if t==1:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["pageSize"]=int(d)
			pos += l
		elif t==2:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["total"]=int(d)
			pos += l
		else:
			continue
	return data

func read_flag(stream):
	var length_ = len(stream)
	var pos =0
	var data = {}
	var read_varint_data
	var d
	var l
	var str_len
	while pos<length_:
		var t = stream[pos]>>3
		pos +=1
		if t==1:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["recFlag"]=int(d)
			pos += l
		elif t==2:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos+=l
			data["recText"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos += str_len
		elif t==3:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["recSwitch"]=int(d)
			pos +=l
		else:
			continue
	return data

func read_commandDms(stream):
	var length_ = len(stream)
	var pos =0
	var data = {}
	var read_varint_data
	var d
	var l
	var str_len
	while pos<length_:
		var t = stream[pos]>>3
		pos +=1
		if t==1:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["id"]=int(d)
			pos += l
		elif t==2:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data['oid'] = int(d)
			pos+=l
		elif t==3:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data['mid'] = int(d)
			pos+=l
		elif t==4:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["commend"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		elif t==5:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["content"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		elif t==6:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data["progress"]=int(d)
			pos+=l
		elif t==7:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["ctime"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		elif t==8:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["mtime"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		elif t==9:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["extra"]=to_json(resp_data.slice(pos,pos+str_len).percent_decode())
			pos+=str_len
		elif t==10:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["idStr"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		else:
			continue
	return data


func read_dmSetting(stream):
	var length_ = len(stream)
	var pos =0
	var data = {}
	var read_varint_data
	var d
	var l
	var str_len
	while pos<length_:
		var t = stream[pos]>>3
		pos +=1
		if t==1:
			data['dmSwitch'] = false
			if stream[pos] == '1':
				data['dmSwitch'] = true
			pos += 1
		elif t==2:
			data['aiSwitch'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==3:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data['aiLevel'] = int(d)
			pos+= l

		elif t==4:
			data['blocktop'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==5:
			data['blockscroll'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==6:
			data['blockbottom'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==7:
			data['blockcolor'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==8:
			data['blockspecial'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==9:
			data['preventshade'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==10:
			data['dmask'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==11:
			d = stream.slice(pos,pos+4)[0]
			pos+=4
			data["opacity"]=d
		elif t==12:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data['dmarea'] = int(d)
			pos+= l
		elif t==13:
			d = stream.slice(pos,pos+4)[0]
			pos+=4
			data["speedplus"]=d
		elif t==14:
			d = stream.slice(pos,pos+4)[0]
			pos+=4
			data["fontsize"]=d
		elif t==15:
			data['screensync'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==16:
			data['speedsync'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==17:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["fontfamily"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		elif t==18:
			data['bold'] = true if stream[pos] == '1' else false
			pos += 1
		elif t==19:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			d = read_varint_data[0]
			l = read_varint_data[1]
			data['fontborder'] = int(d)
			pos+= l
		elif t==20:
			read_varint_data = util.read_varint(stream.slice(pos,len(stream)))
			str_len = read_varint_data[0]
			l = read_varint_data[1]
			pos += l
			data["drawType"]=resp_data.slice(pos,pos+str_len).percent_decode()
			pos+=str_len
		else:
			continue
	return data

func get_danmaku(http_request,bvid,aid,page_id=0,date=null,verify=null):
	var dms = []
	g = get_danmaku_g(http_request,bvid,aid,page_id,date,verify)
	for d in g:
		dms.append(d)
	return dms

func get_danmaku_g(http_request,bvid,aid,page_id=0,date=null,verify=null):
	if not (aid or bvid):
		push_error("no aid or bvid")

	if not verify:
		verify = util.Verify()

	if date:
		if not  verify.has_sess():
			push_error(util.MESSAGES["no_sess"])

	if not aid:
		aid = util.bvid2aid(bvid)

	var api = API["video"]["danmaku"]["get_danmaku"]
	var params = {
		"oid": page_id,
		"type": 1,
		"segment_index": 1,
		"pid": aid
	}
	if date:
		params["type"] = 1
		params["date"] =  "{year}-{month}-{day}"%OS.get_datetime_from_unix_time(date)

	var view = get_danmaku_view(http_request,page_id,null,aid)
	var sge_count = view['dmSge']['total']
	var danmakus = []
	for i in range(sge_count):
		params['segment_index'] = i + 1
		var resp = util.bilibili_get(http_request,api,params,verify.get_cookies(),util.DEFAULT_HEADERS)
		var content_type = req.headers['content-type']
		var con
		var data
		if content_type=="application/json":
			con = to_json(req)
			if con["code"]!=0:
				push_error("%s,%s"%[con['code'],con['message']])
			else:
				return con
		elif content_type=="application/octet-stream":
			con = req.content
			data = con
			var offset = 0
			if data = "1001":
				push_error("%s视频弹幕已关闭"%bvid)
			var dm_result = []
			while offset<len(data):
				if data[offset] == 0x0a:
					dm = util.Danmaku("")
					offset +=1

					var read_varint_data = util.read_varint(data.slice(pos,len(stream)))
					dm_data_length = read_varint_data[0]
					l = read_varint_data[1]
					offset += l
					var real_data = data.slice(offset,offset+dm_data_length)
					var dm_data_offset = 0
					var read_varint_data
					var d
					var l
					var str_len
					while dm_data_offset< dm_data_length:
						var data_type = real_data[dm_data_offset]>>3
						dm_data_offset+=1
						if data_type ==1:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.id = d
						elif data_type ==2:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							# TODO:有问题
							dm.dm_time = OS.get_unix_time()
						elif data_type ==3:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.mode = d
						elif data_type ==4:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.font_size = d
						elif data_type ==5:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.color = util.BilibiliColor.new()
							dm.color.set_dec_color(d)
						elif data_type ==6:
							str_len = real_data[dm_data_offset]
							dm_data_offset += 1
							d = real_data.slice(dm_data_offset,dm_data_offset + str_len)
							dm_data_offset+=str_len
							dm.crc32_id =  d.percent_decode()
						elif data_type ==7:
							str_len = real_data[dm_data_offset]
							dm_data_offset += 1
							d = real_data.slice(dm_data_offset,dm_data_offset + str_len)
							dm_data_offset+=str_len
							dm.text =  d.percent_decode()
						elif data_type ==8:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.send_time = os.get_datetime_from_unix_time(d)
						elif data_type ==9:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.weight = d
						elif data_type ==10:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.action = d
						elif data_type ==11:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.pool = d
						elif data_type ==12:
							str_len = real_data[dm_data_offset]
							dm_data_offset += 1
							d = real_data.slice(dm_data_offset,dm_data_offset + str_len)
							dm_data_offset+=str_len
							dm.id_str =  d.percent_decode()
						elif data_type ==13:
							read_varint_data = util.read_varint(real_data.slice(dm_data_offset,len(real_data)))
							d = read_varint_data[0]
							l = read_varint_data[1]
							dm_data_offset += l
							dm.attr = d
						else:
							break
					offset +=dm_data_length
					dm_result.append(dm)
			return dm_result

func get_history_danmaku_index(http_request,bvid=null,aid=null,page=0,data=null,verify=null):
	if not (aid or bvid):
		push_error("NoIdException")
	if not verify:
		verify = util.Verify()
	if not date:
		date = OS.get_datetime_from_unix_time(OS.get_unix_time())
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var info = get_video_info(http_request,bvid,aid,false,verify)
	var page_id = info["pages"][page]["cid"]
	var api =API["video"]["danmaku"]["get_history_danmaku_index"]
	var params = {
		"oid": page_id,
		"month": "{year}-{month}"%date,
		"type": 1
	}
	var get = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return get

func like_danmaku(http_request,dmid,oid,is_like=true,verify=null):
	if not verify:
		verify = util.Verify()

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API['video']['danmaku']['like_danmaku']
	var payload = {
		"dmid": dmid,
		"oid": oid,
		"op": 1 if is_like else 2,
		"platform": "web_player",
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func has_liked_danmaku(http_request,dmid,oid,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	var api =API['video']['danmaku']['has_liked_danmaku']

	var ids = dmid
	var cur_ids = []
	if not(dmid is int):
		if dmid is list:
			for i in dmid:
				cur_ids.append(str(i))
			ids = cur_ids.join(",")
		else:
			ids = null

	var params = {
		"ids": ids,
		"oid": oid,
	}
	if not params["ids"]:
		push_error("参数错误")
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func send_danmaku(http_request,danmaku,page=0,bvid=null,aid=null,verify=null):
	if not verify:
		verify = util.Verify()

	if not(aid or bvid):
		push_error("NoIdException")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	var page_info = get_pages(http_request,bvid,aid,verify)
	var oid = page_info[page]["cid"]
	var api = API["video"]["danmaku"]["send_danmaku"]
	if danmaku.is_sub:
		pool = 1
	else:
		pool = 0

	var data = {
		"type": 1,
		"oid": oid,
		"msg": danmaku.text,
		"aid": aid,
		"bvid": bvid,
		"progress": int(danmaku.dm_time.seconds * 1000),
		"color": danmaku.color.get_dec_color(),
		"fontsize": danmaku.font_size,
		"pool": pool,
		"mode": danmaku.mode,
		"plat": 1,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func get_comments_g(http_request,bvid = null,aid=null,order="time",verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var replies = common.get_comments(http_request,aid,"video",order,verify)
	return replies


func get_comments_g(http_request,root,bvid = null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var replies = common.get_sub_comments(http_request,aid,"video",root,verify)
	return replies

func send_comment(http_request,text,root = null,parent=null,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.send_comment(http_request,text,aid,"video", root, parent,verify)
	return resp


func set_like_comment(http_request,rpid,status = true,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.operate_comment(http_request,"like",aid,"video", rpid, status,verify)
	return resp

func set_hate_comment(http_request,rpid,status = true,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.operate_comment(http_request,"hate",aid,"video", rpid, status,verify)
	return resp

func set_top_comment(http_request,rpid,status = true,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.operate_comment(http_request,"top",aid,"video", rpid, status,verify)
	return resp


func del_comment(http_request,rpid,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")
	if not aid:
		aid = util.bvid2aid(bvid)
	var resp = common.operate_comment(http_request,"del",aid,"video", rpid,verify)
	return resp

func add_tag(http_request,tag_name,bvid=null,aid=null,verify=null):
	if not verify:
		verify = util.Verify()

	if not(aid or bvid):
		push_error("NoIdException")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if not aid:
		aid = util.bvid2aid(bvid)


	var api =  API["video"]["operate"]["add_tag"]
	var data = {
		"aid": aid,
		"tag_name": tag_name,
		"csrf": verify.csrf,
		"bvid": bvid
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func del_tag(http_request,tag_id,bvid=null,aid=null,verify=null):
	if not verify:
		verify = util.Verify()

	if not(aid or bvid):
		push_error("NoIdException")

	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])

	if not aid:
		aid = util.bvid2aid(bvid)


	var api =  API["video"]["operate"]["del_tag"]
	var data = {
		"aid": aid,
		"tag_id": tag_id,
		"csrf": verify.csrf,
		"bvid": bvid
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp

func share_to_dynamic(http_request,content,bvid=null,aid=null,verify=null):
	if not(aid or bvid):
		push_error("NoIdException")

	if not aid:
		aid = util.bvid2aid(bvid)

	var resp = common.dynamic_share(http_request,"video",aid,content,null,null,null,verify)
	return resp


# TODO:video_upload后的几个函数，不太想写了，主要是视频上传的内容
