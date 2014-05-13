--[[

选区

]]


local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local M = {}

local select_server_id
local PATH = IMG_PATH .. "image/scene/servers/"
function M:create( params )
	local default_server_id = params.default_server_id
	local servers = params.servers

	local default_server , tempDefault_server
	local server_name_label
	local curState
	-- 获取默认选区
	for i = 1 , #servers do
		if servers[i].server_id == default_server_id then
			default_server = servers[i]
			break
		end
	end
	tempDefault_server = default_server
	select_server_id = default_server_id

	local layer = display.newLayer()
	
	layer:addChild( display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg" , 0 , 0 , 0 , 0 ) )
	
	local function setCurState()
		if curState then
			curState:removeFromParentAndCleanup( true )
			curState = nil
		end
		curState = display.newSprite( PATH .. default_server.type .. ".png" )
		setAnchPos(curState , 78 , 138)
		layer:addChild( curState )
	end
	
	
	local function createList()
		
		local listLayer = display.newLayer()
		local mask
		local scroll = KNScrollView:new( 30 , 250 , 420 , 570 , 5 , false , 0 , { priority = -133 } )
		local group = KNRadioGroup:new()
		
		listLayer:addChild( display.newSprite( PATH .. "server_bg.png" , display.cx , 190 , 0.5 , 0 ) )
		
		
		local function createTitle( name )
			local tempTitle = display.newSprite( PATH .. name .. ".png" , display.cx , 0 , 0.5 , 0 )
			tempTitle:addChild( display.newSprite( PATH .. "line.png" , tempTitle:getContentSize().width/2 , -5 , 0.5 , 0 ) )
			return tempTitle
		end
		
		
		
		local function createItem( itemData , itemGroup )
			return KNBtn:new( PATH , { "item_bg.png"  , "select.png" } , 0 , 0 , {
				parent = scroll ,
				priority = -132 ,
				noHide = true ,
				upSelect = true ,
				selectZOrder = 1 ,
				text = { { itemData.name , 14 , ccc3( 0xff , 0xfa , 0xd4 ) , { x = 25 , y = 0 }  , true , 20 } }  ,
				other = { PATH .. itemData.type .. ".png"  , 140 , 14 , -2 } ,
				callback = function()
					default_server = itemData
				end
			} , itemGroup or nil )
		end
		
		scroll:addChild( createTitle("recently_title") )
		
		
		local function createItemGroup( _data , isGroup )
			local lastData = _data or {}
			for i = 1 , math.ceil( #lastData/2 ) do
				local itemLayer = display.newLayer()
				itemLayer:setContentSize( CCSize:new( 420 , 57 ) )
				for j = 1 , 2 do
					local index = ( i - 1 ) * 2 + j
					if lastData[index] then
						local curItem = createItem( lastData[index] , isGroup and group or nil )
						setAnchPos( curItem:getLayer() , ( j == 1 and 0 or 210 ), 0 )
						itemLayer:addChild( curItem:getLayer() )
						
						if default_server.server_id == lastData[index].server_id then
							group:chooseBtn( curItem , true )
						end 
					end
				end
				scroll:addChild( itemLayer , itemLayer )
			end
		end
		local lastData = {}
		for i = 1 , #params.last_login_servers do
			for key , v in pairs(servers) do
				if v.server_id == params.last_login_servers[i] then
					lastData[ #lastData + 1 ] = v 
				end
			end
		end
		
		createItemGroup( lastData , true )
		scroll:addChild( createTitle("all_title") )
		createItemGroup( servers , true )	--所有服务器列表
		
		scroll:alignCenter()
		listLayer:addChild( scroll:getLayer() )
		
		
		--确定
		listLayer:addChild( KNBtn:new(COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 70 , 200 , {
					front =  COMMONPATH .. "confirm.png" ,
					priority = -142,
					scale = true,
					callback = function()
						mask:remove()
						server_name_label:setString( default_server.name )
						select_server_id = default_server.server_id
						tempDefault_server = default_server 
						
						setCurState()
					end
				}):getLayer() )
		--取消
		listLayer:addChild( KNBtn:new(COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 260 , 200 , {
					front =  COMMONPATH .. "cancel.png" ,
					priority = -142,
					scale = true,
					callback = function()
						default_server = tempDefault_server
						mask:remove()
					end
				}):getLayer() )
	
		mask = KNMask:new( { item = listLayer } )
		setAnchPos( listLayer , 0  , display.height )
		transition.moveTo( listLayer , { time = 0.5 , y = 0 , easing = "BACKOUT" })
		
		layer:addChild( mask:getLayer() )
	end

	local serverBtn = KNBtn:new( PATH , { "small.png" } , 29 , 120 , { 
		text = { { "点击选区" , 20 , ccc3( 0x29 , 0xbc , 0xce ) , { x = 316 , y = 0 }  , true , 20 } } ,
		callback = createList 
	})
	
	layer:addChild(  serverBtn:getLayer() )
	
	--设置当前服务器状态
	setCurState()

	server_name_label = CCLabelTTF:create(default_server.name , FONT , 24)
	setAnchPos(server_name_label , 155 , 140)
	server_name_label:setColor( ccc3( 0xff , 0xff , 0xff ) )
	layer:addChild( server_name_label )



	local login_callback = function()
		-- 获取下发的登录服务器
		CONFIG_HOST = default_server.host
		CONFIG_SOCKET_HOST = default_server.socket
		CONFIG_SOCKET_PORT = default_server.port
		if default_server.payurl ~= nil and default_server.payurl ~= "" then
			CONFIG_PAY_URL = default_server.payurl
		end

		-- 发请求
		local post_data = {
			server_id = select_server_id ,
			channel = CHANNEL_ID,
		}
		for k , v in pairs(device.infos) do
			post_data[k] = v
		end
		
		HTTP:call("login" , "develop" , post_data , {
			success_callback = function()
				if CHANNEL_ID == "appFame" then
					LuaCallAppFrameSDK:getInstance():setServIdServName(DATA_Session:get("server_id"),"群殴水浒")
					if DATA_User:get("name") then
						LuaCallAppFrameSDK:getInstance():setRoleIdRoleName(DATA_Session:get("uid"),DATA_User:get("name"))
					end
				elseif CHANNEL_ID == "appFameOfficial" then
                    LuaCallAppFameSDKOfficial:getInstance():setServIdServName(DATA_Session:get("server_id"),"群殴水浒")
                    if DATA_User:get("name") then
						LuaCallAppFameSDKOfficial:getInstance():setRoleIdRoleName(DATA_Session:get("uid"),DATA_User:get("name"))
					end
				end
			end
		})
	end


	-- 登录按钮
	login_btn = KNButton:new("login" , 0 , display.cx , 20 , login_callback , 1 , { noDisable = true })
	setAnchPos(login_btn , display.cx - 120 , 20 , 0.5)
	layer:addChild( login_btn )
	

	return layer
end



return M
