--[[

登录框

]]


local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNInputText = requires(IMG_PATH, "GameLuaScript/Common/KNInputText")

local M = {}

local layer
local isReg 
local loginbox_layer

local userinfo_file_path = "userinfo.txt"
if device.platform == "windows" then
	userinfo_file_path = "../userinfo.txt"
end


function M:uc_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	local has_init
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			if not has_init then
				KNMsg.getInstance():flashShow("正在初始化九游用户中心，请稍等")
				UCGameSDK:getInstance():setOrientation(0)
				UCGameSDK:getInstance():setLogoutCallback(function(event)
					if event.type == "init" then
						-- uc 个人中心
						UCGameSDK:getInstance():createFloatButton()
						UCGameSDK:getInstance():showFloatButton(0 , 0 , true);

						UCGameSDK:getInstance():login(false , "COCO号")
						return
					end

					local uc_sid = event.sid
					if not uc_sid then
						KNMsg.getInstance():flashShow("登录失败，请重新登录")
						return
					end

					-- 发请求
					local post_data = {
						platform = "uc" ,
						uc_sid = uc_sid ,
						channel = CHANNEL_ID,
					}
					for k , v in pairs(device.infos) do
						post_data[k] = v
					end
					HTTP:call("verify" , "check" , post_data)
				end)
				-- init
				UCGameSDK:getInstance():initSDK(false , 2 , 27820 , 518084 , 2126 , "安卓大话水浒" , true , true)


				has_init = true
				return
			else
				KNMsg.getInstance():flashShow("正在初始化九游用户中心，请稍等")
				UCGameSDK:getInstance():login(false , "COCO号")
			end
		end
	}):getLayer()
	layer:addChild(loginBtn)


	return layer
end



function M:_91_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			LuaCall91PlatForm:getInstance():login(function(response)
			    
			    local loginUin = response["loginUin"]
			    local sessionId = response["sessionId"]
			    local nickName = response["nickName"]

				if not sessionId or not loginUin then
					KNMsg.getInstance():flashShow("登录失败，请重新登录")
					return
				end

				-- 发请求
				local post_data = {
					platform = "91" ,
					_91_sid = sessionId ,
					_91_uin = loginUin,
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)

	return layer
end

-- 龙印
function M:longyin_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			FlySDK:getInstance():FlyInit("100079","100125","47adc1294wxyxa88","dahua",function(response) 
				response = string.split(response["data"] , "@@")
				local data = {}

				for i = 1 , #response do
					local temp = string.split(response[i] , "=")
					if #temp == 2 then
						data[temp[1]] = temp[2]
					end
				end
				
				if not data["sessionid"] or not data["accountid"] or not data["status"]or not data["customstring"] then
					KNMsg.getInstance():flashShow("登录失败，请重新登录")
					return
				end
				-- 发请求
				local post_data = {
					platform = "longyin" ,
					accountid = data["accountid"],
					sessionid = data["sessionid"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
				
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	return layer
end

-- 有信
function M:youxin_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )
	
	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			youxinSDK:getInstance():youxinLogin(function(response) 
			
				response = string.split(response["data"] , "@@")
				local data = {}

				for i = 1 , #response do
					local temp = string.split(response[i] , "=")
					if #temp == 2 then
						data[temp[1]] = temp[2]
					end
				end
				CCLuaLog("openId : " .. (data["openId"] or "nil"))
				CCLuaLog("sign : " .. (data["sign"] or "nil"))
				-- 发请求
				local post_data = {
					platform = "youxin" ,
					youxin_openid = data["openId"] ,
					youxin_sign = data["sign"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
				
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	return layer
end

function M:ledou_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			ledouSDK:getInstance():ledouLogin("f8be48c08a4f0a9cadc5","007d67014a65b8652db1","dd",function(response) 
				response = string.split(response["data"] , "@@")
				local data = {}

				for i = 1 , #response do
					local temp = string.split(response[i] , "=")
					if #temp == 2 then
						data[temp[1]] = temp[2]
					end
				end
				
				if not data["openId"] or not data["sessionId"]  then
					KNMsg.getInstance():flashShow("登录失败，请重新登录")
					return
				end
				-- 发请求
				local post_data = {
					platform = "idreamsky" ,
					open_id = data["openId"] ,
					sessionid = data["sessionId"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	return layer
end


function M:pada_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			padaSDK:getInstance():padaLogin("101025","243276271df637165b207edaffe5a912",function(response)
				response = string.split(response["data"] , "@@")
				local data = {}
				
				for i = 1 , #response do
					local temp = string.split(response[i] , "=")
					if #temp == 2 then
						data[temp[1]] = temp[2]
					end
				end
				
				CCLuaLog("roleId : " .. (data["roleId"] or "nil"))
				CCLuaLog("roleName : " .. (data["roleName"] or "nil"))
				CCLuaLog("roleToken : " .. (data["roleToken"] or "nil"))
				
				if not data["roleId"] or not data["roleName"] or not data["roleToken"] then
					KNMsg.getInstance():flashShow("登录失败，请重新登录")
					return
				end
				-- 发请求
				local post_data = {
					platform = "pada" ,
					roleId = data["roleId"] ,
					roleToken = data["roleToken"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	return layer
end


function M:qihoo_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			qihooSDK:getInstance():qihooLogin("false","true",function(response) 
				
				--qihooSDK:getInstance():qihoopay("false","true")
				
				-- 发请求
				local post_data = {
					platform = "qihoo" ,
					qihoo_code = response["data"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	return layer
end


--云顶登录
function M:appFame_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			local userInfo=LuaCallAppFrameSDK:getInstance():login(function()
				SOCKET:getInstance("battle"):closeSocket()
				SOCKET:delInstance("battle")
				switchScene("login")
			end)
			
			local infoSz = string.split(userInfo , ",")
		    
		    local loginUin = infoSz[1]
			local nickName = infoSz[2]
			local sessionId = infoSz[3]
				
			if not sessionId or not loginUin or not nickName then
				KNMsg.getInstance():flashShow("登录失败，请先在云顶账号中心登录账号再重新登录")
				return
			end
			
			-- 发请求
			local post_data = {
					platform = "appFame" ,
					appFame_sid = sessionId ,
					appFame_uin = loginUin,
					channel = CHANNEL_ID,
			}
			for k , v in pairs(device.infos) do
					post_data[k] = v
			end
			HTTP:call("verify" , "check" , post_data )
			
		end
	}):getLayer()
	layer:addChild(loginBtn)

	return layer
end


--云顶正版登录
function M:appFameOfficial_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			local userInfo=LuaCallAppFameSDKOfficial:getInstance():login(function()
				SOCKET:getInstance("battle"):closeSocket()
				SOCKET:delInstance("battle")
				switchScene("login")
			end)
			
			local infoSz = string.split(userInfo , ",")
		    
		    local loginUin = infoSz[1]
			local nickName = infoSz[2]
			local sessionId = infoSz[3]
				
			if not sessionId or not loginUin or not nickName then
				KNMsg.getInstance():flashShow("登录失败，请先在云顶账号中心登录账号再重新登录")
				return
			end
			
			-- 发请求
			local post_data = {
					platform = "appFameOfficial" ,
					appFame_sid = sessionId ,
					appFame_uin = loginUin,
					channel = CHANNEL_ID,
			}
			for k , v in pairs(device.infos) do
					post_data[k] = v
			end
			HTTP:call("verify" , "check" , post_data )
			
		end
	}):getLayer()
	layer:addChild(loginBtn)

	return layer
end




function M:cmge_login( params )
	layer = display.newLayer()

	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )

	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	local loginBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , display.cx - 100 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			CMGEsdk:getInstance():cmgeLogin(function(response)
				response = string.split(response["data"] , "@@")
				local data = {}

				for i = 1 , #response do
					local temp = string.split(response[i] , "=")
					if #temp == 2 then
						data[temp[1]] = temp[2]
					end
				end
				
				CCLuaLog("userId : " .. (data["userId"] or "nil"))
				CCLuaLog("timestamp : " .. (data["timestamp"] or "nil"))
				CCLuaLog("sign : " .. (data["sign"] or "nil"))
				
				if not data["userId"] or not data["timestamp"] or not data["sign"] then
					KNMsg.getInstance():flashShow("登录失败，请重新登录")
					return
				end

				-- 发请求
				local post_data = {
					platform = "cmge" ,
					cmge_uin = data["userId"] ,
					cmge_timestamp = data["timestamp"],
					cmge_sign = data["sign"],
					channel = CHANNEL_ID,
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				HTTP:call("verify" , "check" , post_data)
			end)
		end
	}):getLayer()
	layer:addChild(loginBtn)

	return layer
end



function M:create( params )
	if CHANNEL_ID == "uc" then return M:uc_login( params ) end
	if CHANNEL_ID == "91" then return M:_91_login( params ) end
	if CHANNEL_ID == "cmge" then return M:cmge_login( params ) end
    if CHANNEL_ID == "appFame" then return M:appFame_login( params ) end
    if CHANNEL_ID == "appFameOfficial" then return M:appFameOfficial_login( params ) end
	if CHANNEL_ID == "longyin" or CHANNEL_ID == "mi" or CHANNEL_ID == "downjoy" or CHANNEL_ID == "DK" or CHANNEL_ID == "kugou" or CHANNEL_ID == "gfan" or CHANNEL_ID == "oppo" then return M:longyin_login( params ) end
	if CHANNEL_ID == "ledou" then return M:ledou_login( params ) end
	if CHANNEL_ID == "pada" then return M:pada_login( params ) end
	if CHANNEL_ID == "qihoo" then return M:qihoo_login( params ) end
	if CHANNEL_ID == "youxin" then return M:youxin_login( params ) end
	
	isReg = params.isReg or false	--是否是注册
	
	loginbox_layer = nil

	layer = display.newLayer()
	
	requires(IMG_PATH,"GameLuaScript/Config/version")

	
	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , 0 , 0)
	layer:addChild( bg )
	
	local version_label = CCLabelTTF:create(VERSION , FONT , 18)
	setAnchPos(version_label , 10 , 10)
	version_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	layer:addChild( version_label )

	if CHANNEL_ID == "test" then
		local test_label = CCLabelTTF:create("骚年，你运行的是测试版本，有问题请重新安装" , FONT , 18)
		setAnchPos(test_label , 10 , display.height - 30)
		test_label:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
		layer:addChild( test_label )
	end
	
	local userinfo_file_path = "userinfo.txt"
	if device.platform == "windows" then
		userinfo_file_path = "../userinfo.txt"
	end
	local username = KNFileManager.readfile(userinfo_file_path , "name" , "=")
	local password = KNFileManager.readfile(userinfo_file_path , "pwd" , "=")
	
	if username and username ~= "" then
		M:showLoginBox()
	else
		M:gameSelect()
	end

	return layer
end


function M:showLoginBox()
	local box_bg , username_input_bg , password_input_bg , username_textfield , effBg , 
		password_textfield ,  login_btn , send_btn , backBtn ,registerBtn 

	

	--[[登录按钮]]
	local login_callback = function()
		audio.stopMusic( false )
		
		echoLog("Login" , "Click Login Button")

		local open_id = username_textfield:getString()
		open_id = string.trim( open_id )

		local password = password_textfield:getString()
		password = string.trim( password )
	
		if open_id == "" then
			-- 错误提示
			KNMsg:getInstance():flashShow("请输入ID")
			return
		end

		if password == "" then
			-- 错误提示
			KNMsg:getInstance():flashShow("请输入密码")
			return
		end

		username_textfield:stopInput()
		password_textfield:stopInput()

		-- 发请求
		local post_data = {
			open_id = open_id ,
			pwd = password ,
			channel = CHANNEL_ID,
			reg = isReg and 1 or nil ,
		}
		for k , v in pairs(device.infos) do
			post_data[k] = v
		end
		
		HTTP:call("verify" , "check" , post_data , {
			success_callback = function(d)
				KNFileManager.updatafile(userinfo_file_path , "name" , "=" , open_id)
				KNFileManager.updatafile(userinfo_file_path , "pwd" , "=" , password)
			end,
			error_callback = function(d)
				switchScene("login" , { isReg = isReg } , function()
					KNMsg.getInstance():flashShow("[" .. d.code .. "]" .. d.msg)
				end)
			end
		})
	end


	if loginbox_layer ~= nil then
		loginbox_layer:removeFromParentAndCleanup(true)
	end

	loginbox_layer = display.newLayer()

	

	-- 切换真假输入框的状态
	local function changeStauts(status , type)
		if status == true then
			box_bg:setPosition(0 , 432)
			
			setAnchPos( username_textfield:getLayer() , 150  , 516 )
			setAnchPos( password_textfield:getLayer() , 150  , 476 )
			
			username_input_bg:setPosition(140 , 500)
			password_input_bg:setPosition(140 , 460)
			
			effBg:setVisible(true)
			
			if type == "username" then
				setAnchPos( effBg , 140 + 118 , 500 + 16 , 0.5 , 0.5  )
				
				username_textfield:startInput()
				password_textfield:stopInput()
				
			else
				setAnchPos( effBg , 140 + 118 , 460 + 16 , 0.5 , 0.5  )
				
				username_textfield:stopInput()
				password_textfield:startInput()
				
			end

			login_btn:setVisible(false)
			if isReg then
				send_btn:showBtn(false)
				send_btn:setEnable(false)
				
				setAnchPos( registerBtn:getLayer() , 390 , 455 )
			else
				send_btn:showBtn(true)
				send_btn:setEnable(true)
				
				registerBtn:showBtn(false)
				registerBtn:setEnable(false)
				setAnchPos( registerBtn:getLayer() , 390 , 130 )
			end
			
			backBtn:setVisible(true)
		else
			effBg:setVisible( false )	--隐藏提示光效
			
			box_bg:setPosition(0 , 110)
			

			username_input_bg:setPosition(140 , 175)
			password_input_bg:setPosition(140 , 136)

			setAnchPos( username_textfield:getLayer() , 150  , 192 )
			setAnchPos( password_textfield:getLayer() , 150  , 152 )


			username_textfield:stopInput()
			password_textfield:stopInput()

			login_btn:setVisible(true)
			send_btn:showBtn(false)
			backBtn:setVisible(false)
			
			isReg = false
			registerBtn:showBtn(true)
			registerBtn:setEnable(true)
			setAnchPos( registerBtn:getLayer() , 390 , 130 )
		end
	end

	local username = KNFileManager.readfile(userinfo_file_path , "name" , "=")
	local password = KNFileManager.readfile(userinfo_file_path , "pwd" , "=")

	

	-- 用户名输入框
	username_textfield = KNInputText:new( { width = 212 , 
											height = 28 , 
											size = 20 , 
											defStr = "请输入ID" , 
											existStr = ( ( username and username ~= "" ) and username or nil ) ,
											defColor = ccc3( 0xff , 0xfb , 0xd4 ) , 
											inputColor = ccc3( 0x4d , 0x15 , 0x15 ) 
											} )
	loginbox_layer:addChild( username_textfield:getLayer() , 10 )
	



	-- 密码输入框
	password_textfield = KNInputText:new( { width = 212 , 
											height = 28 , 
											size = 20 , 
											defStr = "请输入密码" , 
											existStr = ( ( password and password ~= "" ) and password or nil ) , 
											defColor = ccc3( 0xff , 0xfb , 0xd4 ) , 
											inputColor = ccc3( 0x4d , 0x15 , 0x15 ) 
											} )
	loginbox_layer:addChild( password_textfield:getLayer() , 10 )


	-- 假输入框背景
	box_bg = display.newSprite(IMG_PATH .. "image/scene/login/box_bg.png")
	setAnchPos(box_bg , 0 , 110)
	loginbox_layer:addChild(box_bg)
	
	effBg = display.newSprite(IMG_PATH .. "image/scene/login/eff_bg.png")
	effBg:setVisible( false )
	loginbox_layer:addChild( effBg )
	local function createAction()
			local action
			action = getSequenceAction( CCFadeIn:create( 0.5 ) , CCFadeOut:create( 0.5 ) , CCCallFunc:create(
			function()
				effBg:runAction(createAction())
			end))	
			return action
	end
	effBg:runAction(createAction())	
	
	
	-- 假用户名输入框背景
	username_input_bg = KNBtn:new(IMG_PATH .. "image/scene/login", {"input_bg.png"} , 140 , 175 , {
		callback = function()
			changeStauts(true , "username")
		end
	}):getLayer()
	loginbox_layer:addChild(username_input_bg)

	-- 假密码输入框背景
	password_input_bg = KNBtn:new(IMG_PATH .. "image/scene/login", {"input_bg.png"} , 140 , 136 , {
		callback = function()
			changeStauts(true , "password")
		end
	}):getLayer()
	loginbox_layer:addChild(password_input_bg)


	-- 开始按钮
	send_btn = KNBtn:new(IMG_PATH .. "image/scene/login" , {"send_btn.png" , "send_btn_pre.png"} , 390 , 455 , {
		callback = 
		function()
			isReg = false
			login_callback()
		end
	})
	loginbox_layer:addChild( send_btn:getLayer() )
	
	-- 注册按钮
	registerBtn = KNBtn:new(IMG_PATH .. "image/scene/login" , {"register.png" , "register_pre.png"} , 390 , 130 , {
		callback =
		function()
			if not isReg then
				isReg = true
				changeStauts( true , "username" )
			else
				login_callback()
			end

		end 
	})
	loginbox_layer:addChild( registerBtn:getLayer() )
	
	-- 返回按钮
	backBtn = KNBtn:new(IMG_PATH .. "image/scene/login" , {"back.png" , "back_pre.png"} , 10 , 460 , {
		callback = 
		function()
			changeStauts()
		end
	}):getLayer()
	loginbox_layer:addChild( backBtn )


	-- 登录按钮
	login_btn = KNButton:new("login" , 0 , display.cx , 20 , login_callback , 1 , { noDisable = true })
	setAnchPos(login_btn , display.cx - 120 , 20 , 0.5)
	loginbox_layer:addChild( login_btn )


	-- 默认为假输入框状态
	changeStauts( isReg )
	
	
	setAnchPos( loginbox_layer , 0 , -display.cy )
	transition.moveTo(loginbox_layer , {time = 0.5 , y = 0 , easing = "BACKOUT" })
	layer:addChild( loginbox_layer , 10)
end
--登陆选择
function M:gameSelect()
	local loginBtn , fastGameBtn
	loginBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , 42 , 70 , {
		front = IMG_PATH .. "image/scene/login/login.png" , 
		callback = function()
			fastGameBtn:removeFromParentAndCleanup( true )
			fastGameBtn = nil 
			
			loginBtn:removeFromParentAndCleanup( true )
			loginBtn = nil 
				
			M:showLoginBox()
		end
	}):getLayer()
	layer:addChild(loginBtn)
	
	fastGameBtn = KNBtn:new(IMG_PATH .. "image/scene/login", {"select_btn.png" , "select_btn_pre.png"} , 264 , 70 , {
		front = IMG_PATH .. "image/scene/login/fast_game.png" , 
		callback = function()
			local open_id = ""
			local password = ""

			if device.infos["msi"] and type(device.infos["msi"]) == "string" and string.len(device.infos["msi"]) >= 10 then
				open_id = device.infos["msi"]
			elseif device.infos["mac"] and type(device.infos["mac"]) == "string" and string.len(device.infos["mac"]) >= 10 then
				open_id = string.gsub(device.infos["mac"] , ":" , "")
			end

			if string.len(open_id) < 10 then
				KNMsg.getInstance():flashShow("不可快速游戏，请使用帐号登录")
				return
			end

			password = tostring( math.random(10000 , 999999) )
			local fast_login_sign = nil
			if CMD5 ~= nil then
				fast_login_sign = MD5(open_id .. CHANNEL_ID)
			end

			-- 发请求
			local post_data = {
				open_id = open_id ,
				pwd = password ,
				channel = CHANNEL_ID,
				fast_login_sign = fast_login_sign,
				reg = 2 ,
			}
			for k , v in pairs(device.infos) do
				post_data[k] = v
			end
			
			HTTP:call("verify" , "check" , post_data , {
				success_callback = function(d)
					KNFileManager.updatafile(userinfo_file_path , "name" , "=" , open_id)
					if d["result"] and d["result"]["pwd"] then
						password = d["result"]["pwd"]
					end
					KNFileManager.updatafile(userinfo_file_path , "pwd" , "=" , password)
				end
			})
		end
	}):getLayer()
	layer:addChild(fastGameBtn)
	
end





return M
