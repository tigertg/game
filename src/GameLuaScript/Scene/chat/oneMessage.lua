--[[一条数据]]
local KNMask = requires(IMG_PATH , "GameLuaScript/Common/KNMask")
local detailOne = requires(IMG_PATH , "GameLuaScript/Scene/chat/detailOne")
local baseElement = requires(IMG_PATH , "GameLuaScript/Scene/common/baseElement")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local PATH = IMG_PATH .. "image/scene/chat/"

local oneMessage = {
	layer,
}

function oneMessage:talknew(data , message_type , params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	params = params or {}
	
	this.layer = display.newLayer()

	local str = self:formatMsg(data["template"] , data["msg"] or {})
	
	if params.type == "world"  and data.item[1] then
		if tonumber( data.item[1].uid ) ~= tonumber( DATA_Session:get("uid") ) then
			str = str .. " -加为好友-"
		end
	end
--	local has_items = true
--	if message_type ~= "talk" and data.item and #data.item > 0 then
--		has_items = true
--	end

	local total_width = has_items and 370 or 410						-- 文字总宽度
	local line = 1														-- 行数



	-- 估算一行的字符数量
	local label = CCLabelTTF:create(str , FONT , params.fontSize or 20)
	local label_size = label:getContentSize()
	local line_height = label_size.height			-- 行高(下面会重新计算)

	if label_size.width > total_width then			-- 大于一行
		line = math.ceil( label_size.width / total_width )
		label:setDimensions( CCSize:new( total_width , line * line_height ) )
	end

	label:setColor( params.color or ccc3( 0x2c , 0x00 , 0x00 ) )
	setAnchPos(label , 0 , 3)
	label:setHorizontalAlignment( 0 )			-- 文字左对齐
	this.layer:addChild( label )


	local total_height = line * line_height + 6		-- 总高度
	-- 横线
	if not params.first_line then
		local rule = display.newSprite(IMG_PATH .. "image/scene/chat/rule.png")
		setAnchPos(rule , -20 , total_height + 5)	
		this.layer:addChild(rule)

		total_height = total_height + 5
	end
	
--	-- 箭头
--	if has_items then
--		local arrow = display.newSprite(IMG_PATH .. "image/scene/chat/arrow.png")
--		setAnchPos(arrow , 380 , total_height / 2 - 2 , 0 , 0.5)	
--		this.layer:addChild(arrow)
--	end


	this.layer:setContentSize( CCSizeMake( 410 , total_height ) )


	-- 设置可点击
--	if has_items then
		local init_y = 0
		this.layer:registerScriptTouchHandler(function( type , x , y )
		local range = this:getRange()
		if range:containsPoint(ccp(x,y)) and y <params.parent:getY() + params.parent:getHeight() and y > params.parent:getY()  then
			if type == CCTOUCHBEGAN then
					init_y = y
			elseif type == CCTOUCHMOVED then
			elseif type == CCTOUCHENDED then
				if math.abs(y - init_y) < 30 then
				
					if params.type == "friend"  then
						--私聊界面，定位聊天对象
						local curData = data.item
						local tempData
						for i = 1 , #curData do
							if tonumber( curData[i].uid ) ~=  tonumber( DATA_Session:get("uid") ) then
								tempData = curData[i]
							end
						end
						params.backFun( tempData )
					else
						--其它的界面，弹出个人信息与加好友
						local curUid
						if params.type == "gang" then
							curUid = data.msg[5]
						elseif params.type == "world" then
							curUid = data.item[1].uid
						end
						
						if tonumber( curUid ) ==  tonumber( DATA_Session:get("uid") )  then
							HTTP:call("status" , "get" , {} , {
								success_callback = function(params)
									switchScene("userinfo",params)
								end
							})
						else
							HTTP:call("profile","get",{ touid = curUid },{success_callback = 
								function()
									local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
									display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
								end})
						end
					end
				end
					
			end
			return true
		else
			return false
		end
		end , false , -131)
		this.layer:setTouchEnabled(true)
--	end
	
	return this
end


function oneMessage:new(data , message_type , params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	params = params or {}
	local type = params.type 
	local parent = params.parent or {}
	this.layer = display.newLayer()
	local bg = display.newSprite( COMMONPATH .. "item_bg.png" , 0 , 0 , 0 , 0 )
	this.layer:addChild( bg )
	this.layer:setContentSize( bg:getContentSize() )
	this.layer:addChild( display.newSprite( PATH .. "item_text_bg.png" , 10 , 10 , 0 , 0 ) )
	local str = self:formatMsg(data["template"] , data["msg"] or {})
--	if type then
--		str = ( type == "world" and "【世界】" or "【帮派】" ) ..  str
--	end
	local has_items = false
	if message_type ~= "talk" and data.item and #data.item > 0 then
		has_items = true
	end

	local total_width = 330												-- 文字总宽度
--	local total_width = has_items and 370 or 410						-- 文字总宽度
	local line = 1														-- 行数



	-- 估算一行的字符数量
	local label = CCLabelTTF:create(str , FONT , params.fontSize or 20 )
	local label_size = label:getContentSize()
	local line_height = label_size.height			-- 行高(下面会重新计算)

	if label_size.width > total_width then			-- 大于一行
		line = math.ceil( label_size.width / total_width )
		label:setDimensions( CCSize:new( total_width , line * line_height ) )
	end

	label:setColor( params.color or  ccc3( 0xff , 0xfb , 0xd5 ) )
--	label:setColor( params.color or  ccc3( 0x2c , 0x00 , 0x00 ) )
	setAnchPos(label , 20 , 90 , 0 , 1 )
	label:setHorizontalAlignment( 0 )			-- 文字左对齐
	this.layer:addChild( label )


	local total_height = line * line_height + 6		-- 总高度

	local function clickFun()
		local additionInfo = data.item 
	
		local function createElement()
			local tempLayer = baseMask( {  titlePath = PATH .. "operation_title.png" , isShowBack = true } )
			
			if additionInfo[1].type == "wakuang" then
				tempLayer:addChild( display.strokeLabel( additionInfo[1].name .. "申请你保护矿山" , display.cx - 150 , 505 , 20 , ccc3( 0x2c , 0x00 , 0x00 ), nil , nil , {
					dimensions_width = 300 ,
					dimensions_height = 0,
					align = 1
				}))
				--接受
				tempLayer:addChild( KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" } , display.cx - 40 , 400 ,{
											parent = parent , 
											priority = -131 ,
											front = COMMONPATH .. "consent.png"  , 
											callback = function()
													HTTP:call("mining","guard_accept",{ from_uid = additionInfo[1].uid },{success_callback = 
													function()
														KNMsg.getInstance():flashShow( "保护成功！" )	
													end})
											end }):getLayer() )
--				--拒绝
--				tempLayer:addChild( KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" } , 275 , 400 ,{
--											parent = parent , 
--											priority = -131 ,
--											front = COMMONPATH .. "reject.png"  , 
--											callback = function()
--												tempLayer:remove()
--											end }):getLayer() )
				return		
			end
			
			local roleData = nil	--是否存在角色
			local goods = nil		--是否存在物品
			for i = 1 , #additionInfo do
				if additionInfo[i].uid then
					roleData = additionInfo[i]
				end
				if additionInfo[i].cid then
					goods = additionInfo[i]
				end
			end
			
			local addX , addY = 125 , 500
			if roleData then
				tempLayer:addChild( display.newSprite( PATH .. "role_title.png" , addX , addY  , 0 , 0 ) )
				tempLayer:addChild( KNBtn:new( COMMONPATH , { "big.png" , "big_pre.png" } ,  addX + 75 , addY - 3 ,{
											parent = parent , 
											priority = -131 ,
											text = { { roleData.name , 16 , ccc3( 0 , 0 , 0 ) } }  , 
											callback = function()
												--查看他人信息
												if  tonumber( roleData["uid"] ) ~= tonumber( DATA_Session:get("uid") ) then
													HTTP:call("profile","get",{ touid = roleData.uid },{success_callback = 
													function()
														local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
														display.getRunningScene():addChild( otherPalyerInfo:new( ):getLayer() )
													end})
												end
											end }):getLayer() )

			end
			if goods then
				addY = addY - 65
				local goodsData = getConfig( getCidType( goods.cid ) ,  goods.cid )
				tempLayer:addChild( display.newSprite( PATH .. "goods_title.png" , addX , addY , 0 , 0 ) )
				tempLayer:addChild( KNBtn:new( COMMONPATH , { "big.png" , "big_pre.png" } , addX + 75  , addY - 3 ,{
						parent = parent , 
						priority = -131 ,
						text = { { goodsData.name , 16 , ccc3( 0 , 0 , 0 ) } }  , 
						callback = function()
							awardCell( goods , { getClickFun = true })()
						end }):getLayer()  )
			end
			if roleData then	
				local addX = ( message_type == "battle" and 76  or ( display.cx - 73 ) )
				local addBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"} , addX  , 370 , {
							scale = true,
							priority = -131 ,
							front = IMG_PATH.."image/scene/userinfo/add_friend.png" , 
							callback = function()
								if tonumber( roleData["uid"] ) ~= tonumber( DATA_Session:get("uid") ) then
									HTTP:call("friends","addfrd",{ id = roleData["uid"] },{success_callback = 
												function()
													tempLayer:remove()
												end})
								else
									KNMsg.getInstance():flashShow( "不能添加自己为好友!" )	
								end
								
							end
							})
				tempLayer:addChild( addBtn:getLayer() )
				
				if message_type == "battle" then
					--战斗回放按钮
					local battleReplayBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"} , 261  , 370 , {
								scale = true,
								priority = -131 ,
								front = PATH .. "battle_replay.png" , 
								callback = function()
									KNMsg.getInstance():flashShow( "暂开开放!" )	
								end
								})
					tempLayer:addChild( battleReplayBtn:getLayer() )
				end
			end
		end
		
		
		if table.nums(additionInfo)~=0 then
			createElement()
			if message_type == "system" then			--系统
	
			elseif message_type == "battle" then		--战报
				
			elseif message_type == "consume" then		--消费
				
			end
		end

	end
	
	local existElement = { 
							system = "system" , 
							battle = "battle" , 
							consume = "consume" ,
							social = "social" ,
							}
	if existElement[message_type] and table.nums( data.item  ) ~= 0 then
		local operationBtn = KNBtn:new( COMMONPATH , {"btn_bg.png","btn_bg_pre.png"}, 357 , 53 , {
											parent = parent ,
											front = IMG_PATH .. "image/scene/friend/text_operate.png" ,
											callback = clickFun
										}):getLayer()
		this.layer:addChild( operationBtn )
	end
	
	return this
end

function oneMessage:formatMsg(str , replace)
	if not str then return "" end

	if type(replace) == "table" and table.nums(replace) > 0 then
		local nums = 0

		str = string.gsub(str , "#s#" , function()
			nums = nums + 1
			if replace[nums] ~= nil then
				local replace_type = type(replace[nums])
				if replace_type == "string" or replace_type == "number" then
					return replace[nums]
				else
					return ""
				end
			end

			return ""
		end)
	end

	local return_str = ""
	while true do
		local start_pos , end_pos , color = string.find(str , "%[color=(#[a-f0-9]+)%]")
		if start_pos == nil then break end
		local start_pos_2 , end_pos_2 = string.find(str , "%[/color%]" , end_pos)
		if start_pos_2 == nil then break end
		local first_str = string.sub(str , 0 , start_pos - 1)
		local second_str = string.sub(str , end_pos + 1 , start_pos_2 - 1)

		return_str = return_str .. first_str .. second_str
		str = string.sub(str , end_pos_2 + 1)
	end


	return return_str .. str
end

function oneMessage:getLayer()
	return self.layer
end


--获取所有父组件，取得按钮的绝对位置
function oneMessage:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()

	local parent = self.layer:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end

return oneMessage