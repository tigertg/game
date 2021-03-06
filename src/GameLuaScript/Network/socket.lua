--[[

socket 通信接口

]]

-- 该接口是全局变量
SOCKET = {}

local socketActions = requires(IMG_PATH , "GameLuaScript/Network/socketActions")--require("GameLuaScript/Network/socketActions")
local commonActions = requires(IMG_PATH , "GameLuaScript/Network/commonActions")--require("GameLuaScript/Network/commonActions")
local json = requires(IMG_PATH , "GameLuaScript/Network/dkjson")-- require("GameLuaScript/Network/dkjson")
local KNLoading = requires(IMG_PATH , "GameLuaScript/Common/KNLoading")--require("GameLuaScript/Common/KNLoading")


local sockets = {}

--[[

获取一个实例 ( 单例模式 )

]]
function SOCKET.getInstance( self , socket_type )
	if sockets[socket_type] == nil then
		sockets[socket_type] = self.new( socket_type )
	end

	return sockets[socket_type]
end

function SOCKET.delInstance( self , socket_type )
	if sockets[socket_type] ~= nil then
		sockets[socket_type] = nil
	end
end

--[[

打开一个新的 socket

]]
function SOCKET.new( socket_type , host , port )
	local socket = {}

	host = host or CONFIG_SOCKET_HOST
	port = port or CONFIG_SOCKET_PORT

	-- 打开一个新链接
	local has_login = false

	socket = LuaSocket:getInstance()
	local opensocket_ret = socket:openSocket( host , port )


	-- 错误处理
	-- todo ....
	if not socket then

	end

	-- 回调队列
	local callbacks_table = {}

	local loading = nil


	--[[

	发送数据, 并获得返回的数据

	param 参数列表
		success_callback  function  成功回调
		error_callback  function  失败回调
		sync  boolean  是否异步，默认为true

	]]

	function socket:call(mod , act , command , data , param)
		if opensocket_ret < 0 then
			SOCKET:delInstance(socket_type)
			KNMsg.getInstance():flashShow("网络出现异常，你可能已经断网了")
			return
		end

		-- 判断是否第一次连服务器
		if not has_login and command ~= "login" then
			print("socket relogin -------------")

			-- 尝试连接长连接服务器
			SOCKET:getInstance(socket_type):call("log" , "in" , "login" , {} , {
				success_callback = function()
					has_login = true
					-- 连接成功后，再回调
					SOCKET:getInstance(socket_type):call(mod , act , command , data , param)
				end
			})

			return
		end



		local func = mod .. "_" .. act
		local success = false

		-- 数据容错
		if type(param) ~= "table" then param = {} end
		--是否存在回调 成功 函数
		if type(param.success_callback) ~= "function" then param.success_callback = function() end end
		--是否存在回调 错误 函数
		if type(param.error_callback)   ~= "function" then
			param.error_callback = function(err)
				KNMsg.getInstance():flashShow("[" .. err.code .. "]" .. err.msg)	-- 弹出错误文字提示
			end
		end
		if type(param.break_callback) ~= "function" then param.break_callback = function() end end
		if type(data) ~= "table" then data = {} end


		-- 判断 socketActions 里有没有该回调
		if type(socketActions[func]) ~= "function" then
			-- 错误处理
			echoInfo("no socketActions function [" .. func .. "]")
			return false
		end

		-- 发送数据前，执行 socketActions 回调
		success , data = socketActions[func](1 , data , param.error_callback)

		-- 错误处理
		if not success then
			param.error_callback( {code = "-1996" , msg = "网络请求出错."} )
			return false
		end

		-- 拼装数据
		local request_data = {
			m = mod,
			a = act,
			command = command,
			_v = VERSION,
			sid = DATA_Session:get("sid"),
			uid = DATA_Session:get("uid"),
			server_id = DATA_Session:get("server_id"),
			data = data,
		}

		if CMD5 ~= nil then
			request_data["_sign"] = MD5(mod .. act .. (DATA_Session:get("uid") or 0) .. (DATA_Session:get("sid") or "") )
		end


		-- 显示遮罩层
		loading = nil
		if param.no_mask == nil then
			local scene = display.getRunningScene()
			-- loading = KNLoading.new()
			if param.no_loading ~= nil then
				loading = KNMask:new({opacity = 0 , priority = -140})
			else
				loading = KNLoading:new()
			end
			scene:addChild( loading:getLayer() )
		end



		--[[
		local function _callback()
		end
		]]

		-- 客户端主动发送数据的用自定义的回调函数接数据
		callbacks_table[func] = function(code , response)
			callbacks_table[func] = nil

			--返回数据中不包含response
			if not response or response == "" then
				if loading ~= nil then loading:remove() end 		-- 去掉 loading

				-- 关闭链接
				-- socket:close(socket_type)

				-- 错误处理
				param.error_callback( {code = "-1999" , msg = "网络请求出错."} )
				return false
			end


			-- 解包数据
--			if func == "mission_execute" then
--				 io.writefile( "c:\\battle2.txt" , response )
--				 response = io.readfile("c:\\battle2.txt")
--			end
			response = json.decode( response )
			if response == nil then
				if loading ~= nil then loading:remove() end 		-- 去掉 loading

				param.error_callback( {code = "-1998" , msg = "网络请求出错."} )
				return false
			end


			--[[处理 code 不为 0 的情况]]
			if response.code ~= 0 then
				if loading ~= nil then loading:remove() end 		-- 去掉 loading

				--[[错误处理]]
				param.error_callback( {code = response.code , msg = response.msg} )
				return false
			end


			-- 接到数据后，执行 socketActions 回调
			commonActions.saveCommonData( response )
			success , response = socketActions[func](2 , response , param.success_callback)


			-- 错误处理
			if not success then
				if loading ~= nil then loading:remove() end 		-- 去掉 loading

				param.error_callback( {code = "-1996" , msg = "网络请求出错."} )
				return false
			end

			if loading ~= nil then loading:remove() end 		-- 去掉 loading
			
			if command == "login" then
				has_login = true
			end

			-- 执行回调
			param.success_callback(response)
		end


		-- 一次http请求
		local function sendRequest(postdata , callback)
			echoLog("SOCKET" , postdata)

			-- socket:creadFuancuan(callback)
			socket:sendSocket( postdata .. "\n" )
		end


		-- 发送数据
		sendRequest( json.encode(request_data))


		return true
	end

	--[[

	关闭 socket 链接

	]]
	function socket:close()
		-- 关闭链接
		socket:closeSocket()

		-- 删除变量
		socket = nil
		sockets[socket_type] = nil
	end






	--[[统一回调]]
	local function _callback(code , response)
		if code < 0 then
			echoLog("SOCKET" , "Bad Code : " .. code)
			if loading ~= nil then loading:remove() end 		-- 去掉 loading

			if code == -100 or code == -101 then
				-- 删掉对象
				SOCKET:delInstance(socket_type)
				local cur_scene = display.getRunningScene()

				if cur_scene["name"] == "battle" then
					KNMsg.getInstance():boxShow("网络出现异常，你可能已经断网了" , {
						confirmFun = function()
							switchScene("login")
						end
					})
				else
					KNMsg.getInstance():flashShow("网络出现异常，你可能已经断网了")
				end
			elseif code == -99 then
				Clock:removeTimeFun("heartbeat")
				SOCKET:delInstance(socket_type)

				print("kick_off  ========")
				-- 解包，先截取前面30个字符
				local response_func = string.sub(response , 0 , 30)
				response_func = string.trim(response_func)

				-- 后面是 json 串
				response = string.sub(response , 31)
				
				--[[服务端推送数据的，在下面处理]]
				-- 解包数据
				response = json.decode( response )

				
				KNMsg.getInstance():boxShow(response.msg , {
					confirmFun = function()
						switchScene("login")
					end
				})
			end

			return false
		end
		
		--返回数据中不包含response
		if not response or response == "" or string.len(response) <= 30 then
			if loading ~= nil then loading:remove() end 		-- 去掉 loading

			-- 关闭链接
			-- socket:close(socket_type)

			-- 错误处理
--			param.error_callback( {code = "-1999" , msg = "网络请求出错."} )
			return false
		end

		-- 解包，先截取前面30个字符
		local response_func = string.sub(response , 0 , 30)
		response_func = string.trim(response_func)

		-- 后面是 json 串
		response = string.sub(response , 31)


		--[[客户端主动发送数据的用自定义的回调函数接数据]]
		if callbacks_table[response_func] ~= nil then
			return callbacks_table[response_func](code , response)
		end

		
		--[[服务端推送数据的，在下面处理]]
		-- 解包数据
		response = json.decode( response )
		if response == nil or response.code ~= 0 or socketActions[response_func] == nil then
			echoLog("SOCKET" , "Bad Data")
			return false
		end


		-- 接到数据后，执行 socketActions 回调
		commonActions.saveCommonData( response )
		socketActions[response_func](2 , response)

	end


	-- 创建统一回调
	socket:creadFuancuan(_callback)



	return socket
end


return SOCKET
