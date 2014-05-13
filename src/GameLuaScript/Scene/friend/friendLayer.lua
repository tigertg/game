--好友主界面

local M = {}

local PATH = IMG_PATH .. "image/scene/friend/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNInputText = requires(IMG_PATH, "GameLuaScript/Common/KNInputText")
function M:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	-- 基础层
	this.baseLayer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.tabLayer  = display.newLayer()
	this.listLayer = nil
	this.curTitle = nil --当前好友/当前仇人 
	this.curNumText = nil	--当前好友/当前仇人数量
	
	-- 背景
	local bg = display.newSprite( COMMONPATH .. "dark_bg.png")
	setAnchPos( bg , 0 , 88 )						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild( bg )
	
	

	local listConfig =  {{"friend","tab_friend"} ,  {"enemy","tab_enemy"} }
	local activity = "friend"
	this:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Friend:get() , defaultPage = 1 } )

	
	
	this.baseLayer:addChild( this.viewLayer )
	this.baseLayer:addChild( this.tabLayer , 20 )
	
	
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new( "friend" , 0 , { title_text = PATH.."scene_title.png", tail_hide = true} )
	this.baseLayer:addChild( this.infoLayer:getLayer() )	
	
	return this.baseLayer 
end

--生成list列表
function M:createList( params )
	params = params or {}
	local LISTPATH = PATH .. "tab/"
	
	
	if self.listLayer then	
		self.listLayer:removeFromParentAndCleanup(true)
		self.listLayer = nil
		self.curTitle = nil
		self.curNumText = nil
	end
	self.listLayer = display.newLayer()
	self.baseLayer:addChild( self.listLayer )
	
	
	
	local data , totalPage , curPage , curType , group , pageText , curData , alonePageNum , listConfig , pageBg , rankText ,  addFriend
	local scroll = nil
	listConfig = params.listConfig							--选项按钮
	data = params.data or {}								--展示的数据
	curType = params.defaultType 							--默认激活table
	curPage = params.defaultPage or 1 						--默认展示页面
	alonePageNum = params.alonePageNum or 0					--单页item个数
	local isPaging = params.alonePageNum and true or false	--是否分页
	local heightType = 0
	self.listLayer:addChild( display.newSprite( COMMONPATH .. "page_bg.png" , 350 , 700 , 0 , 0 ) )	--当前好友数字背景
	addFriend = KNBtn:new( COMMONPATH , { "add.png" , "add_press.png"  } , 430 , 695 , {
					scale = true ,
					callback = function()
						self:friendNumTip( { type = curType } )
					end})
					
	self.listLayer:addChild( addFriend:getLayer() )
	
	
	local function refreshData()
		if curType == "friend" then				--好友列表
			curData = data.frd or {} 
		elseif curType == "enemy" then			--仇人列表
			curData = data.enermy or {}
		end
		
		if isPaging then
			totalPage = math.ceil( #curData / alonePageNum )
			totalPage = totalPage == 0 and 1 or totalPage 
			pageText:setString( curPage .. "/" .. totalPage )
		else
			curPage = 1
		end
	end
	

	if isPaging then
		--页数背景
		pageBg = display.newSprite( COMMONPATH .. "page_bg.png" )
		setAnchPos(pageBg , 240 , 110 , 0.5)
		self.viewLayer:addChild( pageBg )
		--页数文字
		pageText = display.strokeLabel( curPage .. "/" .. 1  , 230 , 117 , 20 , ccc3(0xff,0xfb,0xd4) )
		setAnchPos( pageText , 240, 117, 0.5 )
		self.viewLayer:addChild(pageText)
	else
		totalPage = nil
	end
	refreshData()
	
	local function createList( )
		if scroll then
			scroll:getLayer():removeFromParentAndCleanup( true )
			scroll = nil
		end
		
		if self.curTitle then
			self.curTitle:removeFromParentAndCleanup(true)
			self.curTitle = nil
		end
		if self.curNumText then
			self.curNumText:removeFromParentAndCleanup(true)
			self.curNumText = nil
		end
		local textPath , str
		if curType == "friend" then
			textPath = PATH .. "cur_friend.png"
			str = data.frd_count .. "/" .. data.frd_max 
--			addFriend:getLayer():setVisible( true )
		elseif curType == "enemy" then
--			addFriend:getLayer():setVisible( false )
			textPath = PATH .. "cur_enemy.png"
			str = data.enermy_count .. "/" .. data.enermy_max 
		end
		self.curTitle = display.newSprite( textPath , 260 , 704 , 0 , 0 ) 
		self.listLayer:addChild( self.curTitle )	--当前好友/当前仇人
		self.curNumText = display.strokeLabel( str , 350 , 705 , 20 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , {
					dimensions_width = 83 ,
					dimensions_height = 24,
					align = 1
				}) 
		self.listLayer:addChild( self.curNumText )	--当前好友
		
		
		refreshData()
		
		local scrollX , scrollY , scrollWidth , scrollHeihgt
		scrollX			= 15
		scrollY			= isPaging and 155 or 105
		scrollWidth		= 450
		scrollHeihgt	= isPaging and 530 or 580
		
		if heightType == 1 then
			scrollY 		= 155
			scrollHeihgt 	= 392
		elseif heightType == 2 then
			scrollY 		= 155
			scrollHeihgt 	= 525
		end
		
		scroll = KNScrollView:new( scrollX , scrollY , scrollWidth , scrollHeihgt , 5 )
		for i = 1 , ( isPaging and alonePageNum or #curData ) do
			local itemData = curData[ ( curPage - 1 ) * alonePageNum + i ]
			if itemData then
				local tempItem = self:listCell( { data = itemData , type = curType , parent = scroll , index = ( curPage - 1 ) * alonePageNum + i } )
				scroll:addChild(tempItem, tempItem )
			end
		end
		scroll:alignCenter()
		self.listLayer:addChild( scroll:getLayer() )
	end
	
	--翻页按钮
	if isPaging then
		local pre = KNBtn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
			scale = true,
			flipX = true,
			callback = function()
				if curPage > 1 then
					curPage = curPage - 1
					createList( curType )
				end
			end
		})
		self.listLayer:addChild(pre:getLayer())
		local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
			scale = true,
			callback = function()
				if curPage < totalPage then
					curPage = curPage + 1
					createList( curType )
				end
			end
		})
		self.listLayer:addChild(next:getLayer())
	end
	
	local startX,startY = 10,690
	if heightType == 1 then startX,startY = 10 , 556 end
	
	group = KNRadioGroup:new()
	for i = 1, #listConfig do
		local temp = KNBtn:new( COMMONPATH.."tab/", {"tab_star_normal.png","tab_star_select.png"} , startX , startY , {
			disableWhenChoose = true,
			upSelect = true,
			id = listConfig[i][1],
			front = { LISTPATH..listConfig[i][1]..".png" , LISTPATH..listConfig[i][2]..".png"},
			callback=
			function()
				curType = listConfig[i][1]
				curPage = 1
				createList( listConfig[i][1] )
			end
		},group)
		self.tabLayer:addChild( temp:getLayer() )
		startX = startX + temp:getWidth() + 12
	end
	group:chooseById( curType , true )	--激活的选项
	createList()
	
	local findBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" , "long_btn_grey.png" } , 15 , 109 , 
						{
							front = PATH .. "find_player_text.png" , 
							callback = 
							function()
								self:findFriend()
							end
						})
	self.listLayer:addChild( findBtn:getLayer() )
	self.listLayer:addChild( display.newSprite( PATH .. "blessing.png" , 345 , 102 , 0 , 0 ) )			--祝福
	self.listLayer:addChild( display.strokeLabel( data.wishto_count .. "/" .. data.wishto_max , 415 , 127 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )		--祝福
	self.listLayer:addChild( display.strokeLabel( data.wishfrom_count .. "/" .. data.wishfrom_max , 415 , 104 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )	--被祝福
	
	self.tabLayer:addChild( display.newSprite( COMMONPATH.."tab_line.png"  , 6 , startY - 5 , 0 , 0 ) )
end
--生成列表item
function M:listCell( params )
	params = params or {}
	local type = params.type or 0 
	local data = params.data or {}
	local index = params.index
	local parent = params.parent
	local ITEMPATH = PATH .. "gang_list/"
	
	local layer = display.newLayer()
	--背景
	local bg
	if type == "ranking" or type == "rank" then
		bg = KNBtn:new( COMMONPATH , { "item_bg.png" } ,  0 , 0 , 
			{
				parent = parent ,
				upSelect = true , 
--				priority = -140 , 
				callback=
				function()
				end
			}):getLayer()
		layer:addChild( bg )
	else
		local str = type == "task" and IMG_PATH .. "image/scene/activity_new/item_bg.png" or COMMONPATH .. "item_bg.png"
		bg = display.newSprite( str )
		setAnchPos(bg , 0 , 0) 
		layer:addChild( bg )
	end
	local titleElement , addX , addY
	
	local function createItem()
		--玩家头像
		local infoBg = display.newSprite(COMMONPATH .."sex" .. data.sex .. ".jpg")
		setAnchPos( infoBg , 14 , 24 )
		layer:addChild(infoBg)
		
		infoBg = display.newSprite(COMMONPATH.."role_frame.png")
		setAnchPos( infoBg , 13 , 21 )
		layer:addChild(infoBg)
		
		if data.viplv ~= 0 then
			layer:addChild( display.newSprite(  IMG_PATH.."image/scene/vip/v" .. data.viplv .. ".png" , 85 , 60 , 0 , 0 ) )
		end
		layer:addChild( display.strokeLabel( data.name , ( data.viplv ~= 0 and 125 or 85 ) , 64 , 20 , ccc3(0x4a,0x08,0x08) ) )
		layer:addChild( display.strokeLabel( "Lv:" .. data.lv , 250 , 64 , 20 , ccc3(0x4a,0x08,0x08) ) )
		--战力
		layer:addChild( display.strokeLabel( "战力: " .. data.ability , 85 , 30 , 20 , ccc3(0x88,0x1f,0x1c) ) ) 
		local isOnlineStr = tonumber( data.online ) == 0 and "不在线" or "在线"
		layer:addChild( display.strokeLabel( "当前: " .. isOnlineStr , 185 + 140  , 10 , 20 , ccc3(0x88,0x1f,0x1c) ) ) 
		
		layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" } , 351  , 50 , {
								front = PATH .. ( type == "friend" and "text_exchange.png"  or "text_operate.png") ,
								parent = parent , 
								callback = function()
									if type == "friend" then
										self:exchange( {data = data } )
									else
										self:enemyOperate( { data = data } )
									end
								end
								} ):getLayer())
		
		
	end
	
	createItem()
	
	layer:setContentSize( bg:getContentSize() )
	return layer
end
--查找好友
function M:findFriend( params )
	params = params or {}
	local layer = self:baseMask()
	layer:addChild( display.newSprite( COMMONPATH .. "tip_bg.png" , display.cx , 336 , 0.5 , 0 ) )
	layer:addChild( display.newSprite( PATH .. "find_player.png" , 52 , 536 , 0 , 0 ) )
	local inputText = KNInputText:new( { width = 365 , 
										height = 28 , 
										size = 20 , 
										defStr = "请输入要查找的完整昵称" , 
										existStr = nil ,
										defColor = ccc3( 0xff , 0xfb , 0xd4 ) , 
										inputColor = ccc3( 0x4d , 0x15 , 0x15 ) 
										} )
	setAnchPos( inputText:getLayer() , 60  , 500 )
	layer:addChild( inputText:getLayer() , 10 )
	layer:addChild( KNBtn:new( IMG_PATH .. "image/scene/gang/no_gang/" , {"input_name_bg.png"} , 48 , 477 , {
								priority = -131 ,
								callback = function()
									inputText:startInput()
								end
								} ):getLayer() )
	--确定
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 70 , 365 , {
								front = COMMONPATH .. "confirm.png" ,
								priority = -131 ,
								callback = function()
									local function addCallBack()
										local listConfig =  {{"friend","tab_friend"} ,  {"enemy","tab_enemy"} }
										local activity = "friend"
										self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Friend:get() , defaultPage = 1 } )
									end
									HTTP:call("friends","search",{ nick = inputText:getString() },{success_callback = 
										function()
											inputText:stopInput()
											layer:remove()
											if params.type == "talk" then 
												local curData =  DATA_OTHER:get("base")
												curData.uid = curData.touid
												params.backFun( curData )
											else
												local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
												display.getRunningScene():addChild( otherPalyerInfo:new( { addCallBackFun = addCallBack } ):getLayer() )
											end
										end})
								end
								} ):getLayer() )
	--取消
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 267 , 365 , {
								front = COMMONPATH .. "cancel.png" ,
								priority = -131 ,
								callback = function()
									inputText:stopInput()
									layer:remove()
								end
								} ):getLayer() )
	
	
end
--生成基本弹出背景图
function M:basePopup( titlePath , params )
	params = params or {}
	local x , y ,pointX , pointY = params[1] or 0 , params[2] or 0 ,  params[3] or 0 ,  params[4] or 0 
	local bg = display.newSprite( IMG_PATH .. "image/scene/mission/wipe_bg.png")
	local addX = 90
	local addY = 324
	
	local titleBg = display.newSprite( IMG_PATH .. "image/scene/mission/title_bg.png")
	setAnchPos(titleBg, addX , addY)
	bg:addChild(titleBg)
	
	local title = display.newSprite( titlePath )
	setAnchPos(title, addX - 24 , addY )
	bg:addChild(title)
	
	setAnchPos( bg , x , y ,pointX , pointY )
	return bg
end
--常用弹出界面
function M:baseMask( params )
	params = params or {}
	local isBackBtn = params.isShowBack or false--时否显示返回按钮
	local bgInfo = params.bgInfo or { path = COMMONPATH .. "tip_bg.png" ,  y = 336 }
	local titlePath = params.titlePath or nil	--是否有标题
	if titlePath then
		bgInfo.y = 250
	end
	local mask
	local layer = display.newLayer()
	layer:addChild( ( titlePath and self:basePopup( titlePath , { display.cx , bgInfo.y , 0.5 , 0 } ) or display.newSprite( bgInfo.path , display.cx , bgInfo.y , 0.5 , 0 ) ) )
	
	if isBackBtn then
		--退出界面
		layer:addChild( KNBtn:new( COMMONPATH , { "back_img.png" , "back_img_press.png" } , 30 , 545 , {
								priority = -131 ,
								callback = function()
									mask:remove()
								end
								} ):getLayer() )
	end
	
	setAnchPos( layer , 0 , display.height , 0 , 0 )
	transition.moveTo( layer , { time = 0.5 , y = 0 , easing = "BACKOUT"})
	
	mask = KNMask:new({ item = layer , priority = -130 })
	local scene = display.getRunningScene()
	scene:addChild( mask:getLayer() )
	
	function layer:remove()
		mask:remove()
	end

	return layer
end
--仇人操作
function M:enemyOperate( params )
	params = params or {}
	local data = params.data or {}
	local layer = self:baseMask( { isShowBack = true } )
	
	layer:addChild( display.strokeLabel( data.info , 98 , 480 , 24 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil  , {
											dimensions_width = 290 ,
											dimensions_height = 80,
											align = 0
											}) )
	layer:addChild( display.strokeLabel( "1.发起复仇可以与仇人进行战斗\n2.每日前五次复仇可获得银两奖励" , 110 , 410 , 18 , ccc3( 0xa7 , 0x1f , 0x1f ) , nil , nil  , {
											dimensions_width = 290 ,
											dimensions_height = 61,
											align = 0
											}) )
	--发起复仇
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 70 , 365 , {
								front = PATH .. "revenge.png" ,
								priority = -131 ,
								callback = function()
									if not isBagFull() then
										SOCKET:getInstance("battle"):call("friends" , "execute" , "execute" , { type = 2 , id = data.uid } )
									end
									layer:remove()
								end
								} ):getLayer() )
	--删除仇人
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 267 , 365 , {
								front = PATH .. "delete_enemy.png" ,
								priority = -131 ,
								callback = function()
									HTTP:call("friends","delenermy",{ id = data.uid },{success_callback = 
									function()
										KNMsg.getInstance():flashShow( "删除成功！" )
										local listConfig =  {{"friend","tab_friend"} ,  {"enemy","tab_enemy"} }
										local activity = "enemy"
										self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Friend:get() , defaultPage = 1 } )
									end})
									layer:remove()
								end
								} ):getLayer() )
end


--好友人数提示
function M:friendNumTip( params )
	params = params or {}
	local type = params.type
	local layer = self:baseMask( { isShowBack = true } )
	layer:addChild( display.strokeLabel( "玩家10级后每提升5级增加" .. ( type == "friend" and "1个好友" or "2个仇人" ) .. "上限" , 80 , 453 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil ,  {
											dimensions_width = 345 ,
											dimensions_height = 61,
											align = 1
											}) )
	--成为VIP
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 70 , 365 , {
								front = PATH .. "go_up.png" ,
								priority = -131 ,
								callback = function()
									HTTP:call("mission" , "get",{},{success_callback = function()
										layer:remove()
										switchScene("mission")
									end })
								end
								} ):getLayer() )
--	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 70 , 365 , {
--								front = IMG_PATH .. "image/scene/activity_new/become_vip.png" ,
--								priority = -131 ,
--								callback = function()
--									layer:remove()
--									switchScene("pay")
--								end
--								} ):getLayer() )
	--删除仇人
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 267 , 365 , {
								front = COMMONPATH .. "cancel.png" ,
								priority = -131 ,
								callback = function()
									layer:remove()
								end
								} ):getLayer() )
end
--好友交流界面
function M:exchange( params )
	params = params or {}
	local data = params.data or {}
	local curTempData =  DATA_Friend:get()
	local layer = self:baseMask( { isShowBack = true , titlePath = PATH .. "friend_exchange_title.png" } )
	local btnElement = {"text_private_char" , "text_pray" , "text_look_info" , "text_blessing" , "text_del_friend" ,   }
	for i = 1 , #btnElement do
		local tempBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" , "long_btn_grey.png"} , 100 + (i-1)%2 * 168 , 477 - math.floor( (i-1)/2 ) * 66  , {
								front = PATH .. btnElement[i] .. ".png" ,
								priority = -131 ,
								callback = function()
									if btnElement[i] == "text_private_char" then	--私聊
										if CHANNEL_ID == "tmsjIosAppStore" then
											KNMsg.getInstance():flashShow( "该功能暂未开放！" )
											return
										end
										local curTalk
										DATA_Info:setIsMsg( false )
										if DATA_Info:getIsOpen( ) then
											local talkLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/talk")
											curTalk = talkLayer:new( { type = "friend" , friendData = data } )
											local curScene = display.getRunningScene()
											curScene:addChild( curTalk:getLayer()  )
										else
											curTalk:remove()
										end
										
										DATA_Info:setIsOpen(  not DATA_Info:getIsOpen( ) )
									elseif btnElement[i] == "text_pray" then --祝福
										HTTP:call("friends","zhufu",{ id = data.uid },{success_callback = 
											function()
												KNMsg.getInstance():flashShow( "祝福成功！" )
												
												local listConfig =  {{"friend","tab_friend"} ,  {"enemy","tab_enemy"} }
												local activity = "friend"
												self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Friend:get() , defaultPage = 1 } )
											end})
									elseif btnElement[i] == "text_look_info" then	--查看信息 
										HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
											function()
												local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
												display.getRunningScene():addChild( otherPalyerInfo:new( { isFriend = true } ):getLayer() )
											end})
									elseif btnElement[i] == "text_blessing" then 	--切磋
										if not isBagFull() then
											SOCKET:getInstance("battle"):call("friends" , "execute" , "execute" , { type = 1 , id = data.uid } )
										end
									elseif btnElement[i] == "text_del_friend" then 	--删除好友
										local function delFun()
											HTTP:call("friends","delfrd",{ id = data.uid },{success_callback = 
												function(resultData)
													KNMsg.getInstance():flashShow( "删除成功！" )
													local listConfig =  {{"friend","tab_friend"} ,  {"enemy","tab_enemy"} }
													local activity = "friend"
													self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Friend:get() , defaultPage = 1 } )
												end})
										end
										KNMsg.getInstance():boxShow( "确认删除该好友吗?" ,{ 
																	confirmFun = delFun , 
																	cancelFun = function() end 
																	} )
									end
									layer:remove()
								end
								} )
		if curTempData.wishto_count >= curTempData.wishto_max and btnElement[i] == "text_pray" then
			tempBtn:setEnable( false )
		end
		layer:addChild(tempBtn:getLayer())
	end
	layer:addChild( display.strokeLabel( "1.祝福可使好友增加1点体力\n2.每日前五次切磋可获得银两奖励" , 100 , 272 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
											dimensions_width = 300 ,
											dimensions_height = 61,
											align = 0
											}) )


end
return M