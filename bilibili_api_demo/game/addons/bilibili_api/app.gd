extends Reference
var util = load("util.gd").new()
var API = util.get_api()
func get_loading_images(http_request,mobi_app="android", platform="android",height= 1920, width = 1080,build = 999999999, birth = "",verify = null):
	if not verify:
		verify = util.Verify()
	
	var api = API["app"]["splash"]["list"]
	var params = {
		"build": build,
		"mobi_app": mobi_app,
		"platform": platform,
		"height": height,
		"width": width,
		"birth": birth
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp



func get_loading_images_special(http_request,mobi_app = "android", platform = "android",height = 1920, width = 1080,ts = int(OS.get_unix_time()),appkey = "1d8b6e7d45233436",appsec = "560c52ccd288fed045859ed18bffd973",verify = null):
	if not verify:
		verify = util.Verify()

	var api = API["app"]["splash"]["brand"]
	var sign_params = "appkey="+appkey+"&mobi_app="+mobi_app+"&platform="+platform+"&screen_height="+str(height)+"&screen_width="+str(width)+"&ts="+str(ts)+appsec
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(sign_params.percent_encode())
	var res = ctx.finish()
	var hex_sign = res.hex_encode()
	var params = {
		"appkey": appkey,
		"mobi_app": mobi_app,
		"platform": platform,
		"screen_height": height,
		"screen_width": width,
		"ts": ts,
		"sign": hex_sign
	}
	var resp = util.bilibili_get(http_request,api["url"], params, verify.get_cookies())
	return resp
