extends Reference
var util = load("util.gd").new()
var common = load("common.gd").new()
var API = util.get_api()

func get_commonts_g(http_request,cv,order="time",verify=null):
	var replies = common.get_comments(http_request,cv,"article",order,verify)
	return replies

func get_sub_comments_g(http_request,cv,root,verify=null):
	return common.get_sub_comments(http_request,cv,"article",root,verify)


func send_comment(http_request,text,cv,root=null,parent=null,verify=null):
	var resp = common.send_comment(http_request,text,cv,"article",root,parent,verify)
	return resp


func set_like_comment(http_request,rpid,cv,status=true,verify=null):
	var resp = common.operate_comment(http_request,"like",cv,"article",rpid,status,verify)
	return resp


func set_hate_comment(http_request,rpid,cv,status=true,verify=null):
	var resp = common.operate_comment(http_request,"hate",cv,"article",rpid,status,verify)
	return resp


func set_top_comment(http_request,rpid,cv,status=true,verify=null):
	var resp = common.operate_comment(http_request,"top",cv,"article",rpid,status,verify)
	return resp


func del_comment(http_request,rpid,cv,verify=null):
	var resp = common.operate_comment(http_request,"del",cv,"article",rpid,verify)
	return resp


func get_info(http_request,cv,verify=null):
	if not verify:
		verify = util.Verify()

	var api = API["article"]["info"]["view"]

	var params = {
		"id": cv
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp


func set_like(http_request,cv,status,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api = API["article"]["operate"]["like"]

	var data = {
		"id": cv,
		"type": 1 if status else 2,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp



func set_favorite(http_request,cv,status=true,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var api =  API["article"]["info"]["del_favorite"]
	if status:
		api =  API["article"]["operate"]["add_favorite"]
	var data = {
		"id": cv
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp



func add_coins(http_request,cv,num=1,verify=null):
	if not verify:
		verify = util.Verify()
	if not verify.has_sess():
		push_error(util.MESSAGES["no_sess"])

	if not verify.has_csrf():
		push_error(util.MESSAGES["no_csrf"])
	var upid = get_info(http_request,cv)["mid"]
	var api =  API["article"]["operate"]["coin"]
	var data = {
		"aid": cv,
		"multiply": num,
		"upid": upid,
		"avtype": 2,
		"csrf": verify.csrf
	}
	var resp = util.bilibili_post(http_request,api["url"], verify.get_cookies(),data)
	return resp


func share_to_dynamic(http_request,cv,content,verify=null):
	var resp = common.dynamic_share(http_request,cv,"article",content,null,null,null,verify)
	return resp


func node_handle(node, prev):
	if not node:
		return
	if not node.children:
		# 文本节点
		prev.node_list.append(TextNode.new(str(node)))
		return

	var obj = null
	if node.name == "blockquote":
		# 引用
		obj = BlockquoteNode.new()
		prev.node_list.append(obj)
	elif node.name == "ul":
		# 无序列表
		obj = UlNode.new()
		prev.node_list.append(obj)
	elif node.name == "ol":
		# 有序列表
		obj = OlNode.new()
		prev.node_list.append(obj)
	elif node.name == "h1":
		# 标题
		obj = HeadNode.new(node.string)
		prev.node_list.append(obj)
	elif node.name == "strong":
		# 加粗
		obj = BoldNode.new()
		prev.node_list.append(obj)
	elif node.name == "a":
		# 链接
		var u = node["href"]
		obj = UrlNode.new(u)
		prev.node_list.append(obj)
	elif node.name == "h1":
		# 标题
		obj = HeadNode.new(node.string)
		prev.node_list.append(obj)
	elif node.name == "span":
		var style = node.get("style", [])
		if "text-decoration: line-through;" in style:
			# 删除线
			obj = DelNode.new()
			prev.node_list.append(obj)
		else:
			obj = prev
	elif node.name == 'pre':
		# 代码块
		var code = node['codecontent'].http_unescape()
		var lang = node['data-lang'].split('@')[0]
		obj = CodeNode.new(code, lang)
		prev.node_list.append(obj)

	elif node.name == "img":
		var cls = node.get("class", [])
		if "video-card" in cls:
			# 视频卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				var bvid = util.aid2bvid(int(aid))
				obj = VideoCardNode.new(bvid)
				prev.node_list.append(obj)
		elif "article-card" in cls:
			# 专栏卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = ArticleCardNode.new(aid)
				prev.node_list.append(obj)
		elif "fanju-card" in cls:
			# 番剧卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = BangumiCardNode.new(aid)
				prev.node_list.append(obj)
		elif "music-card" in cls:
			# 音乐卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = MusicCardNode.new(aid)
				prev.node_list.append(obj)
		elif "shop-card" in cls:
			# 会员购卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = ShopCardNode.new(aid)
				prev.node_list.append(obj)
		elif "live-card" in cls:
			# 直播卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = LiveCardNode.new(aid)
				prev.node_list.append(obj)
		elif "caricature-card" in cls:
			# 漫画卡片
			var aids = node["aid"].split(",")
			for aid in aids:
				obj = ComicCardNode.new(aid)
				prev.node_list.append(obj)
		elif "vote-display" in cls:
			# 投票卡片
			var vote_id = int(node["data-vote-id"])
			var info = common.get_vote_info(vote_id)["info"]
			obj = VoteNode.new(vote_id, info)
			prev.node_list.append(obj)
		elif "latex" in cls:
			# 公式
			var tex = node['alt'].http_unescape()
			obj = LatexNode.new(tex)
			prev.node_list.append(obj)
		else:
			if len(cls) > 0:
				if "cut-off" in cls[0]:
					# 分割线
					obj = SeparatorNode.new()
					prev.node_list.append(obj)
			else:
				# 图片
				var u = "https:" + node["data-src"]
				if node["data-src"].begins_with("http:") or node["data-src"].begins_with("https:"):
					u = node["data-src"]
				obj = ImageNode.new(u, node.next.string)
				prev.node_list.append(obj)
	elif node.name == "li":
		# 列表元素
		obj = LiNode.new()
		prev.node_list.append(obj)
	elif node.name == "p":
		obj = prev
	elif node.name in ["figcaption"]:
		# 忽略处理节点
		return
	else:
		# 其他节点
		obj = prev

	if obj:
		for child in node.children:
			# 处理子节点
			node_handle(child, obj)


func get_content(http_request,cid,preview=false,verify=null):
	# TODO: 需要考虑怎么兼容BeautifulSoup元素
	if not verify:
		verify = util.Verify()
	var meta ={}
	var body
	if not preview:
		var protocol = "http"
		if util.request_settings["use_https"]:
			protocol = "https"
		var url = "%s://www.bilibili.com/read/cv%s"%[protocol,cid]
		var resp = util.bilibili_get(http_request,url,null,verify.get_cookies(),util.DEFAULT_HEADERS)
		if "error" in resp.url:
			push_error("专栏不存在")
		var raw_content = resp.content.percent_encode()
		# var soup = BeautifulSoup(raw_content, "lxml")
		var soup
		body = soup.select_one(".article-holder")
		var ldjson_string =  soup.select_one("script[type='application/ld+json']").string.replace('\t', '  ')
		var ld_json = to_json(ldjson_string)
		var stat = get_info(http_request,cid)
		meta = {}
		meta["cid"] = cid
		meta["title"] = stat["title"]
		meta["head_image"] = stat["banner_url"]
		meta["author"] = {
			"name": stat["author_name"],
			"uid": stat["mid"]
		}
		meta["stats"] = stat["stats"]

		meta["fetch_time"] = "{year}-{month}-{day} {hour}:{minute}:{second}"%OS.get_datetime_from_unix_time(resp.headers.get("date"))
		meta["ctime"] = ld_json["pubDate"] if ld_json  else ""

		meta["tags"] = []
		var tags = soup.select(".tag-container .tag-content")
		for tag in tags:
			meta["tags"].append(tag.string)
	else:
		var url = "https://api.bilibili.com/x/article/creative/draft/view?aid=%s"%[cid]
		var stat = util.bilibili_get(http_request,url,null,verify.get_cookies(),util.DEFAULT_HEADERS)

		meta["cid"] = cid
		meta["title"] = stat["title"]
		meta["head_image"] = stat["banner_url"]
		meta["author"] = {
			"name": "测试用户",
			"uid": stat["author"]["mid"]
		}
		meta["stats"] = null
		meta["fetch_time"] = "None"
		meta["ctime"] = "未发布"

		meta["tags"] = stat["tags"]

		# body = BeautifulSoup(f"<div>{stat['content']}</div>", "lxml")

	var article = Article.new(meta)
	for p in body.children:
		var para = Paragraph.new()
		article.paragraphs.append(para)
		node_handle(p,para)
	return article



class Article:
	var meta
	var paragraphs
	func _init(_meta=null,_paragraphs=null):
		meta = {}
		paragraphs = []
		if _meta:
			meta = _meta
		if _paragraphs:
			paragraphs = _paragraphs


	func _to_string():
		var t = ""
		if len(self.meta["head_image"])>0:
			t += "![头图](%s)\n"%meta["head_image"]

		t+="# %s"%meta['title']
		t+="\n\n"
		t+="[原文链接](https://www.bilibili.com/read/cv%s)"%meta['cid']
		t+="\n\n"
		t+="作者：[%s](https://space.bilibili.com/%s)    发布时间：%s    抓取时间：%s"%[meta['author']['name'],meta['author']['uid'],meta['ctime'],meta['fetch_time']]
		t += "\n\n"
		t += "标签："
		t += meta['tags'].join(" ")
		t += "\n\n"
		t += "***\n"
		var cur_node_list = []
		for node in paragraphs:
			cur_node_list.append(str(node))
		t+=cur_node_list.join("\n\n")
		return t

	func save_as_markdown(http_request,path):
		var save_path = path+"/"+"cv%s"%self.meta['cid']
		var dir = Directory.new()
		if not dir.dir_exists(save_path):
			dir.make_dir(save_path)

		var urls = []
		var img_name
		for para in paragraphs:
			for node in para.node_list:
				if node is ImageNode:
					urls.append(node.url)
					img_name = node.url.split("/")[-1]
					node.url = "./"+img_name
		if len(meta["head_image"])>0:
			urls.append(meta["head_image"])
			img_name = meta["head_image"].split("/")[-1]
			meta["head_image"] = "./"+img_name

		_image_downloader_main(http_request,urls, save_path)
		var md = _to_string()
		var md_file = File.new()
		md_file.open(save_path+"cv%s.md"%self.meta['cid'], File.WRITE)
		md_file.store_string(md)

		var json_file = File.new()
		json_file.open(save_path+"meta.json", File.WRITE)
		json_file.store_string(to_json(meta))

	func _image_downloader_main(http_request,url, save_path):
		http_request.set_download_file(save_path+url.split("/")[-1])
		http_request.request(url)
		var request_ret = yield(http_request, "request_completed")
		return request_ret


class Paragraph:
	var align
	var node_list
	func _init(_align="left",_node_list=null):
		node_list = []
		if _node_list:
			node_list = _node_list
		align = _align

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var content =  node_list_str.join("")
		var t
		if align =="left":
			t = content
		else:
			t="<p style='text_align:%s'>%s</p>"%[align,content]
		return t

	func len():
		return len(node_list)



class AbstractNode:
	func _init():
		pass

class TextNode extends AbstractNode :
	var text
	func _init(_text):
		text = _text

	func _to_string():
		return text

	func len():
		return len(text)


class AbstractListNode extends AbstractNode :
	var node_list
	func _init(_node_list=null):
		node_list = []
		if _node_list:
			node_list = _node_list

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		return node_list_str.join("\n")

	func len():
		return len(node_list)


class StyleNode extends AbstractListNode :
	var style
	func _init(_style=null,_node_list=null).(_node_list):
		style = {}
		if _style:
			style = _style

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		var style_list_str = []
		var format_string = "{name}: {value}"
		for name in style:
			style_list_str.append(format_string.format({"name":name,"value":style[name]}))
		var _style = style_list_str.join(";")
		if len(_text)==0:
			return ""
		var node_name = "span"
		if "text_align" in style:
			node_name = "p"
		format_string = "<{node_name} style=\"{style}\">{text}</{node_name}>"
		return format_string.format({"node_name":node_name,"style":_style,"text":_text})


class HeadNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		if len(_text)==0:
			return ""
		return "##%s"%_text


class ItalicNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		if len(_text)==0:
			return ""
		return "*%s*"%_text


class BoldNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		if len(_text)==0:
			return " "

		var regex = RegEx.new()
		regex.compile("\\s+")
		var regex_result = regex.search_all(_text)
		if regex_result:
			return " "
		return " **%s**"%_text


class DelNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		if len(_text)==0:
			return ""
		return "~~%s~~"%_text


class BlockquoteNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(">"+str(node))
		var _text = node_list_str.join("\n")
		return _text


class UlNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append("- "+str(node))
		var _text = node_list_str.join("\n")
		return _text


class OlNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for i in range(len(node_list)):
			node_list_str.append(str(i+1)+". "+str(node_list[i]))
		var _text = node_list_str.join("\n")
		return _text


class LiNode extends AbstractListNode :
	func _init(_node_list=null).(_node_list):
		pass

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		return _text




class ImageNode extends AbstractNode :
	var url
	var alt
	func _init(_url,_alt):
		url=_url
		alt = ""
		if _alt:
			alt = _alt

	func _to_string():
		return "![%s](%s\"%s\""%[url,alt]


class LatexNode extends AbstractNode :
	var code
	func _init(_code):
		code = _code

	func _to_string():
		if("\n" in code):
			return "$$\n%s\n$$"%code
		else:
			return "$%s$"%code


class CodeNode extends AbstractNode :
	var code
	var lang
	func _init(_code,_lang=null):
		code = _code
		lang=_lang

	func _to_string():
		if lang:
			return "```%s\n%s\n```"%[lang,code]
		return "```''\n%s\n```"%[code]


class AbstractCardNode extends AbstractNode :
	var id
	func _init(_id):
		id = _id


class VideoCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://www.bilibili.com/%s>"%[id]


class ArticleCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://www.bilibili.com/read/cv%s>"%[id]


class BangumiCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://www.bilibili.com/bangumi/play/%s>"%[id]


class MusicCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://www.bilibili.com/audio/%s>"%[id]


class ShopCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://show.bilibili.com/platform/detail.html?id=%s>"%[id.substr(2)]


class ComicCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://manga.bilibili.com/m/detail/mc%s>"%[id]


class LiveCardNode extends AbstractCardNode :
	func _init(_id).(_id):
		pass

	func _to_string():
		return "<https://live.bilibili.com/%s>"%[id]


class VoteNode extends AbstractNode :
	var info
	var vote_id
	func _init(_vote_id,_info):
		info = _info
		vote_id = _vote_id

	func _to_string():
		var op_list_str = []
		for op in info["options"]:
			op_list_str.append("- "+str(op["desc"]))
		var _text = op_list_str.join("\n")


		var t =[
			"## 投票",
			"%s\n"%info["title"],
			"发起者： [%s](https://space.bilibili.com/%s)\n"%[info["name"],info["uid"]],
			"选项：",
			_text,
			"\n---"
		]
		return t.join("\n")

class UrlNode extends AbstractListNode :
	var url
	func _init(_url,_node_list=null).(_node_list):
		url = _url

	func _to_string():
		var node_list_str = []
		for node in node_list:
			node_list_str.append(str(node))
		var _text = node_list_str.join("")
		if len(_text) == 0:
			return "<%s>"%url
		return "[%s](%s)"%[_text,url]



class SeparatorNode extends AbstractNode :
	func _init():
		pass

	func _to_string():
		return "\n***\n"