--[[

http 通信接口

]]

-- 该接口是全局变量
HTTP = {}

local httpActions = requires(IMG_PATH,"GameLuaScript/Network/httpActions")--require("GameLuaScript/Network/httpActions")
local commonActions = requires(IMG_PATH,"GameLuaScript/Network/commonActions")--require("GameLuaScript/Network/commonActions")
local json = requires(IMG_PATH,"GameLuaScript/Network/dkjson")--require("GameLuaScript/Network/dkjson")
local KNLoading = requires(IMG_PATH,"GameLuaScript/Common/KNLoading")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local network = requires(IMG_PATH,"framework/client/network")

requires(IMG_PATH,"GameLuaScript/Data/Session")

--require("GameLuaScript/Data/Session")


--[[

发送数据, 并获得返回的数据

param 参数列表
	success_callback  function  成功回调
	error_callback  function  失败回调
	sync  boolean  是否异步，默认为true

]]
local M = {
	loading
}

function HTTP:call(mod , act , data , param)
	local this = {}
	setmetatable(this , self)
	self.__index = self


	local func = mod .. "_" .. act
	local success = false
	this.loading = nil


	-- 数据容错
	if type(param) ~= "table" then param = {} end
	if type(param.success_callback) ~= "function" then param.success_callback = function() end end
	if type(param.error_callback)   ~= "function" then
		param.error_callback = function(err)
			if err.code == -2 then
				KNMsg.getInstance():boxShow( err.msg ,{ 
					confirmText = COMMONPATH .. "vip_privilege.png" , 
					confirmFun = function() 
						HTTP:call("vip", "get", {} , {
							success_callback = function()
								switchScene("vip")
							end
						})
					end , 
					cancelFun = function() end 
				})
			else
				KNMsg.getInstance():flashShow("[" .. err.code .. "]" .. err.msg)	-- 弹出错误文字提示
			end
		end
	end
	if type(data) ~= "table" then data = {} end


	-- 判断 httpActions 里有没有该回调
	if type(httpActions[func]) ~= "function" then
		-- 错误处理
		echoInfo("no httpActions function [" .. func .. "]")
		return false
	end

	-- 发送数据前，执行 httpActions 回调
	success , data = httpActions[func](1 , data , param.error_callback)

	--[[错误处理]]
	if not success then
		param.error_callback( {code = "-996" , msg = "网络请求出错"} )
		return false
	end

	-- 拼装数据
	local request_data = {
		m = mod,
		a = act,
		_v = VERSION,
	}

	--[[非登录模块，添加登陆态参数]]
	if func ~= "verify_check" then
		request_data["sid"] = DATA_Session:get("sid")
		request_data["uid"] = DATA_Session:get("uid")
		request_data["server_id"] = DATA_Session:get("server_id")
	end

	for k , v in pairs(data) do
		request_data[k] = v
	end

	if CMD5 ~= nil then
		request_data["_sign"] = MD5(mod .. act .. (request_data["uid"] or 0) .. (request_data["sid"] or "") )
	end


	--[[显示遮罩层]]
	local scene = display.getRunningScene()

	if param.no_loading ~= nil then
		this.loading = KNMask:new({opacity = 0 , priority = -140})
	else
		this.loading = KNLoading:new()
	end
	scene:addChild( this.loading:getLayer() )



	--[[接收数据]]
	local function _callback(httpCode , response)
		--[[
		echoLog("HTTP" , "#####################")
		echoLog("HTTP" , "#####################")
		echoLog("HTTP" , "### " .. string.len(response))
		echoLog("HTTP" , "### " .. response)
		echoLog("HTTP" , "#####################")
		echoLog("HTTP" , "#####################")
		]]

		if not response or response == "" then
			if this.loading ~= nil then this.loading:remove() end 		-- 去掉 loading

			--[[错误处理]]
			param.error_callback( {code = "-999" , msg = "网络请求出错."} )
			return false
		end

		if string.sub(response , 0 , 1) ~= "{" then
			if this.loading ~= nil then this.loading:remove() end 		-- 去掉 loading

			param.error_callback( {code = httpCode , msg = response} )
			return false
		end

		

		--[[解包数据]]
--		io.writefile( "c:\\battle2.txt" , response )
		response = json.decode( response )

		if response == nil then
			if this.loading ~= nil then this.loading:remove() end 		-- 去掉 loading

			--[[错误处理]]
			param.error_callback( {code = "-998" , msg = "网络请求出错."} )
			return false
		end

		
		--[[处理 code 不为 0 的情况]]
		if response.code ~= 0 then
			if this.loading ~= nil then this.loading:remove() end 		-- 去掉 loading
			
			--[[错误处理]]
			param.error_callback( {code = response.code , msg = response.msg} )
			return false
		end


		if this.loading ~= nil then this.loading:remove() end 		-- 去掉 loading

		--[[接到数据后，执行 httpActions 回调]]
		commonActions.saveCommonData( response )
		success , response = httpActions[func](2 , response , param.success_callback)


		--[[错误处理]]
		if not success then


			param.error_callback( {code = "-996" , msg = "网络请求出错."} )
			return false
		end

		--[[执行回调]]
		-- param.success_callback(response)
	end



	-- 生成 URL-encode 之后的请求字符串
	local function http_build_query(data)
		if type(data) ~= "table" then return "" end

		local str = ""
		for k , v in pairs(data) do
			str = str .. k .. "=" .. string.urlencode(v) .. "&"
		end

		return str
	end

	-- 一次http请求
	local function sendRequest(url , postdata , callback , params)
		params = params or {}
		local timeout = params.timeout or 15

		echoLog("HTTP" , url .. "?" .. postdata)

		local request = network.createHTTPRequest(function(event)
			if event.name == "progress" then
				return
			end

			if event.name == "timeout" then
				CCLuaLog("===== error: timeout " .. timeout .. "s =====" )
				callback( -28 , "网络请求超时" )
				return
			end

			local request = event.request

			local error_code = request:getErrorCode()
			if error_code ~= 0 then
				local error_msg = request:getErrorMessage()
				echoLog("HTTP" , "===== error: " .. error_code .. " , msg: " .. error_msg .. " =====" )

				if string.find(error_msg , "resolve host name") ~= nil or string.find(error_msg , "connect to server") or string.find(error_msg , "Failed sending data") then
					error_msg = "网络异常，无法连接服务器"
				elseif string.find(error_msg , "Timeout") ~= nil then
					error_msg = "网络连接超时"
				end
				callback( error_code , error_msg )
				return
			end

			callback( request:getResponseStatusCode() , request:getResponseDataLua() )
		end , url , "POST")

		-- request:setAcceptEncoding(kCCHTTPRequestAcceptEncodingDeflate)
		request:setPOSTData(postdata)
		request:setTimeout(timeout)
		request:start()

--[[
		local http = HSHttpRequest:getInstance()
		http:SetUrl(url)
		http:SetRequestType(HTTP_MODE_POST)

		http:SetRequestData(postdata , string.len(postdata))
		http:SetTag("POST")

		-- 设置超时时间
		HSBaseHttp:GetInstance():SetTimeoutForConnect(5)
		HSBaseHttp:GetInstance():SetTimeoutForRead(10)

		-- 发送请求
		HSBaseHttp:GetInstance():Send(http);
		http:creadFuancuan(callback)

		http:release()
]]
	end



	-- 发送数据
	local url
	if param.requestUrl and param ~= "" then
		url = param.requestUrl
	elseif mod == "verify" and act == "check" and CONFIG_LOGIN_HOST ~= nil then
		url = CONFIG_LOGIN_HOST .. "/app.php"
	else
		url = CONFIG_HOST .. "/app.php"
	end
	sendRequest( url , http_build_query(request_data) , _callback , param)

	return this
end

function HTTP:showLoading()
	if self.loading then
		self.loading:remove()
		self.loading = nil
	end
	
	self.loading = KNLoading:new()

	local scene = display.getRunningScene()
	scene:addChild( self.loading:getLayer() )
end


return HTTP
