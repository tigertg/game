--活动页面
local M = {}
local SCENETYPE
local NOGANG , SEEGANG , MEMBER , RANKING  , RANK , PRAY , APPOINT , APPLY , TASK , SHOP , HALL , DONATE , WARS , WARSMEBER , WARSRANK = 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 
local PATH = IMG_PATH .. "image/scene/gang/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNCheckBox = requires (IMG_PATH,"GameLuaScript/Common/KNCheckBox")
local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local KNSlider = requires(IMG_PATH, "GameLuaScript/Common/KNSlider")
local KNClock = requires(IMG_PATH, "GameLuaScript/Common/KNClock")
local baseElement = requires(IMG_PATH , "GameLuaScript/Scene/common/baseElement")
local data
local gangInfoTable , noticeText , energyText , tributeText
function M:new( params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	params = params or {}
	SCENETYPE = params.type or 0 
	
	
	-- 基础层
	this.baseLayer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.gangInfoLayer = nil		--帮派信息
	
	local bg = display.newSprite( COMMONPATH.."dark_bg.png" )
	setAnchPos( bg , 0 , 425 , 0 , 0.5 )
	this.baseLayer:addChild( bg )
	
	

	local function backFun()
		KNClock:removeTimeFun( "trends" )
		KNClock:removeTimeFun( "wars" )
		if SCENETYPE == SEEGANG or SCENETYPE == MEMBER or SCENETYPE == RANKING or SCENETYPE == PRAY or SCENETYPE == RANK or SCENETYPE == TASK or SCENETYPE == DONATE then
			switchScene("gang")
		elseif SCENETYPE == APPOINT or  SCENETYPE == APPLY or SCENETYPE == SHOP or SCENETYPE == WARS then
			switchScene("gang")
		elseif SCENETYPE == WARSMEBER  or SCENETYPE == WARSRANK then
			this:createWars()
		else
			switchScene("home")
		end
	end
	if DATA_Gang:isJoinGang() then
		if SCENETYPE == SEEGANG then
			this:seeGangList( )	--加入查看其它帮派列表
		else
			this:noGang()	--默认没有加入帮派前界面
		end
		-- 显示公用层 底部公用导航以及顶部公用消息
		this.infoLayer = InfoLayer:new("gang", 0, { title_text = PATH.."gang_text2.png", tail_hide = true , closeCallback = backFun })
	else
		this:createHall()
		this.infoLayer = InfoLayer:new("gang", 0 , { title_text = PATH.."gang_text2.png", tail_hide = true , closeCallback = backFun })
		this:refreshGangInfo( )
	end
	
	this.baseLayer:addChild( this.infoLayer:getLayer() )	
	
	return this.baseLayer 
end
function M:refreshGangInfo( params )
	params = params or {}
	local type = params.type or 0
	
	local isRefresh = params.refresh or false	
	
	--是否强制作刷新
	if  self.gangInfoLayer and isRefresh then
		self.gangInfoLayer:removeFromParentAndCleanup( true )
		self.gangInfoLayer = nil
	end
	
	if type == 3 then return end
		
	
	
	local HALLPATH = PATH .. "hall/"
	local infoData = DATA_Gang:get( "list" )
	local infoElement = {
			infoData.name ,																											--帮派名称
			"Lv" .. infoData.lv ,																									--帮派等级
			infoData.count .. "/" .. infoData.count_max ,																			--人数
			infoData.id ,																											--帮派ID
			infoData.chieftains_name ,																								--帮主
			infoData.sum_ability ,																									--战力
			( infoData.tribute>10000 and math.floor( infoData.tribute/10000) .. "万" or infoData.tribute ) ,							--帮贡
			( infoData.funds>10000 and math.floor( infoData.funds/10000) .. "万" or infoData.funds ) ,								--资金
			}
	--人物信息层
	local layer
	
	local function refreshInfo()
		energyText:setString( infoData.usertribute_v )
		tributeText:setString( infoData.usertribute )
		
		if type == 0 then
			for i = 1 , #gangInfoTable do
				gangInfoTable[i]:setString( infoElement[i] )
			end
		end
	end

	if not self.gangInfoLayer then
		
		self.gangInfoLayer = display.newLayer()
		self.baseLayer:addChild( self.gangInfoLayer , 10 )
		
		layer = display.newLayer()

		local bgPath , bgX = HALLPATH .. "notice_bg.png" , 561
		if type == 0 then
			bgPath = bgPath
			bgX = bgX
			
			layer:addChild(  display.newSprite( bgPath , display.cx , bgX , 0.5 , 0 ) )
			layer:addChild(  display.newSprite(HALLPATH .. "notice_left.png" , 90 , 650 ) )
			layer:addChild(  display.newSprite(HALLPATH .. "notice_right.png" , 320 , 650 ) )
			layer:addChild(  display.newSprite(HALLPATH .. "notice_text_bg.png" , display.cx , 440 + 75 ) )
			layer:addChild(  display.newSprite(HALLPATH .. "notice_title.png" , 40 , 440 + 75 ) )
			
			layer:addChild(  display.newSprite(HALLPATH .. "my_bg.png" , display.cx , 450 , 0.5 ) )
			layer:addChild(  display.newSprite(HALLPATH .. "my_total.png" , 30 , 450 , 0 ) )	--我的总帮威
			layer:addChild(  display.newSprite(HALLPATH .. "my_usable.png" , 256 , 450 , 0 ) )	--可用帮威
			
			
		
			energyText = display.strokeLabel( ( infoData.usertribute_v > 10000 and math.floor(infoData.usertribute_v/10000) .. "万" or infoData.usertribute_v ) , 400 , 440 , 20 , ccc3(112 , 236 , 241) , 2 )										--可用帮威
			tributeText = display.strokeLabel( ( infoData.usertribute > 10000 and math.floor(infoData.usertribute/10000) .. "万" or infoData.usertribute )  , 155 , 440 , 20 , ccc3(177 , 245 , 97) , 2 )										--帮威
			layer:addChild( tributeText ) 
			layer:addChild( energyText )
													
			
			layer:addChild( KNBtn:new( COMMONPATH , {"tribute.png"} , 125 , 435 , {scale = true , callback = function()KNMsg.getInstance():flashShow("你的历史总帮威是" ..infoData.usertribute ) end}):getLayer() )
			layer:addChild( KNBtn:new( PATH , {"usertribute_v.png"} , 370 , 435 , {scale = true , callback = function()KNMsg.getInstance():flashShow("你的可用帮威是" ..infoData.usertribute_v ) end}):getLayer() )
			
			
			--生成公告文字内容
			noticeText = display.strokeLabel( infoData.notice , 70 , 405 + 75 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 330,
					dimensions_height = 70,
					align = 0
				})
			layer:addChild( noticeText )
			--编辑公告
			local isGangMan =  infoData.userstate == 100
			local editBtn = KNBtn:new(COMMONPATH , isGangMan and { "btn_ver.png" , "btn_ver_pre.png" } or { "btn_ver_grey.png" } , 415 , 405 + 75 , {
				front = HALLPATH .. "edit_notice.png",
--				priority = -131,	
				callback = function()
					
					if isGangMan and SCENETYPE == HALL then
						local function confirmFun(str)
							HTTP:call("alliance","notice",{ notice = str },{success_callback = 
							function(data)
								infoData = DATA_Gang:get( "list" )
								noticeText:setString( infoData.notice )
							end})	
						end
						self:inputBox({confirmFun = confirmFun , isFind = false })
					end
				end
			}):getLayer()
			editBtn:setScale(0.8)
			layer:addChild( editBtn )
			
			--帮派基本信息
			local addX , addY 
			gangInfoTable = {}
			for i = 1 , #infoElement do
				addX = 125 + (( i - 1 ) % 2 ) * 230
				addY = 694 - math.floor( ( i - 1 ) / 2 ) * 38
				gangInfoTable[i] = display.strokeLabel( infoElement[i] , addX , addY , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
						dimensions_width = 200,
						dimensions_height = 25,
						align = 0
					})
					
				layer:addChild( gangInfoTable[i] )
			end
		else
			--修改后无用样式
--			bgPath = HALLPATH .. "notice_bg2.png"
--			bgX = 680
--			layer:addChild(  display.newSprite( bgPath , display.cx , bgX ) )
		end
		
		self.gangInfoLayer:addChild( layer )
	else
		refreshInfo()
	end
	
end
--祈福界面
function M:createPray()
	SCENETYPE = PRAY
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_pray_title.png" )
	
	local PRAYPATH = PATH .. "pray/"
	local layer = display.newLayer()
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
	end
	
	local data = DATA_Gang:get("pray")
	local layer = display.newLayer()


	layer:addChild(display.newSprite(PRAYPATH .. "bg.png" , display.cx , 109 , 0.5 , 0 ) )
	layer:addChild(display.newSprite(PRAYPATH .. "trends_title.png" , display.cx , 727 ) )
	layer:addChild(display.newSprite(PRAYPATH .. "tip.png" , display.cx , 580) )
	layer:addChild(display.newSprite(PRAYPATH .. "frame.png" , display.cx , 450) )
	layer:addChild(display.newSprite(PRAYPATH .. "cost.png" , 110 , 190) )
	layer:addChild(display.newSprite(COMMONPATH .. "gold.png" , 350 , 190) )
	layer:addChild(display.newSprite(COMMONPATH .. "gold.png" , 170 , 190) )
	layer:addChild(display.newSprite(PRAYPATH .. "surplus.png" , 288 + 25 , 190) )
	layer:addChild(display.newSprite(PRAYPATH .. "award_frame.png" , display.cx , 282) )
	for i = 1 , 4 do
		layer:addChild(display.newSprite(SCENECOMMON .. "skill_frame2.png" , 108 + (i-1) * 87 , 278) )
	end
	local trendsText = {}
	for i = 1 , 3 do
		trendsText[i] = display.strokeLabel( "" , 40 , 708 - i * 25 , 20 ,ccc3(0x2c , 0x00 , 0x00 ) )
		layer:addChild( trendsText[i] )
	end 
	
	local delay = nil
	local function refreshTrends()
		if not delay or delay > 10 then
			delay = 0
			HTTP:call("alliance","cliffordmovement",{ },{ no_loading = true , success_callback =
			function( tempData )
				for i = 1 , #trendsText do
					local curData = tempData.clifford_movement[i] or { content = ""  }
					local str = curData.content 
					trendsText[i]:setString( str )
				end
			end})
		end
		delay = delay + 1
	end
	
	KNClock:addTimeFun( "trends" , refreshTrends )
	
	refreshTrends()
	
	
	local function showAward( index , awards )
		local gold = awards.award_gold
		local silver = awards.award_silver
		layer:addChild( display.newSprite(COMMONPATH .. ( gold == 0 and "silver.png" or "gold.png" ) , 330 , 567 - index * 34 ) )
		layer:addChild( display.strokeLabel( ( gold == 0 and silver or gold)  , 345 ,  557 - index  * 34 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
	end
	
	for i = 1 , 5 do
		layer:addChild(display.newSprite(IMG_PATH .. "image/scene/battle/hero_info/line_long.png" , display.cx , 552 - i * 34) )
		layer:addChild(display.newSprite( PRAYPATH .. "other_tip.png" , display.cx - 50, 567 - ( i + 1 ) * 34) )
		layer:addChild( display.strokeLabel( 5 - i , 115 + 40  ,  557 - ( i + 1 ) * 34 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
		showAward( i + 1  , data.clifford_award[ (i + 1) ] )
		if i == 1 then
			layer:addChild(display.newSprite( PRAYPATH .. "highest_tip.png" , display.cx - 50, 567 - i * 34) )
			showAward( i , data.clifford_award[ i ] )
		end
	end
	layer:addChild( display.strokeLabel( data.clifford_money , 187 , 180 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
	--剩余黄金
	local surplusText = display.strokeLabel( DATA_Account:get("gold") , 370 , 180 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
	layer:addChild( surplusText ) 
	
	
	
	
	
	
	--动画部分处理
	local maskLayer = WindowLayer:createWindow()	
	setAnchPos(maskLayer , 0 , 252 , 0 , 0)
	maskLayer:setContentSize(CCSizeMake(480,53))
	layer:addChild( maskLayer )
	
	local prayRecord = {}
	local curGroup = 1
	local isOver = false
	local function createInfo( isFirst )
		if not isFirst then
			for j = 0 , 3 do
				transition.stopTarget( prayRecord[curGroup][j] )
				prayRecord[curGroup][j]:removeFromParentAndCleanup(true)
				prayRecord[curGroup][j] = nil
			end
			prayRecord[curGroup] = nil
			
			prayRecord[curGroup] = display.newSprite( PRAYPATH .. ( data.rands and ("text".. data.rands[curGroup+1]) or ("init" .. curGroup ) )  .. ".png" , 108 + curGroup * 87 , 25)
			maskLayer:addChild( prayRecord[curGroup] )
			curGroup = curGroup + 1
		else
			for i = 0 , 3 do
				if prayRecord[i] then
					prayRecord[i]:removeFromParentAndCleanup(true)
					prayRecord[i] = nil
				end
				prayRecord[i] = display.newSprite( PRAYPATH .. ( data.rands and ("text".. data.rands[i+1]) or ("init" .. i ) )  .. ".png" , 108 + i * 87 , 25)
				maskLayer:addChild( prayRecord[i]  )
			end
		end
		
	end
	createInfo(true)
	
--		if isOver and group == curGroup then
--			for j = 0 , 3 do
--				transition.stopTarget( prayRecord[curGroup][j] )
--				if j ~= data.rands[curGroup] then
--					prayRecord[curGroup][j]:removeFromParentAndCleanup(true)
--					prayRecord[curGroup][j] = nil
--				end
--			end
--			curGroup = curGroup + 1
--			curGroup = curGroup>=4 and  4 or curGroup
--			prayRecord[curGroup] = prayRecord[curGroup][data.rands[curGroup]]
--		end
	local speed = 0.2
	local isData = false		--是否接收到数据
	local downTime = 3	--倒计时
	local function startAction( group )
		if group then
			local addX = 76 + group * 87
			--计算Y坐标
			local function countY( i ) 
				local tempY = 50
				data = DATA_Gang:get("pray")
--				data.rands = { 1 , 3 , 1 , 1 }--星照星星
				if data.rands then
					tempY = ( isOver and ( group == curGroup ) and ( i < data.rands[curGroup]) ) and ( i == data.rands[curGroup] and 20 or -60 ) or 50 
				end
				return tempY
			end
			
			local function chekeOver( i )
				setAnchPos( prayRecord[group][i] , 76 + group * 87 , -60 , 0 , 0 )
				if i == 2 then
					startAction(group) 
				end
			end
			
			transition.moveTo( prayRecord[group][0] , { delay = 0	,			time = speed , y = countY(0) , onComplete = function() chekeOver(0)  end })
			transition.moveTo( prayRecord[group][1] , { delay = speed/2 , 		time = speed , y = countY(1) , onComplete = function() chekeOver(1)  end })
			transition.moveTo( prayRecord[group][2] , { delay = speed/2 * 2 ,	time = speed , y = countY(2) , onComplete = function() chekeOver(2)  end })
			transition.moveTo( prayRecord[group][3] , { delay = speed/2 * 3 , 	time = speed , y = countY(3) , onComplete = function() chekeOver(3)  end })
		else
			--初始化动画
			downTime = 3
			for i = 0 , 3 do
				if prayRecord[i] then
					prayRecord[i]:removeFromParentAndCleanup(true)
					prayRecord[i] = nil
				end
				prayRecord[i] = {}
				
				for j = 0 , 3 do
					prayRecord[i][j] = display.newSprite(PRAYPATH .. "text".. j .. ".png" )
					setAnchPos( prayRecord[i][j] , 76 + i * 87 , -60 , 0 , 0 )
					maskLayer:addChild( prayRecord[i][j] )
				end

				startAction(i)
			end
		end
		 
		 
		 
	end
	
	
	
	
	local mask
	local function overAction(  )
		downTime = downTime - 1
		isOver = downTime <= 0
		if ( ( not isOver ) and ( not isData ) ) then
			return
		end
		speed = speed * 2
		data = DATA_Gang:get("pray")
		createInfo()
		
		if curGroup < 4 then
			return
		end
		
		Clock:removeTimeFun( "prayAction" )
	
		
		mask:remove()
		surplusText:setString( DATA_Account:get("gold") )	--刷新剩余黄金数量
		self:refreshGangInfo( { type = 3 , refresh = true } )
		
		
		local totalNum = 0
		if table.concat(data.rands) == "0123" then
			totalNum = 5--出现福星高照  取最高奖励数据，1为最高奖励
		else
			for i = 1 , #data.rands do
				if data.rands[i] == 0 then
					totalNum = totalNum + 1
				end
			end
		end
		local awardData = data.clifford_award[ 6 - totalNum ]
		KNMsg.getInstance():flashShow(  "恭喜您获得" .. ( awardData.award_gold == 0 and  awardData.award_silver .. "银两" or awardData.award_gold .. "黄金" )   )
	end
	
	--祈福
	local prayBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 168 , 116 , {
		front = PRAYPATH .. "pray_text.png",
--		priority = -131,	
		callback = function()
			if countGold(data.clifford_money ) then
				mask = KNMask:new({ priority = -133 ,	opacity = 0 })
				local scene = display.getRunningScene()
				scene:addChild( mask:getLayer() )
				Clock:addTimeFun("prayAction" , overAction )
				
				speed = 0.2
				curGroup = 0
				downTime = 3
				isOver = false
				isData = false
				
				local tempData = DATA_Gang:get("pray")
				tempData.rands = nil
				DATA_Gang:set_type("pray" , tempData)
				
				startAction()
				HTTP:call("alliance","sendclifford",{ },{success_callback =function() isData = true end})
			end
		end
	}):getLayer()
	layer:addChild( prayBtn )
	
	
	self.viewLayer:addChild(layer)
end
--帮派大厅
function M:createHall()
	local HALLPATH = PATH .. "hall/"
	SCENETYPE = HALL
	local layer = display.newLayer()
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
	end
	--权限
	local privilegeBtn = KNBtn:new( HALLPATH , { "privilege.png" , "privilege_pre.png" } , 15 , 360 , {
		priority = -131,	
		callback = function()
			HTTP:call("alliance", "get", {},{success_callback = 
			function()
				self:lookPrivilege()
			end})
		end
	}):getLayer()
	layer:addChild( privilegeBtn )
	
	local btnConfig = {
		{flag = "donate" },
		{flag = "pray" },
		{flag = "gang_wars" },
		{flag = "task" },
		{flag = "ranking" },
		{flag = "shop" },
	}
	for i = 1 , #btnConfig do
		local tempBtn = KNBtn:new(COMMONPATH , 
		{ "btn_bg_red.png" , "btn_bg_red_pre.png"  , "btn_bg_red2.png"} , 
		74 + math.floor( (i-1)/3 ) * 188 , 305 - (i-1)%3 * 74 ,
		{
			front = HALLPATH .. btnConfig[i].flag .. ".png" , 
			priority = -131,	
			callback = 
			function()
				if btnConfig[i].flag == "task" then
					HTTP:call("alliance","task",{ },{success_callback =
					function()
						self:createTask()
					end})
				elseif btnConfig[i].flag == "donate" then
					HTTP:call("alliance","task",{ },{success_callback =
					function()
						self:createDonate()
					end})
				elseif btnConfig[i].flag == "ranking" then
					HTTP:call("alliance","totalrank",{ },{success_callback = 
					function()
						self:totalRank()
					end
					})
				elseif btnConfig[i].flag == "shop" then
					HTTP:call("alliance","shop",{ },{success_callback = 
					function()
						self:createShop()
					end
					})
				elseif btnConfig[i].flag == "gang_wars" then
--					self:createWars()
					KNMsg.getInstance():flashShow( "帮战正在研发中，预计在9月中下旬开放，敬请期待！" )
				elseif btnConfig[i].flag == "pray" then
					if DATA_Gang:get( "pray" ) then
						SCENETYPE = PRAY
						self:refreshGangInfo( { type = 3 , refresh = true } )
						self:createPray()
					else
						HTTP:call("alliance","clifford",{ },{success_callback = 
						function()
							self:createPray()
						end
						})
					end

				end
			
			end
		}):getLayer()
		layer:addChild( tempBtn )
	end
	
	
	
	self.viewLayer:addChild(layer)
	self.baseLayer:addChild( self.viewLayer )
	
	
	
	
	local btn_images = {"aide.png" , "aide_press.png"}
	local curTalk
	if checkOpened("talk") ~= true then btn_images = {"aide_press.png"} end
	local temp = KNBtn:new( IMG_PATH .. "image/scene/chat/"  , {"talk_flag1.png"} , 410 , 370 , {
		scale = true ,
		front =  IMG_PATH .. "image/scene/chat/talk_flag.png" , 
		callback = function()
			DATA_Info:setIsMsg( false )
			if DATA_Info:getIsOpen( ) then
				local talkLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/talk")
				curTalk = talkLayer:new( {type = "gang" } )
				local curScene = display.getRunningScene()
				curScene:addChild( curTalk:getLayer()  )
			else
				curTalk:remove()
			end
			
			DATA_Info:setIsOpen(  not DATA_Info:getIsOpen( ) )
		end
	})
	
	temp:getLayer():setScale(0.7)
	layer:addChild(temp:getLayer())
	DATA_Info:addActionBtn( "gang" , temp )
	if CHANNEL_ID == "tmsjIosAppStore" then
		temp:getLayer():setVisible( false )
		temp:setEnable(false)
	end
	
end
--总榜
function M:totalRank( )
	SCENETYPE = RANK
	self.gangInfoLayer:setVisible(false)
	
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_total.png" )
	
	local listConfig =  {{"ability","tab_ability"} ,  {"tribute","tab_tribute"} , {"rank","tab_rank"}  }
	local activity = "ability"
	self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Gang:get( "gang_rank" ) , defaultPage = 1 } )
end
--成员事件
function M:gangMember( )
	SCENETYPE = MEMBER
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_text2.png" )
	--查看帮派成员列表
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
	end
	
	local data = { event_movement = DATA_Gang:get("event_movement") , info = DATA_Gang:get("info") }
	local listConfig =  {  {"info","tab_info"} , {"event_movement","tab_event_movement"}  } 
	self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = "info" , data = data , defaultPage = 1 } )
end
--生成基本弹出背景图
function M:basePopup( titlePath )
	local bg = display.newSprite( IMG_PATH .. "image/scene/mission/wipe_bg.png")
	local addX = 90
	local addY = 324
	
	local titleBg = display.newSprite( IMG_PATH .. "image/scene/mission/title_bg.png")
	setAnchPos(titleBg, addX , addY)
	bg:addChild(titleBg)
	
	local title = display.newSprite( titlePath )
	setAnchPos(title, addX - 24 , addY )
	bg:addChild(title)
	
	return bg
end
--未加 入帮派时的界面
function M:noGang()
	local NOPATH = PATH .. "no_gang/"
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
	end
	
	local bg = display.newSprite( NOPATH .. "bg.jpg" )
	setAnchPos(bg , display.cx , display.cy , 0.5 , 0.5)
	self.viewLayer:addChild( bg )
	
	--提示背景
	local tipBg = display.newSprite( NOPATH .. "tip_bg.png" )
	setAnchPos(tipBg , display.cx , 180 , 0.5 )
	self.viewLayer:addChild( tipBg )
	--提示文字
	local str = "加入帮会可获额外体力,还能购买宝石和高星级套装,赶快去加入帮会吧！"
	local tipText = display.strokeLabel( str , 50 , 180 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
			dimensions_width = 380,
			dimensions_height = 80,
			align = 0
		})
	self.viewLayer:addChild( tipText )
	
	--创建帮派
	local createGangLayer , createMask --创建帮派层
	local function createGang()
		if createGangLayer then
			createGangLayer:removeFromParentAndCleanup( true )
			createGangLayer = nil
		end
		createGangLayer = display.newLayer()
		
		
		local bg = self:basePopup( NOPATH .. "create_gang_title.png" )
		setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
		createGangLayer:addChild(bg)
		
		--帮派名字提示
		bg = display.newSprite( NOPATH .. "name_tip.png")
		setAnchPos(bg, display.cx, 570, 0.5 , 0.5 )
		createGangLayer:addChild(bg)
		
		local tempText = display.strokeLabel( "（6个汉字以内）", 330 , 470 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
			dimensions_width = 120,
			dimensions_height = 25,
			align = 0
		})
		createGangLayer:addChild( tempText )
		
		local inputGangName = CCTextFieldTTF:textFieldWithPlaceHolder("请输入帮派名称" , FONT , 20)
		display.align( inputGangName , display.CENTER_LEFT , 0 , 0)
		inputGangName:setColor( ccc3( 0xff , 0xfb , 0xd4 ) )
		inputGangName:setColorSpaceHolder( ccc3( 0x4d , 0x15 , 0x15 ) )
		
		local inputGangNameMask = WindowLayer:createWindow()
		inputGangNameMask:setAnchorPoint( ccp(0 , 0.5) )
		inputGangNameMask:setContentSize( CCSizeMake(350 , 28) )
		inputGangNameMask:setPosition( 62 , 525 )
		inputGangNameMask:addChild( inputGangName )
		createGangLayer:addChild( inputGangNameMask , 10 )
		
		local inputBg = KNBtn:new( NOPATH , {"input_name_bg.png"} , 48 , 500 , {
			priority = -140 , 
			callback = function()
				inputGangName:attachWithIME()
			end
		}):getLayer()
		createGangLayer:addChild(inputBg)
		
		--创建需求
		bg = display.newSprite( NOPATH .. "create_need.png")
		setAnchPos(bg, 60, 450 )
		createGangLayer:addChild(bg)
		
		local isMeet = 0 
		local completeY = 416
		local interval = 30
		local function addConfirmFlag( index )
			isMeet = isMeet + 1
			local completeFalg = display.newSprite( NOPATH .. "complete_flag.png")
			setAnchPos( completeFalg , 70, completeY  - ( index - 1 ) *  interval  )
			createGangLayer:addChild( completeFalg )
		end
		
		local needTable = {
							{ curValue = DATA_User:get("lv") , 						maxValue = 15 , 		tip = "1.等级达到15级(" } , 
							{ curValue = DATA_Account:get("silver") ,				maxValue = 300000 , 	tip = "2.银两30万("} , 
							{ curValue = DATA_Bag:getTypeCount("prop", "16020") ,	maxValue = 1 , 			tip = "3.建帮派令1个(" },}
							
		for i = 1 , #needTable do
			local str = needTable[i].tip .. needTable[i].curValue .. "/" .. needTable[i].maxValue .. ")"
			local tempText = display.strokeLabel( str, 110 , completeY -  ( i - 1 ) * interval , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
				dimensions_width = 300,
				dimensions_height = 25,
				align = 0
			})
			createGangLayer:addChild( tempText )
			
			if needTable[i].curValue >= needTable[i].maxValue then
				addConfirmFlag( i )
				tempText:setColor(  ccc3( 0xef , 0x00 , 0x00 )  )
			end
		end
		
		--返回按钮
		local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
			scale = true,
			priority = -131,	
			callback = function()
				inputGangName:detachWithIME()
				createMask:remove()
				createGangLayer = nil
				
			end
		})
		createGangLayer:addChild(cancelBtn:getLayer())
		
		--确认创建按钮
		local cancelBtn = KNBtn:new(COMMONPATH,
			isMeet >= 3 and {"btn_bg_red.png","btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
			display.cx - 73 , 300 ,
			{
				front = NOPATH .. "confirm_create.png",
				priority = -131,	
				callback = function()
					if isMeet >= 3 then
						local gangNameStr = inputGangName:getString()
						if gangNameStr == "" then
							KNMsg.getInstance():flashShow( "帮派名字不能为空" )
							return
						end
						
						if string.len( gangNameStr ) <= 18 then
							local propId = DATA_Bag:cidByData("16020" , "id" )
							HTTP:call("alliance","_create",{ name = gangNameStr , id = propId },{success_callback = 
							function(data)
								inputGangName:detachWithIME()
								switchScene( "gang" )	
							end})
						else
							KNMsg.getInstance():flashShow( "帮派名字过长，请修改！" )
						end
					end
				end
			}):getLayer()
		createGangLayer:addChild(cancelBtn)
		
		local function onTouch(eventType , x , y)
			inputGangName:detachWithIME()
		end
		createGangLayer:setTouchEnabled( true )
		createGangLayer:registerScriptTouchHandler(onTouch , false , -140 , true)
		
		local scene = display.getRunningScene()
		createMask = KNMask:new({ item = createGangLayer })
		scene:addChild( createMask:getLayer() )
		
		setAnchPos( createGangLayer , 0 , display.height , 0 , 0 )
		transition.moveTo( createGangLayer , { time = 0.5 , y = 0 , easing = "BACKOUT"})
	end
	
	--创建帮派
	local createBtn = KNBtn:new( COMMONPATH, {"btn_bg_red.png","btn_bg_red_pre.png"}, 50, 135, 
			{
				front = NOPATH .. "create_btn.png",
				callback = createGang
			}):getLayer()
	self.viewLayer:addChild( createBtn )
	
	
	--加入帮派
	local joinBtn = KNBtn:new( COMMONPATH, {"btn_bg_red.png","btn_bg_red_pre.png"}, 286, 135, 
			{
				front = NOPATH .. "join_btn.png",
				callback = 
				function()
					HTTP:call("alliance","rank",{ name = gangNameStr},{success_callback = 
					function()
						switchScene("gang" , { type = 1 } )
					end})
				end
			}):getLayer()
	self.viewLayer:addChild( joinBtn )
	
	self.baseLayer:addChild( self.viewLayer )	
end
--申请界面
function M:applyFun()
	SCENETYPE = APPLY
	GLOBAL_INFOLAYER:refreshTitle( PATH .. "apply_title.png")
	local data = { applylist = DATA_Gang:get("applylist") }
	local listConfig =  {} 
	self:createList( { listConfig = listConfig , defaultType = "applylist" , data = data , defaultPage = 1 } )
end

--输入框
function M:inputBox( params )
	params = params or {}
	local confirmFun = params.confirmFun or function()end
	local cancelFun = params.cancelFun or function()end
	local isFind = params.isFind
	local layer = display.newLayer()
	local mask
	
	
	local findBg = display.newSprite( COMMONPATH .. "tip_bg.png" )
	setAnchPos(findBg , display.cx , 337 , 0.5 )
	layer:addChild( findBg )
	
	
	local findTipSp = display.newSprite(PATH .. "gang_list/" .. ( isFind and "find_tip.png" or "input_notice_title.png" ) )
	setAnchPos(findTipSp , 52 , 538 )
	layer:addChild( findTipSp )
	
	if not isFind then
		layer:addChild(display.strokeLabel( "(50个汉字以内)" , 300 , 440 , 18 , ccc3(0x2c,0x00,0x00) )) 
	end
	
	
	local inputGangName = CCTextFieldTTF:textFieldWithPlaceHolder( isFind and "请输入帮派ID" or "请输入要编辑的内容" , FONT , 20)
	display.align( inputGangName , display.CENTER_LEFT , 0 , 0)
	inputGangName:setColor( ccc3( 0xff , 0xfb , 0xd4 ) )
	inputGangName:setColorSpaceHolder( ccc3( 0x4d , 0x15 , 0x15 ) )
	
	local inputGangNameMask = WindowLayer:createWindow()
	inputGangNameMask:setAnchorPoint( ccp(0 , 0.5) )
	inputGangNameMask:setContentSize( CCSizeMake(370 , 28) )
	inputGangNameMask:setPosition( 55 , 490)
	inputGangNameMask:addChild( inputGangName )
	layer:addChild( inputGangNameMask , 10 )
	
	local inputBg = KNBtn:new(PATH .. "no_gang/", {"input_name_bg.png"} , 47 , 465 , {
		priority = -142 , 
		callback = function()
			inputGangName:attachWithIME()
		end
	}):getLayer()
	layer:addChild(inputBg)
	
	
	local confirmBtn = KNBtn:new(COMMONPATH , { "btn_bg.png" } , 67 , 364 , {
					front =  COMMONPATH .. "confirm.png" ,
					priority = -142,
					scale = true,
					callback =
					function()
						local gangNameStr = inputGangName:getString()
						confirmFun( gangNameStr )
						inputGangName:detachWithIME()
						mask:remove()
					end
				}):getLayer()
	layer:addChild(confirmBtn)
	local cancelBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" } , 327 , 364 , {
					front = COMMONPATH .. "cancel.png",
					priority = -142,
					scale = true,
					callback = 
					function()
						inputGangName:detachWithIME()
						mask:remove()
						cancelFun()
					end,
				}):getLayer()
	layer:addChild(cancelBtn)
	
	
	setAnchPos( layer , 0 , -display.height )
	transition.moveTo( layer , { time = 0.5 , easing = "BACKOUT" , y = 0 })
	
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -141 })
	scene:addChild( mask:getLayer() )
end
--未加入帮派前查看其它帮派列表
function M:seeGangList()
	local listConfig =  { {"list","tab_list"} , {"ranking","tab_ranking"} }
	local activity = "list"
	if SCENETYPE == RANKING then
		activity = "ranking"
	end
	self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Gang:get("rank") , defaultPage = 1 } )
	--搜索帮会
	local findBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" } , 
		display.width - 120 , 690 ,
		{
			front = PATH .. "gang_list/" .. "find_gang.png" ,
			callback=function()
				local function confirmFun( str )
					if str and str ~= "" then
						--搜索帮派
						HTTP:call("alliance","getallianceinfo",{ id = str },{success_callback = 
						function(resultData)
							self:lookInfo( { type = 1 , data = resultData or {} } )
						end})
					else
						KNMsg.getInstance():flashShow( "帮派ID不能为空" )
					end
				end
				self:inputBox({confirmFun = confirmFun , isFind = true })
			end
		}):getLayer()
	self.viewLayer:addChild( findBtn )
end
--重置任务
function M:resetLayout( params )
	params = params or {}

	local layer = display.newLayer()
	local mask
	local TASKPATH = PATH .. "task/"
	local curData = DATA_Gang:get("task").task
	local bg = self:basePopup( PATH .. "task_reset_title.png" )
	setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)
	
	layer:addChild( display.newSprite( TASKPATH .. "task_reset_tip.png" , display.cx , 460 , 0.5 , 0 ))
	layer:addChild( display.newSprite( TASKPATH .. "task_reset_cost.png" , 155 , 400 , 0 , 0 ) )
	layer:addChild( display.newSprite( COMMONPATH .. "gold.png" , 257 , 400 , 0 , 0 ) )
	layer:addChild( display.strokeLabel( curData.task_reset , 292 , 400 , 20 , ccc3(0x2c , 0x00 , 0x00 ) ) )
	
	
	
	local confirmResetBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" } , 165 , 307 , {
		front = TASKPATH .. "task_confirm_reset.png",
		priority = -143,	
		callback = function()
			if countGold( curData.task_reset ) then
				if curData.reset_state == 1 then
					HTTP:call("alliance","resettask",{ },{success_callback =
					function()
						mask:remove()
						self:createTask()
					end
					 })
				else
					if DATA_Gang:get("list").userstate < 90 then
						KNMsg.getInstance():flashShow( "权限不足无法重置任务！" )
					else
						KNMsg.getInstance():flashShow( "任务已重置，每天只可重置一次！" )
					end
				end
			end
		end
		})
	
	layer:addChild(confirmResetBtn:getLayer())
	
	
	
	--返回按钮
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
		scale = true,
		priority = -142,	
		callback = function()
			mask:remove()
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	setAnchPos( layer , -display.width , 0 )
	transition.moveTo( layer , {time = 0.5 , easing = "BACKOUT" , x = 0 })
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -141 })
	scene:addChild( mask:getLayer() )
end
--生成list列表
function M:createList( params )
	params = params or {}
	local LISTPATH = PATH .. "gang_list/"
	
	
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
	end
	

	
	
	local data , totalPage , curPage , curType , group , pageText , curData , alonePageNum , listConfig , pageBg , rankText 
	local selectNum , optionFun , countNum	--用手选择参战人员
	local scroll = nil

	listConfig = params.listConfig			--选项按钮
	data = params.data 						--展示的数据
	curType = params.defaultType 			--默认激活table
	curPage = params.defaultPage or 1 		--默认展示页面
	alonePageNum = params.alonePageNum or 0		--单页item个数
	local isPaging = params.alonePageNum and true or false	--是否分页
	local heightType = 0
	
	
	if curType == "wars_member" then
		countNum = 0
		local members = {}
		--确认选择
		local chooseBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" ,"btn_bg_red2.png"} , 
			163  , 108 ,
			{
				priority = -142 ,
				front = COMMONPATH .. "confirm.png" ,
				callback=
				function()
					if table.nums( members ) == 0 then
						KNMsg.getInstance():flashShow( "请选择参战人员！" )					
					else
						self:createWars()
					end
				end
			})
		self.viewLayer:addChild( chooseBtn:getLayer() )
		self.viewLayer:addChild( display.newSprite( PATH .. "wars/selected.png" , 364 , 700 , 0 , 0 ) )
		self.viewLayer:addChild( display.strokeLabel( "请选择要参加帮战的成员" , 20 , 708 , 22 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
		selectNum = display.strokeLabel( countNum , 435 , 708 , 22 , ccc3( 0xff , 0xfc , 0xd3 ) ) 
		self.viewLayer:addChild( selectNum ) 
		
		optionFun = function( tempParams )
			tempParams = tempParams or {}
			local isSelect = tempParams.isSelect
			local uid = tempParams.uid
			
			countNum = countNum + ( isSelect and 1 or -1 )
			members[ uid .. "" ] = isSelect == true and uid or nil
			
			selectNum:setString( countNum )
		end
	end
	
	
	--刷新当前数据
	local function showRank()
		local textElement = { ability = "你的战力排行是第" , rank = "你的帮会排行是第" ,tribute = "你的帮威排行是第"  }
		local str = textElement[curType .. ""] .. data[ curType .. "_top" ] 
		if not rankText then
			rankText = display.strokeLabel( str , 10 , 95 , 18 , ccc3(0xff,0xfb,0xd4), nil, nil, {
				dimensions_width = 130,
				dimensions_height = 50
			})
			self.viewLayer:addChild( rankText )
		end
		rankText:setString( str )
	end
	local function refreshData()
		if curType == "list" then				--帮派列表
			curData = data.toplist  
		elseif curType == "ranking" then		--帮派排行
			curData = data.toprank
		elseif curType == "apply" then			--申请加入
			curData = data.toprank
		elseif curType == "info" then			--帮派成员
			curData = data.info
			heightType = 2
		elseif curType == "wars_member" then	--选择参战成员
			curData = data.info
			heightType = 2
		elseif curType == "event_movement" then	--帮派事件
			curData = data.event_movement
			heightType = 2
		elseif curType == "rank" then			--帮会总榜
			curData = data.rank
			showRank()
		elseif curType == "ability" then		--战力排行
			curData = data.ability
			showRank()
		elseif curType == "tribute" then		--贡献排行
			curData = data.tribute
			showRank()
		elseif curType == "applylist" then		--申请列表
			curData = data.applylist
			heightType = 2
		elseif curType == "appoint" then		--帮内认命
			curData = data.info
		elseif curType == "gem" then			--商城宝石
			curData = data.gemconfig
			heightType = 2
		elseif curType == "task" then			--帮派任务
			curData = data.task.info
			heightType = 2
			return
		end
		
		if isPaging then
			totalPage = math.ceil( #curData / alonePageNum )
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
				local tempItem = self:listCell( { 
													data = ( curType == "appoint" and { isGangMan = data.isGangMan , data = itemData , targetIndex = data.targetIndex ,  position = data.position } or  itemData ) , 
													type = curType , 
													parent = scroll , 
													index = ( curPage - 1 ) * alonePageNum + i , 
													checkBoxOpt = optionFun , 
													checked = false ,  
												} )
				scroll:addChild(tempItem, tempItem )
			end
		end
		scroll:alignCenter()
		self.viewLayer:addChild( scroll:getLayer() )
	end
	
	
	
	local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
	local startX,startY = 10,690
	if heightType == 1 then startX,startY = 10 , 556 end
	if SCENETYPE == RANK then startX,startY = 18 , 690 end
	
	
	
	
	group = KNRadioGroup:new()
	for i = 1, #listConfig do
		local temp = KNBtn:new( COMMONPATH.."tab/", ( ( SCENETYPE == RANK or SCENETYPE == TASK ) and {"long.png","long_select.png"} or {"tab_star_normal.png","tab_star_select.png"} ) , startX , startY , {
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
		self.viewLayer:addChild(temp:getLayer())
		startX = startX + temp:getWidth() + ( SCENETYPE == RANK and 12 or 4 )
	end
	group:chooseById( curType , true )	--激活的选项
	createList()
	
	if curType == "gem" then
		--可用帮威
		local infoData = DATA_Gang:get( "list" )
		local str = ( infoData.usertribute_v > 10000 and math.floor(infoData.usertribute_v/10000) .. "万" or infoData.usertribute_v )
		self.viewLayer:addChild( display.newSprite( LISTPATH .. "usable_prestige.png" , 300 , 695 , 0 , 0 ) )
		self.viewLayer:addChild( display.strokeLabel( str , 400 , 695 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	end
	
	if curType == "info" then
		--总帮威
		local infoData = DATA_Gang:get( "list" )
		local str = ( infoData.usertribute > 10000 and math.floor(infoData.usertribute/10000) .. "万" or infoData.usertribute )
		self.viewLayer:addChild( display.newSprite( LISTPATH ..  "total_prestige.png" , 280 , 695 , 0 , 0 ) )
		self.viewLayer:addChild( display.strokeLabel( str , 400 , 695 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	end
	
	if curType == "task"  then
			--重置任务
			local resetBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" ,"long_btn_grey.png"} , 
				350  , 695 ,
				{
					priority = -142 ,
					front = PATH .. "task/" .. "task_reset.png" ,
					callback=
					function()
						if data.task.reset_state == 1 then
							self:resetLayout()
						else
							if DATA_Gang:get("list").userstate < 90 then
								KNMsg.getInstance():flashShow( "权限不足无法重置任务！" )
							else
								KNMsg.getInstance():flashShow( "任务已经重置！" )
							end
						end
					end
				})
			resetBtn:setEnable( data.task.reset_state == 1 )
			self.viewLayer:addChild( resetBtn:getLayer() )
			
		--总帮威
		local infoData = DATA_Gang:get( "list" )
		local str = ( infoData.usertribute > 10000 and math.floor(infoData.usertribute/10000) .. "万" or infoData.usertribute )
		self.viewLayer:addChild( display.newSprite( LISTPATH ..  "total_prestige.png" , 20 , 695 , 0 , 0 ) )
		self.viewLayer:addChild( display.strokeLabel( str , 140 , 695 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
		end
	
	if curType == "appoint" then
		local str = "请选择要任命的" .. data.text
		if data.text == "帮主" then
			str = "请选择要任命的下一任帮主"
		end
		self.viewLayer:addChild( display.strokeLabel( str , 20 , 708 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	end

	if curType == "applylist" then
			local gangInfoData = DATA_Gang:get("list")
			local isFull = gangInfoData.count < gangInfoData.count_max	--是否达到收人上限
			
			local oneOkBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" ,"btn_bg_red2.png"} , 
				52 , 105 ,
				{
					priority = -142 ,
					front = LISTPATH .. "one_ok.png" ,
					callback=
					function()
						HTTP:call("alliance","agreeonekey",{ },{success_callback = 
						function()
							self:applyFun()
						end})
					end
				})
			oneOkBtn:setEnable( isFull )
			self.viewLayer:addChild( oneOkBtn:getLayer() )
			
			local oneNoBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 
				285 , 105 ,
				{
					priority = -142 ,
					front = LISTPATH .. "all_no.png" ,
					callback=
					function()
						HTTP:call("alliance","refuseonekey",{ },{success_callback = 
						function()
							self:applyFun()
						end})
					end
				}):getLayer()
			self.viewLayer:addChild( oneNoBtn )
			
			--设置验证
			local checkingBtn 
			checkingBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" } , 
				358 , 700 ,
				{
					priority = -142 ,
					front = LISTPATH .. ( gangInfoData.state == 1 and "auto_add.png" or "checking_text.png" ),
					callback=
					function()
						HTTP:call("alliance","switchuser",{ id = data.id },{success_callback = 
						function(resultData)
							gangInfoData = DATA_Gang:get("list")
							local str
							if gangInfoData.state == 1 then
								str = "您已将帮会收人的设置修改为 自动加入"
							else
								str = "您已将帮会收人的设置修改为 验证加入"
							end
							KNMsg.getInstance():flashShow( str )
							checkingBtn:setFront( LISTPATH .. ( gangInfoData.state == 1 and "auto_add.png" or "checking_text.png" ) )
						end})
					end
				})
			self.viewLayer:addChild( checkingBtn:getLayer() )
			
			self.viewLayer:addChild(display.newSprite(LISTPATH .. "set_text.png" , 320 , 720 ))
			self.viewLayer:addChild(display.newSprite(LISTPATH .. "member_num.png" , 72 , 720 ))
			self.viewLayer:addChild(display.strokeLabel( gangInfoData.count .. "/" .. gangInfoData.count_max , 125 , 708 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	end
	

	self.viewLayer:addChild( display.newSprite( COMMONPATH.."tab_line.png"  , 6 , startY - 5 , 0 , 0 ) )
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
		self.viewLayer:addChild(pre:getLayer())
		local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
			scale = true,
			callback = function()
				if curPage < totalPage then
					curPage = curPage + 1
					createList( curType )
				end
			end
		})
		self.viewLayer:addChild(next:getLayer())
	end
	
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
					--查看其它帮派信息
					HTTP:call("alliance","getallianceinfo",{ id = data.id },{success_callback = 
					function(resultData)
						self:lookInfo( { type = 0 , data = resultData or {} } )
					end})
				end
			}):getLayer()
		layer:addChild( bg )
	else
		local str = type == "task" and IMG_PATH .. "image/scene/activity_new/item_bg.png" or COMMONPATH .. "item_bg.png"
		bg = display.newSprite( str )
		setAnchPos(bg , 0 , 0) 
		layer:addChild( bg )
	end
	
	--是否存在复选框
	if params.checkBoxOpt then
		local checkBox
		checkBox = KNCheckBox:new( 377 , 15 , {
										path= COMMONPATH , 
										parent = params["parent"],
										checkBoxOpt = function() 
											params["checkBoxOpt"]( { isSelect = checkBox:isSelect() , uid = data.uid } )
										end,
										file={"checkbox_bg.png","checkbox_choose.png","checkbox_lock.png"}})
		layer:addChild(checkBox:getLayer())
		checkBox:check( params["checked"] )
	end
	
	local titleElement , addX , addY
	
	local function createItem()
		for i = 1 , #titleElement do
			addX = 50 + math.floor( ( i - 1 ) / 3 ) * 260
			addY = 73 - (( i - 1 ) % 3) * 30
			local curTitle = titleElement[i].title
			if 	curTitle ~= "" then
				local tempTitle = display.newSprite( ITEMPATH .. curTitle .. ".png")
				setAnchPos( tempTitle , addX , addY )
				layer:addChild( tempTitle )
				
				local tipText
				addX = addX +  65
				if curTitle == "gang_rank" then
					if 	type == "rank" or type == "ranking"then
						if titleElement[i].text<=3 then
							tipText = display.newSprite( IMG_PATH .. "image/scene/ranklist/" .. titleElement[i].text ..".png" )
							setAnchPos( tipText , addX , addY - 10  )
						else
							tipText = display.strokeLabel( titleElement[i].text , addX , addY - 8 , 40 , ccc3( 0xff , 0x00 , 0x00 ) )
						end
					else
						tipText = getImageNum( tonumber( titleElement[i].text ) , COMMONPATH .. "small_num.png" )
						setAnchPos( tipText , addX , addY )
					end
				else
					tipText = display.strokeLabel( titleElement[i].text , addX , addY , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
							dimensions_width = i<4 and 200 or 80,
							dimensions_height = 25,
							align = 0
						})
				end
				layer:addChild( tipText )
			end
		end
	end
	
	if type == "ranking" then
		titleElement = {
							{ title = "gang_title" , 	text = data.name  .. "(Lv" .. data.lv ..")"} , 										--帮派名
							{ title = "gang_man_title" ,text = data.chieftains_name  } , 							--帮主
							{ title = "ability_title" ,	text = "  " .. data.sum_ability } , 						--战力
							{ title = "" , 				text = data.lv } , 											--帮派等级
							{ title = "gang_rank" , 	text = data.top } ,											--排名
							{ title = "gang_member" , 	text = data.count .."/" .. data.count_max } ,				--成员数
						}
		createItem()
	elseif type == "rank"  then	
		titleElement = {
							{ title = "gang_title" , 	text = data.name  .. "(Lv" .. data.lv ..")"} , 										--帮派名
							{ title = "gang_man_title" ,text = data.chieftains_name  } , 							--帮主
							{ title = "ability_title" ,	text = "  " .. data.sum_ability } , 						--战力
							{ title = "" , 				text = data.lv } , 											--帮派等级
							{ title = "gang_rank" , 	text = data.top } ,											--排名
							{ title = "gang_member" , 	text = data.count .."/" .. data.count_max } ,				--成员数
						}
		createItem()
	elseif type == "gem"  then
		local curProp = awardCell( data , { parent = params.parent} ) 
		setAnchPos( curProp , 15 , 30 , 0 , 0 )
		layer:addChild(curProp)
		
		layer:addChild( display.strokeLabel( data.name , 88 , 75 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ))
		layer:addChild( display.strokeLabel( data.bagdesc , 88 , 50 , 18 , ccc3( 0xac , 0x25 , 0x0f ) ))
		layer:addChild( display.strokeLabel( "帮威：" .. data.tribute , 88 , 25 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ))
		
		local buyBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			335 , 8 ,
			{
				parent = params.parent , 
				front = COMMONPATH .. "buy.png" ,
				callback=
				function()
					self:buy( { data = data , index = index - 1 } )
				end
			})
		buyBtn:setEnable( data.state == 1 )
		layer:addChild( buyBtn:getLayer() )
		--开启宝石加成
		local openBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			237 , 8 ,
			{
				parent = params.parent , 
				front = PATH .. "shop/open_text.png" ,
				callback=
				function()
					local function openFun()
						local isTribute = DATA_Gang:get("list").tribute > data.exp	--帮贡
						local isTunds = DATA_Gang:get("list").funds > data.silver		--资金
						local isUserstate = DATA_Gang:get("list").userstate == 100	--是否是帮主
						if isTribute and isTunds  and isUserstate  then
							HTTP:call("alliance","wakeprop",{ id = index - 1 },{success_callback = 
							function()
								KNMsg.getInstance():flashShow( "开启成功!" )
								self:createShop( )
							end})
						else
							KNMsg.getInstance():flashShow( "资金或帮贡不足" )
						end
					end
					
					KNMsg.getInstance():boxShow( "开启需要花费" .. data.exp ..  "帮贡和"  ..  data.silver .. "资金，确认开启吗？",{ 
--																	confirmText = SCENECOMMON .. "navigation/na_charge_big.png" , 
																	confirmFun = openFun , 
																	cancelFun = function() end 
																	} )

          
				end
			})
		openBtn:setEnable( data.state == 0 and DATA_Gang:get("list").userstate == 100 )
		layer:addChild( openBtn:getLayer() )
		
	elseif type == "ability"  then	
		titleElement = {
							{ title = "meber_name" ,	text = data.name  } , 										--帮主
							{ title = "gang_lv" ,		text = data.lv } , 											--等级
							{ title = "meber_ability" ,	text = data.ability } ,										--战力
							{ title = "gang_rank" , 	text = data.top } , 										--排行
						}
		createItem()
--		--添加好友
--		local addFriendBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
--			237 , 17 ,
--			{
--				parent = params.parent , 
--				front = PATH .. "gang_list/add_friend.png" ,
--				callback=
--				function()
--					dump("暂时不能添加好友")
--				end
--			})
--		addFriendBtn:setEnable( false )
--		layer:addChild( addFriendBtn:getLayer() )
		
		--查看其它成员
		local lookBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			335 , 17 ,
			{
				parent = params.parent , 
				front = PATH .. "gang_list/look.png" ,
				callback=
				function()
					HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
					function()
						local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
						display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
					end})
				end
			}):getLayer()
		layer:addChild( lookBtn )
	elseif type == "tribute"  then	
		titleElement = {
							{ title = "meber_name" ,	text = data.name  } , 										--帮主
							{ title = "gang_lv" ,		text = data.lv } , 											--等级
							{ title = "meber_tribute" ,	text = data.tribute } ,										--帮威
							{ title = "gang_rank" , 	text = data.top } , 										--排行
						}
		createItem()
		
		
--		--添加好友
--		local addFriendBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
--			237 , 17 ,
--			{
--				parent = params.parent , 
--				front = PATH .. "gang_list/add_friend.png" ,
--				callback=
--				function()
--					dump("暂时不能添加好友")
--				end
--			})
--		addFriendBtn:setEnable( false )
--		layer:addChild( addFriendBtn:getLayer() )
		
		--查看其它成员
		local lookBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			335 , 17 ,
			{
				parent = params.parent , 
				front = PATH .. "gang_list/look.png" ,
				callback=
				function()
					HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
					function()
						local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
						display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
					end})
				end
			}):getLayer()
		layer:addChild( lookBtn )
		
	elseif type == "appoint"  then	--成员认命	
		local tempData = data.data
		titleElement = {
							{ title = "gang_title" , 	text = tempData.name } , 										--帮派名
							{ title = "meber_tribute" ,	text = tempData.tribute  } , 									--帮威
							{ title = "meber_ability" ,	text = tempData.ability } , 									--战力
							{ title = "meber_title" , 	text = tempData.title } ,										--头衔
						}
		createItem()
		--查看其它成员
		local appointBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			335 , 17 ,
			{
				parent = params.parent , 
				front = PATH  ..  "appoint/appoint.png" ,
				callback=
				function()
					HTTP:call("alliance","manage",{ touid = tempData.uid , state = data.position , index = data.targetIndex },{success_callback = 
					function()
						if data.isGangMan then
							switchScene("gang")
						else
							self:appointFun()	
						end
					end})
				end
			})
		if data.isGangMan then
			if tempData.state == 100 then
				appointBtn:setEnable( false )
			elseif tempData.state >= 90 then
				appointBtn:setEnable( true )
			else
				appointBtn:setEnable( false )
			end
		else
			appointBtn:setEnable( tempData.state == 0 )
		end
		layer:addChild( appointBtn:getLayer() )
		
	elseif type == "list" then
		titleElement = {
						{ title = "gang_title" , 	text = data.name } , 										--帮派名
						{ title = "gang_man_title" ,text = data.chieftains_name } , 							--帮主
						{ title = "ability_title" ,	text = "  " .. data.sum_ability } , 						--战力
						{ title = "gang_member" , 	text = data.count .."/" .. data.count_max } ,				--成员数
					}
		createItem()
		local applyBtn
		--生成申请加入
		local function createApplyBtn()
				if applyBtn then
					applyBtn:getLayer():removeFromParentAndCleanup( true )
					applyBtn = nil
				end
				
				local applyData = DATA_Gang:getApply()
				local isApply = false	--当前帮派是否已经申请
				
				if applyData then
					for key , v in pairs( applyData ) do
						if v == tonumber( data.id ) then
							isApply = true
							break
						end
					end
				end
				
				applyBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" , "long_btn_grey.png" } , 
					addX - 64 , addY - 55 ,
					{
						parent = params.parent , 
						front = PATH .. "gang_list/" .. ( isApply and "cancel_apply.png" or "apply.png" ) ,
						callback=
						function()
							if isApply then
								--取消申请
								HTTP:call("alliance","exitapplication",{ id = data.id },{success_callback = createApplyBtn})
							else
								if table.nums( applyData ) >= 5 then
									KNMsg.getInstance():flashShow( "同时最多只可向5个帮会发送入帮申请" )
								else
									HTTP:call("alliance","application",{ id = data.id },{success_callback = 
										function()
											if ( not DATA_Gang:isJoinGang() ) then
												switchScene("gang") 
											else
												createApplyBtn() 
											end
										end})
								end
							end
						end
					})
--				applyBtn:setEnable( not isApply )
				layer:addChild( applyBtn:getLayer() )
		end
		createApplyBtn()
	elseif type == "wars_member" then
		titleElement = {
						{ title = "meber_name" , 	text = data.name } , 						--成员名称
						{ title = "meber_tribute" ,	text = data.tribute } , 					--成员帮威
						{ title = "meber_ability" ,	text = data.ability } , 					--成员战力
						{ title = "meber_title" , 	text = data.title } ,						--成员头衔
					}
		createItem()
	elseif type == "info" then
		titleElement = {
						{ title = "meber_name" , 	text = data.name } , 						--成员名称
						{ title = "meber_tribute" ,	text = data.tribute } , 					--成员帮威
						{ title = "meber_ability" ,	text = data.ability } , 					--成员战力
						{ title = "meber_title" , 	text = data.title } ,						--成员头衔
					}
		createItem()
		
		--查看其它成员
		local lookBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			347 , 11 ,
			{
				parent = params.parent , 
				front = PATH .. "gang_list/" ..  "look.png" ,
				callback=
				function()
					HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
					function()
						local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
						display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
					end})
				end
			}):getLayer()
		layer:addChild( lookBtn )
		local tempPlayerData = DATA_Gang:get("list") 
		local isOpen = tempPlayerData.userstate == 100 
		--踢出其它成员
		local removeBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			237 , 11 ,
			{
				parent = params.parent , 
				front = PATH .. "gang_list/" ..  ( ( isOpen and data.state ~= 100 ) and "remove.png" or "remove_dis.png") ,
				callback=
				function()
					if data.state ~= 100 then
						KNMsg.getInstance():boxShow( "你确认要将  " .. data.name .. "  踢出帮会吗？" ,{ 
																	confirmFun = function()
																		HTTP:call("alliance","excluding",{ touid = data.uid },{ success_callback = 
																		function() 
																			self:gangMember()
																		end })
																	end , 
																	cancelFun = function() end 
																	} )

					else
						KNMsg.getInstance():flashShow( "权限不足，无法完成操作" )
					end
				end
			})
		removeBtn:setEnable( isOpen and data.state ~= 100 )--不可以踢出自己
		layer:addChild( removeBtn:getLayer() )
	elseif type == "task" then
		local TASKPATH = PATH .. "task/"
		layer:addChild( display.newSprite( TASKPATH .. "task_discribe_title.png" , 15 , 130 , 0 , 0 ) )
		layer:addChild( display.newSprite( TASKPATH .. "task_award_title.png" , 15 , 50 , 0 , 0 ) )
		local eventText = display.strokeLabel( data.desc , 25 , 72 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 326 ,
					dimensions_height = 60,
					align = 0
				})
		layer:addChild( eventText )	
		local awardData = data.award
		 
		for i = 1 , #awardData do 
			local curProp = awardCell( awardData[i] , { parent = parent }) 
			setAnchPos( curProp , 120 + (i-1)*80 , 10 , 0 , 0 )
			layer:addChild(curProp)
		end
		
		local acceptPath , getPath , isAccept , isGet
		if data.state == 0 then			--0未接 
			isAccept = true
			acceptPath = PATH .. "gang_list/" ..  "accept.png"
			isGet = false
			getPath = COMMONPATH .. "get_grey.png"
		elseif data.state == 1 then		--1已接
			isAccept = true
			acceptPath = PATH .. "gang_list/" ..  "execute.png"
			isGet = false
			getPath = COMMONPATH .. "get_grey.png"
		elseif data.state == 2 then		--2完成 
			isAccept = false
			acceptPath = PATH .. "gang_list/" ..  "execute_gray.png"
			isGet = true
			getPath = COMMONPATH .. "get.png"
			layer:addChild( display.newSprite( TASKPATH .. "complete_flag.png" , 23 , 45 , 0 , 0 ) )
		elseif data.state == 3 then		--3已领奖
			isAccept = false
			acceptPath = PATH .. "gang_list/" ..  "execute_gray.png"
			isGet = false
			getPath = COMMONPATH .. "get_complete.png"
			layer:addChild( display.newSprite( TASKPATH .. "complete_flag.png" , 23 , 45 , 0 , 0 ) )
		end
		--接受 执行
		local acceptBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			360 , 90 ,
			{
				parent = parent , 
				front = acceptPath ,
				callback=
				function()
--					1-关卡、2-藏宝楼、3-山神庙、4-狩猎、5-如意阁、6-道具搜集、7-帮派捐献、8-帮派祈福
					if data.state == 1 then
						if data.type == 1 then
							HTTP:call("mission" , "get",{},{success_callback = function()
									switchScene("mission")
								end })
						elseif data.type == 2 then
							HTTP:call("insequip" , "get",{},{success_callback = function(data)
								switchScene("fb" , { state = "equip" , map = data.current_map } )
							end })
						elseif data.type == 3 then
							HTTP:call("penglai", "get", {}, {
								success_callback = function(data)
									switchScene("fb" , { state = "hero", data = data} )
								end})
						elseif data.type == 4 then
							HTTP:call("inspetnew" , "get",{},{success_callback = function()
								switchScene("fb" , { state = "pet"} )
							end })
						elseif data.type == 5 then
							HTTP:call("insskill" , "get",{},{success_callback = function()
								switchScene("fb" , { state = "skill"} )
							end })
						elseif data.type == 6 then	--暂不做处理 道具搜集
						elseif data.type == 7 then
							self:createDonate()
						elseif data.type == 8 then
							HTTP:call("alliance","clifford",{ },{success_callback = 
							function()
								self:createPray()
							end})
						end
					elseif data.state == 0 then
						HTTP:call("alliance","receivetask",{ id = data.id },{success_callback = 
						function()
							self:createTask()
						end})
					end
				end
			})
		acceptBtn:setEnable( isAccept )	
		layer:addChild( acceptBtn:getLayer() )
		
		--领奖 未领
		local getBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" , "btn_bg_dis.png"} , 
			360 , 11 ,
			{
				parent = parent , 
				front = getPath ,
				callback=
				function()
					HTTP:call("alliance","posttask",{ id = data.id },{success_callback = 
					function()
					
						local function inform( data )
							if data.awards then
								local str = ""
								local decollator = "    "	--分割符
								for key , v in pairs( data.awards ) do
									if v.cid == "power"		then str = str .. "体力  +" .. v.num
									elseif v.cid == "gold"		then str = str .. "黄金  +" .. v.num
									elseif v.cid == "silver"		then str = str .. "银币  +" .. v.num
									elseif v.cid == "task_tribute"		then str = str .. "帮威  +" .. v.num
									elseif v.cid == "task_exp"		then str = str .. "帮贡  +" .. v.num
									elseif v.cid == "task_power"		then str = str .. "体力  +" .. v.num
									elseif v.cid == "funds"		then str = str .. "资金  +" .. v.num
									end
									str = str ..  decollator
								end
								
								
								KNMsg.getInstance():flashShow( str )
							end
						end
						inform( {awards = data.award} )
						
						self:createTask()
					end})
				end
			})
		getBtn:setEnable( isGet )
		layer:addChild( getBtn:getLayer() )
		
	elseif type == "event_movement" then
	
		local str = data.event .. "   " .. data.time
		local eventText = display.strokeLabel( str , 30 , 75 , 20 , ccc3( 0xcc , 0x13 , 0x11 ) , nil , nil , {
					dimensions_width = 400 ,
					dimensions_height = 25,
					align = 0
				})
		layer:addChild( eventText )	
		
		str =data.content 	
		local contentText = display.strokeLabel( str , 30 , 10 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 400 ,
					dimensions_height = 65,
					align = 0
				})
		layer:addChild( contentText )		
		
	elseif type == "applylist" then
		titleElement = {
				{ title = "look" } , 							--查看
				{ title = "reject" } , 							--拒绝
				{ title = "agree" } , 							--同意
			}
			
		local str = data.name .. "(Lv" .. data.lv .. ")" .. "申请加入帮会"
		local tipText = display.strokeLabel( str , 30 , 67 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 400 ,
					dimensions_height = 25,
					align = 0
				})
		layer:addChild( tipText )
		
		for i = 1 , #titleElement do
			local curFalg = titleElement[i].title
			local tempBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" , "btn_bg_pre.png" } , 
				150 + ( i - 1 ) * 100 , 15 ,
				{
					parent = params.parent , 
					front = PATH .. "gang_list/".. curFalg .. ".png" ,
					callback=
					function()
						if curFalg == "look" then
							HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
								function()
									local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
									display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
								end})
						elseif curFalg == "reject" then
							HTTP:call("alliance","refuse",{ touid = data.uid },{success_callback = 
								function()
									self:applyFun()
								end})
						elseif curFalg == "agree" then
							HTTP:call("alliance","agree",{ touid = data.uid },{success_callback = 
								function()
									self:applyFun()
								end})
						end
					end
				}):getLayer()
			layer:addChild( tempBtn )
		end
		layer:setContentSize( bg:getContentSize() )
	end
	

	
	layer:setContentSize( bg:getContentSize() )
	return layer
end

--职务Icon
function M:positionCell( params )
	params = params or {}
	local group = params.group	--职位编号
	local index = params.index 	--堂口编号
	local data  = params.data or nil 	--是否有人
	local targetIndex = params.targetIndex --职位索引
	local APPOINTPATH = PATH .. "appoint/"
	local layer = display.newLayer()
	--认命按钮
	if group ~= 1 then
		local isApply = data ~= nil 
		local appointBtn = KNBtn:new( COMMONPATH , 
				{ "btn_bg.png" , "btn_bg_pre.png" } , 
				0 , 0 ,
				{
					priority = -142 ,
					front = PATH .. "appoint/" ..  ( isApply and "retire.png" or "appoint.png" ) ,
					callback=
					function()
						if isApply then
							HTTP:call("alliance","manage",{ touid = data.uid , state = 0 , index = 0 },{success_callback = 
							function()
								self:appointFun()	
							end})
						else
							SCENETYPE = APPOINT
							local listConfig =  { }
							local textConfig = { "帮主" , "副帮主" ,{"青龙堂堂主" , "白虎堂堂主" ,"朱雀堂堂主" ,"玄武堂堂主"}}
							local positionConfig = { 100 , 95 , 90 , 0 }
							self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = "appoint" , data = { targetIndex = targetIndex ,  position = positionConfig[group] , info = DATA_Gang:get( "info" ) , text = ( group == 3 and textConfig[group][index] or textConfig[group] )} , defaultPage = 1 } )
						end
					end
				}):getLayer()
		setAnchPos(appointBtn , -41 , 0.5)
		layer:addChild( appointBtn )	
	end
	
	
	--人物角色
	local otherData = nil
	local textData = nil
	if data then
		otherData = { IMG_PATH.."image/scene/common/navigation/level_bg.png" , -17 , 54 } 
		textData = { { data.lv  , 18 , ccc3( 0xbf , 0x3a , 0x01 ) , { x = -33 , y = 34	} , nil , 20 } , 
					{ data.name , 18 , ccc3( 0x2c , 0x00 , 0x01 ) , { x = 1 , y = -45	} , nil , 20 } }
	end
	local roleIcon = KNBtn:new( COMMONPATH , { data and "sex".. data.sex .. ".jpg" or "role_frame.png" } , 7 , 70 ,
		{
			front = data and  COMMONPATH .. "role_frame.png"  or nil,
			other = otherData , 
			text = textData ,
			callback = function()end,
		}):getLayer()
	setAnchPos(roleIcon , 0 - 32  , 70 , 0.5)
	layer:addChild( roleIcon )
	
	--职务背景
	local positionBg = display.newSprite( APPOINTPATH .. "position_bg.png")
	setAnchPos( positionBg , 0 , 170 , 0.5 , 0.5 )
	layer:addChild( positionBg )
	
	local positionElement = {
				{ "gang_man"} ,
				{ "deputy_gang_man" , "deputy_gang_man" } ,
				{ "dragon" ,"tiger" , "bird" , "tortoise" } }
	
	--职务名称
	local position = display.newSprite( APPOINTPATH .. positionElement[group][index] ..  ".png")
	setAnchPos( position , 0 , 170 , 0.5 , 0.5 )
	layer:addChild( position )
	
	
	layer:setContentSize( CCSize:new( 110 , 190 ) )
	return layer
end
--认命界面
function M:appointFun(  )
							
	SCENETYPE = APPOINT
	
	GLOBAL_INFOLAYER:refreshTitle( PATH .. "appoint/" .. "appoint_title.png")
	
		
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
	end
	
	local layer = display.newLayer()
	
	local bg = display.newSprite( COMMONPATH .. "figure_bg.png" )
	setAnchPos( bg , display.cx , display.cy + 14 , 0.5 , 0.5)
	layer:addChild( bg )
	layer:addChild( display.newSprite( PATH .. "appoint/" .. "line1.png" , display.cx , 576 , 0.5 , 0) )
	layer:addChild( display.newSprite( PATH .. "appoint/" .. "line2.png" , display.cx , 340 , 0.5 , 0) )
	
	
	local titleVein = display.newSprite( PATH .. "appoint/" .."title_vein.png" )
	setAnchPos(titleVein , display.cx , 700 , 0.5 )
	layer:addChild(titleVein)
	
	local roomMan = display.newSprite( PATH .. "appoint/" .. "room_man.png" )
	setAnchPos(roomMan , display.cx , 368 , 0.5 )
	layer:addChild(roomMan)
	
	local infoData = DATA_Gang:get( "info" )
	
	local leadTable = { {} , {} , {} }	--查找帮主，副帮主，堂主数据
	for i = 1 , #infoData do
		if infoData[i].state == 100 then
			leadTable[1][ 1 .. "" ] = infoData[i]
		elseif infoData[i].state == 95 then
			leadTable[2][ infoData[i].index .. "" ] = infoData[i]
		elseif infoData[i].state == 90 then
			leadTable[3][ infoData[i].index .. "" ] = infoData[i]
		end
	end
	
	local positionElement = {
			{ y = 550 , position = 1 , data = { { x = 200 } } } ,
			{ y = 397 , position = 2 , data = { { x = 112 } , { x = 284 } } } ,
			{ y = 153 , position = 3 , data = { { x = 36  } , { x = 145 } , { x = 255  } , { x = 365  } } } ,}
			
	
	for i = 1 , #positionElement do
		local position = positionElement[i].position
		for j = 1 , #positionElement[i].data do
			local curData = positionElement[i].data[j]
			local temp = self:positionCell( { targetIndex = j , group = position , index = j , data = leadTable[position][j .. "" ] } )
			setAnchPos(temp , curData.x + 40 ,positionElement[i].y , 0.5)
			layer:addChild( temp )	
		end
	end
	
	
	local str = "说明：只有帮主可以任命帮会职位，且帮威排名前10才可被任命！"
	local tipText = display.strokeLabel( str , 14 , 105 , 16 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , {
				dimensions_width = 466 ,
				dimensions_height = 25,
				align = 0
			})
	layer:addChild( tipText )
	
	self.viewLayer:addChild(layer)
	self.baseLayer:addChild( self.viewLayer )	
end
--帮派详细信息页面
function M:lookInfo( params )
	params = params or {}
	local data = params.data.list or {}
	local isNoGang = params.type == 1
	local layer = display.newLayer()
	local mask
	
	local bg = self:basePopup( PATH .. "gang_info.png" )
	setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)
	
	local infoBg = display.newSprite( PATH .. "info_bg.png" )
	setAnchPos( infoBg , display.cx , 367 , 0.5)
	layer:addChild( infoBg )
	
	local infoTitle = display.newSprite( PATH .. "info_title.png" )
	setAnchPos( infoTitle , display.cx - 105 , 375 )
	layer:addChild( infoTitle )

	
	local elementTable = {
							{ text = data.name .. "  (Lv" .. data.lv .. ")" } , 										--帮派名
							{ text = data.id} , 											--帮派等级
							{ text = data.count .. "/" .. data.count_max  } ,					--成员数
							{ text = data.sum_ability} , 									--战力
							{ text = data.chieftains_name } , 								--帮主
	}
	
	for i = 1 , #elementTable do
		local str = elementTable[i].text
		local tipText = display.strokeLabel( str , 220 , 585 - i * 42 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 200 ,
					dimensions_height = 25,
					align = 0
				})
		layer:addChild( tipText )
	end
	
	local applyBtn
	--生成申请加入
	local function createApplyBtn()
		if applyBtn then
			applyBtn:getLayer():removeFromParentAndCleanup( true )
			applyBtn = nil
		end
		
		local applyData = DATA_Gang:getApply()
		local isApply = false	--当前帮派是否已经申请
		
		if applyData then
			for key , v in pairs( applyData ) do
				if v == tonumber( data.id ) then
					isApply = true
					break
				end
			end
		end
		
		applyBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" , "long_btn_grey.png"} , 70 , 305 ,
			{
				priority = -142 ,
				front = PATH .. "gang_list/" .. ( isApply and "cancel_apply.png" or "apply.png" ) ,
				callback=
				function()
					if isApply then
						--取消申请
						HTTP:call("alliance","exitapplication",{ id = data.id },{success_callback = createApplyBtn})
					else
						if table.nums( applyData ) >= 5 then
							KNMsg.getInstance():flashShow( "同时最多只可向5个帮会发送入帮申请" )
						else
							HTTP:call("alliance","application",{ id = data.id },{success_callback = 
								function()
									if ( not DATA_Gang:isJoinGang() ) then
										switchScene("gang") 
									else
										createApplyBtn() 
									end
								end})
						end
					end
				end
			})
--		applyBtn:setEnable( not isApply )
		layer:addChild( applyBtn:getLayer() )
	end
	if isNoGang then
		createApplyBtn()
	end
	
	--返回
	local backBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" } , 
		isNoGang and 268 or display.cx - 70 , 305 ,
		{
			priority = -142 ,
			front = COMMONPATH .. "back.png" ,
			callback=
			function()
				mask:remove()
			end
		}):getLayer()
	layer:addChild( backBtn )
	
	
	setAnchPos( layer , -display.width , 0 )
	transition.moveTo( layer , {time = 0.5 , easing = "BACKOUT" , x = 0 })
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -141 })
	scene:addChild( mask:getLayer() )
end


--查看权限界面
function M:lookPrivilege( params )
	params = params or {}
	
	local layer = display.newLayer()
	local mask
	local PRIVILEGEPATH = PATH .. "privilege/"
	
	local bg = self:basePopup( PRIVILEGEPATH .. "title.png" )
	setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)
	local jobFlag = DATA_Gang:get("list").userstate 
	local jobElement = { ["0"] = "帮众" , ["90"] = "堂主" , ["95"] = "副帮主" , ["100"] = "帮主" ,}
	
	layer:addChild( display.strokeLabel( "你是本帮" .. jobElement[ jobFlag .. "" ] .. "，拥有以下权限：" , 0 , 543 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 480 ,
					dimensions_height = 24,
					align = 1
				}) )
	
	local elementPrivilege = {
								"gang_up" , 										--帮派升级
								"abdicate" , 										--转让帮主
								"gang_appoint" , 									--帮内任命
								"gang_add_member" , 								--帮会收人
								"member_manage" , 									--成员管理
								"quit_gang" , }										--退出帮会
	--权限配置
	local privilegeConfig = {
		["0"] 	= { gang_up = "gang_up" , member_manage = "member_manage" , quit_gang = "quit_gang" } ,
		["90"] 	= { gang_up = "gang_up" , member_manage = "member_manage" , quit_gang = "quit_gang" ,	gang_add_member = "gang_add_member" } , 		
		["95"] 	= { gang_up = "gang_up" , member_manage = "member_manage" , quit_gang = "quit_gang" ,	gang_add_member = "gang_add_member"} , 		
		["100"] = { gang_up = "gang_up" , member_manage = "member_manage" , abdicate = "abdicate" ,		gang_add_member = "gang_add_member" ,  gang_appoint = "gang_appoint" ,  } , }			
		
	local privilegeValue = privilegeConfig[ jobFlag .. "" ]
	
	local isOpen	--是否开启对应功能
	for i = 1 , #elementPrivilege do
		isOpen = privilegeValue[elementPrivilege[i]] and true or false
		local addX , addY = 100 + ( ( i - 1 ) % 2 ) * 170 , 470 - math.floor( ( i - 1 )/2 ) * 73
		local tempBtn = KNBtn:new( COMMONPATH , ( isOpen and { "long_btn.png" , "long_btn_pre.png" } or { "long_btn_grey.png" } ), 
			addX , addY ,
			{
				front = PRIVILEGEPATH .. elementPrivilege[i] .. ".png" ,
				priority = -142,	
				callback=
				function()
					if elementPrivilege[i] == "gang_appoint" then
						self.gangInfoLayer:setVisible(false)
						mask:remove()
						self:appointFun()
					elseif elementPrivilege[i]=="abdicate" then
						self.gangInfoLayer:setVisible(false)
						mask:remove()
						SCENETYPE = APPOINT
						local listConfig =  { }
						local textConfig = { "帮主" , "副帮主" ,{"青龙堂堂主" , "白虎堂堂主" ,"朱雀堂堂主" ,"玄武堂堂主"}}
						local positionConfig = { 100 , 95 , 90 , 0 }
						self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = "appoint" , data = { targetIndex = 1 , 
																															isGangMan = true ,  
																															position = 100 , 
																															info = DATA_Gang:get( "info" ) , 
																															text = "帮主" ,
																															} , defaultPage = 1 } )
					elseif elementPrivilege[i]=="gang_add_member" then
						self.gangInfoLayer:setVisible(false)
						HTTP:call("alliance","fresh",{ },{success_callback = 
						function()
							mask:remove()
							self:applyFun()
						end})	
					elseif elementPrivilege[i] == "member_manage" then
						HTTP:call("alliance","eventmovement",{ },{success_callback =
						function()
							mask:remove()
							self:gangMember()
						end})
					elseif elementPrivilege[i]=="quit_gang" then
						KNMsg.getInstance():boxShow( "退出帮派后,帮威将全部清空,你确认要退出帮会吗？" ,{ 
											confirmFun = function()
												HTTP:call("alliance","excluding",{ touid = DATA_Session:get("uid") },{ success_callback = 
													function() 
														switchScene("gang")
													end })
											end , 
											cancelFun = function() end 
											} )

					elseif elementPrivilege[i]=="gang_up" then
						if not DATA_Gang:get( "gangup" ) then
							HTTP:call("alliance","escalate",{ },{success_callback = 
							function()
								mask:remove()
								self:gangUpFun()
							end})
						else
							if DATA_Gang:get("list").lv < 5 then
								mask:remove()
								self:gangUpFun()
							else
								KNMsg.getInstance():flashShow( "帮派已经达到5级，不需要再升级了" )
							end
						end
					end
				end
			})
		tempBtn:setEnable( isOpen )
		
		layer:addChild( tempBtn:getLayer() )
	end
	
	--返回按钮
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
		scale = true,
		priority = -142,	
		callback = function()
			mask:remove()
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	setAnchPos( layer , -display.width , 0 )
	transition.moveTo( layer , {time = 0.5 , easing = "BACKOUT" , x = 0 })
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -141 })
	scene:addChild( mask:getLayer() )
end
--帮会升级
function M:gangUpFun()
	params = params or {}
	
	local layer = display.newLayer()
	local mask
	local UPPATH = PATH .. "gang_up/"
	local data = DATA_Gang:get( "gangup" )
	
	local bg = self:basePopup( UPPATH .. "gang_up_title.png" )
	setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)
	
	layer:addChild( display.newSprite(UPPATH .. "up_tip.png" , 		display.cx 	, 580 , 0.5 , 0.5 	))
	layer:addChild( display.newSprite(UPPATH .. "frame.png" , 		display.cx 	, 502 , 0.5 , 0.5 	))
	layer:addChild( display.newSprite(UPPATH .. "up_cost.png" , 	display.cx 	, 423 , 0.5 , 0.5 	))
	layer:addChild( display.newSprite(UPPATH .. "frame2.png", 		display.cx 	, 372 , 0.5 , 0.5 	))
	layer:addChild( display.newSprite(UPPATH .. "left_title.png"  ,	61			, 450 , 0 	, 0		))
	layer:addChild( display.newSprite(UPPATH .. "right_title.png" ,	243			, 524 , 0 	, 0		))
	layer:addChild( display.newSprite(UPPATH .. "bottom_title.png",	61			, 342 , 0 	, 0		))
	
	local curLv = DATA_Gang:get("list").lv
	data.infoconfig = data.infoconfig or {}
	data.infoconfig = data.infoconfig or {}
	data.infoconfig[ curLv .. "" ] = data.infoconfig[ curLv .. "" ] or {}
	data.infoconfig[ curLv + 1 .. "" ] = data.infoconfig[  curLv + 1 .. "" ] or {}
	local showElement = { 
							{ now = curLv ,  later = curLv + 1 } , 
							{ now = 30+data.infoconfig[curLv .. ""].power or 0 ,  later = 30 + ( data.infoconfig[ curLv + 1 .. "" ].power or 0 )  } , 
							{ now = data.infoconfig[curLv .. ""].nummax or 0 ,  later = data.infoconfig[ curLv + 1 .. ""].nummax or 0 } , 
							{ now = nil ,  later = nil } , 
							{ now = data.infoconfig[curLv .. ""].task_num or 0  ,  later = data.infoconfig[ curLv + 1 .. "" ].task_num or 0 } , 
						 }
	local addX , addY
	for i = 1 , 5 do
		if showElement[i].now then
			addX , addY = 180 + ( ( i - 1 ) % 2 ) * 180 , 532 - math.floor( ( i - 1 ) / 2 ) * 37
			layer:addChild( display.newSprite(UPPATH .. "up_flag.png"	, addX , addY  , 0 	, 0		))
			addY = addY - 5
			layer:addChild( display.strokeLabel( showElement[i].now 	, addX - 30 , addY , 20 , ccc3(0x2c , 0x00 , 0x00 ) )	)
			layer:addChild( display.strokeLabel( showElement[i].later 	, addX + 35 , addY , 20 , ccc3(0x2c , 0x00 , 0x00 ) )	)
		end
	end
	data.lvconfig = data.lvconfig or {}
	data.lvconfig[curLv+1 .. ""] = data.lvconfig[curLv+1 .. ""] or {}
	local curNum = ( data.lvconfig[curLv+1 .. ""].task_exp or 0 )
	local curNum1 = DATA_Gang:get("list").tribute
	local curNum2 = ( data.lvconfig[curLv+1 .. ""].task_money or 0 ) 
	local curNum3 = DATA_Gang:get("list").funds
	
	local needElement = {
						banggong = { need = curNum  , 	have = curNum1 } , 
						zijin    = { need = curNum2  , 	have = curNum3 } , 
	}
	layer:addChild( display.strokeLabel( ( curNum > 10000 and ( math.floor(curNum/10000) .. "万" ) or curNum )  		, 122 , 373 , 20 , ccc3(0x2c , 0x00 , 0x00 ) )	)
	layer:addChild( display.strokeLabel( ( curNum2 > 10000 and ( math.floor(curNum2/10000) .. "万" ) or curNum2 ) 	, 122 , 341 , 20 , ccc3(0x2c , 0x00 , 0x00 ) )	)
	
	layer:addChild( display.strokeLabel( ( curNum1 > 10000 and ( math.floor(curNum1/10000) .. "万" ) or curNum1 ) 	, 327 , 373 , 20 , ccc3(0x6c , 0xd9 , 0x1e ) )	)
	layer:addChild( display.strokeLabel( ( curNum3 > 10000 and ( math.floor(curNum3/10000) .. "万" ) or curNum3 )	, 327 , 341 , 20 , ccc3(0x6c , 0xd9 , 0x1e ) )	)
	
	local isUp = true	--是否可升级
	for key , v in pairs(needElement) do
		if v.have < v.need  then
			isUp = false
			break
		end
	end
	
	local prayBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" } , 165 , 290  , {
	front = UPPATH .. "confirm_up_text.png",
	priority = -133,	
	callback = function()
		HTTP:call("alliance","escalate",{ isPost = 1 },{success_callback = 
		function()
			KNMsg.getInstance():flashShow( "升级成功" )
			self:refreshGangInfo( { type = 0 , refresh = true } )
			mask:remove()
--			self:gangUpFun()
		end})	
	end})
	prayBtn:setEnable( isUp )
	layer:addChild( prayBtn:getLayer() )
	
	
	--返回按钮
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
		scale = true,
		priority = -142,	
		callback = function()
			mask:remove()
			self:refreshGangInfo( { type = 0 , refresh = true } )
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	setAnchPos( layer , -display.width , 0 )
	transition.moveTo( layer , {time = 0.5 , easing = "BACKOUT" , x = 0 })
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -132 })
	scene:addChild( mask:getLayer() )
end
--创建捐献
function M:createDonate(params)
	SCENETYPE = DONATE
	self:refreshGangInfo( { type = 3 , refresh = true } )
	
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_donate_title.png" )
	
	
	params = params or {}
	local default = params.default or 1 		--默认捐献类型  1黄金，2银两

	local curType = params.type or "task"
	local TASKPATH = PATH .. "task/"
	local data = DATA_Gang:get("task")
	
	
	if data.donate.juangold == 0 then
		default = 2
	end
	
	local layer = display.newLayer()
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
		self.viewLayer:addChild( layer )
		self.baseLayer:addChild( self.viewLayer )
	end
	
	
	
	layer:addChild( display.newSprite( TASKPATH .."frame_bg.png"  , 20 , 104 , 0 , 0 ) )
	
	layer:addChild( display.newSprite( TASKPATH .. "donate_tip.png" , display.cx , 577 , 0.5 , 0) )
	layer:addChild( display.newSprite( PATH .. "pray/award_frame.png"  , display.cx , 440 , 0.5 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "fund_text.png"  , 70 , 475 , 0 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "select_donate.png"  , 40 , 336 , 0 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "cost_text.png"  , 255 , 338 , 0 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "money_bg.png"  , 344 , 336 , 0 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "get_num.png"  , 55 , 189 , 0 , 0) )
	layer:addChild( display.newSprite( TASKPATH .. "get_num2.png"  , 262 , 189 , 0 , 0) )
	--帮会当前资金总额
	layer:addChild( display.strokeLabel( DATA_Gang:get("list").funds , 287 , 480 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) )	 )
	
	
	local btnFlag , costFlag , comboBox , moneyText , bangwei , zijin , slider , addBtn , minusBtn = nil , nil ,  nil , nil , nil , nil , nil , nil , nil
	local num  , baseX , baseY , maxValue = 1 , display.cx , display.cy - 28 , 0
--	maxValue = ( default == 1 and ( DATA_Account:get("gold") > data.donate.juangold and data.donate.juangold or DATA_Account:get("gold") ) or  ( DATA_Account:get("silver") > data.donate.juangold and data.donate.juansilver or DATA_Account:get("silver") ) ) 
	maxValue = ( default == 1 and data.donate.juangold or  data.donate.juansilver )
	
	--捐献数值
	moneyText = display.strokeLabel( "" , 287 + 70 , 357 + 46 - 60 , 18 , ccc3( 0xf7 , 0xee , 0xc5 ) )	
	layer:addChild( moneyText )
	--可获得帮威
	bangwei = display.strokeLabel( "" , display.cx - 137  , 190 , 18 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil ,
	 {
	 	 dimensions_width = 74 , 
	 	 dimensions_height = 23 , 
	 	 align = 1 
	 })
	layer:addChild( bangwei )
	--可获得资金
	zijin = display.strokeLabel( "" , display.cx + 70  , 190 , 18 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil ,
	 {
	 	 dimensions_width = 74 , 
	 	 dimensions_height = 23 , 
	 	 align = 1 
	 })
	layer:addChild( zijin )
	
	
	local function changeValue()
		local ratioData = ( default == 1 and data.donateinfo.gold or data.donateinfo.silver ) 
		bangwei:setString( num * ratioData.tribute )
		moneyText:setString( num )
		zijin:setString( num * ratioData.funds )
	end
	
	--增加按钮
	addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX + 128 , 249 , {
		scale = true,
		priority = -130,
		callback = function()
			if num < maxValue then
				num = num + 1
				slider:setValue( num )
			end
		end
	})
	dump( maxValue )
	--划动条
	slider = KNSlider:new( "buy" ,  {
										x = baseX - 106 , 
										y = baseY - 53 + 229, 
										minimum = 1 , 
										maximum = maxValue , 
										value = 1 , 
										callback  = function( _curIndex )  num =  _curIndex  changeValue() end ,
										priority = -140
										} )
	layer:addChild( slider )
	minusBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX - 165 , 249 ,{
		scale = true,
		priority = -130,
		callback = function()
			if num > 1 then
				num = num - 1
				slider:setValue( num )
			end
		end
	})
	minusBtn:setFlip(true)
	
	addBtn:getLayer():setScale( 0.9 )
	minusBtn:getLayer():setScale( 0.9 )
	
	layer:addChild(addBtn:getLayer())
	layer:addChild(minusBtn:getLayer())

	local confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" } , 165 , 126 , {
			front = TASKPATH .. "confirm_donate.png",
			priority = -131,	
			callback = function()
				local tempValue = ( ( default == 1 ) and data.donate.juangold or data.donate.juansilver )
				
				if tempValue == 0 then
					KNMsg.getInstance():flashShow( "已到捐献上限,请明天再来！" )
				else
					local selfMoney = ( default == 1 and  DATA_Account:get("gold") or  DATA_Account:get("silver") )
					if num>selfMoney then
						local moneyName = ( default == 1 ) and  "黄金" or "银两" 
						KNMsg.getInstance():flashShow( moneyName .. "不足！"  )
					else
						HTTP:call("alliance","senddonate",{ type = ( default == 1 ) and "gold" or "silver" , num = num },{success_callback =
						function(data)
							KNMsg.getInstance():flashShow("捐献成功,帮威+" .. bangwei:getString() .. ",资金+" .. zijin:getString() )
							self:createDonate( { default = default } )
						end
						 })
					end
				end
			end
			})
	confirmBtn:setEnable( ( default == 1 ) and ( DATA_Account:get("gold") > 1 ) or ( DATA_Account:get("silver") > 1 ) )
	layer:addChild( confirmBtn:getLayer() )
	
	local function changeLayout( )
		if costFlag then
			costFlag:removeFromParentAndCleanup( true )
			costFlag = nil
		end
		
		costFlag = display.newSprite( COMMONPATH .. ( default == 1 and "gold.png" or "silver.png" )  , 311 , 338 , 0 , 0)
		layer:addChild(costFlag , 50 )
		
		maxValue = ( default == 1 and data.donate.juangold or  data.donate.juansilver )
		
		if maxValue == 0 then--为临时解决单项目捐献
			maxValue = 0.5
		end
		slider:setMax( maxValue )
		
		
		
		local tempValue = ( ( default == 1 ) and data.donate.juangold or data.donate.juansilver )
		num = tempValue == 0 and 0 or 1
		
	end
	changeLayout()
	local KNComboBox = requires(IMG_PATH,"GameLuaScript/Common/KNComboBox")
	local group = KNRadioGroup:new()
	local items = {}
	for i = 1, 2 do
		items[i] = KNBtn:new( COMMONPATH, { i == 1 and "gold.png" or "silver.png" , "star_select.png"}, 0, 0, {
			id = i,
			noHide = true,
			callback = function()
				default = i
				comboBox:autoShow()
				comboBox:refreshBtn( { front = COMMONPATH .. ( default == 1 and "gold.png" or "silver.png" ) })
				changeLayout()
				changeValue()
			end
		},group)
	end
	comboBox = KNComboBox:new(80, 350, {
		dir = COMMONPATH,
		res = {"small_btn_bg.png", "small_btn_bg_pre.png"},
		front = COMMONPATH .. ( default == 1 and "gold.png" or "silver.png" ) ,
		bg = TASKPATH.."combo_bg.png",
		up = true,
		offset = 15,
		addX = 12,
		additionHeight = 15 ,
		items = items,
		default = default,
		itemsGroup = group
	})
	self.viewLayer:addChild( comboBox:getLayer() )
	
	--总帮威
	local infoData = DATA_Gang:get( "list" )
	local str = ( infoData.usertribute > 10000 and math.floor(infoData.usertribute/10000) .. "万" or infoData.usertribute )
	layer:addChild( display.newSprite( PATH ..  "gang_list/total_prestige.png" , 20 , 680 , 0 , 0 ) )
	layer:addChild( display.strokeLabel( str , 140 , 680 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	
	layer:addChild( display.newSprite( TASKPATH ..  "surplus.png" , 330 , 680 , 0 , 0 ) )
	layer:addChild( display.newSprite( COMMONPATH ..  "gold.png" , 382 , 680 , 0 , 0 ) )
	local goldValue = DATA_Account:get("gold")
	layer:addChild( display.strokeLabel( ( ( goldValue>10000 ) and math.floor(goldValue/10000) .. "万" or goldValue ) , 415 , 681 , 20 , ccc3( 0xff , 0xfc , 0xd3 ) ) )
	
	setAnchPos( layer , 0 , 15 , 0 , 0 )
	
	self.viewLayer:addChild( display.newSprite( COMMONPATH.."tab_line.png"  , 6 , 688 , 0 , 0 ) )
end
--帮会任务捐献
function M:createTask( params )
	SCENETYPE = TASK
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_task_title.png" )
	params = params or {}
	local default = params.default or 1 		--默认捐献类型  1黄金，2银两
	local curType = params.type or "task"
	local TASKPATH = PATH .. "task/"
	
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
	end
	
	local listConfig =  { {"task","tab_task"} }
	local activity = curType
	self:createList( { listConfig = {} , defaultType = activity , data = DATA_Gang:get("task") , defaultPage = 1 , backFun = function() self:createTask(params) end } )
end

--创建商城
function M:createShop()
	
	local SHOPPATH = PATH .. "shop/"
	SCENETYPE = SHOP
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_shop_title.png" )
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
	end
	
	
	local listConfig =  { {"gem","tab_gem"} }
	local activity = "gem"
	self:createList( { alonePageNum = 10 , listConfig = listConfig , defaultType = activity , data = DATA_Gang:get( "shop" ) , defaultPage = 1 } )
end

--购买弹出
function M:buy( params )
	params = params or {}
	local data = params.data or {}
	local index = params.index or 0
	local TEMPPATH = IMG_PATH.."image/scene/shop/"
	local layer = display.newLayer()
	local mask
	local baseX , baseY = display.cx , display.cy - 28
	
	layer:addChild( display.newSprite(COMMONPATH .. "tip_bg.png" ,  display.cx + 3 , baseY - 28 , 0.5 , 0  ) )
	--物品Icon
	layer:addChild( KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , baseX - 148 , baseY + 135 , {  front = getImageByType( data.cid , "s") } ):getLayer())	
	-- 名字
	layer:addChild( display.strokeLabel( data.name , baseX - 75 , baseY + 170 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 130 , dimensions_height = 30 ,align = 0 } ) )
	
	--花费总数
	local valueBg = display.newSprite(TEMPPATH.."value_bg.png")
	valueBg:setScaleY(0.89)
	setAnchPos(valueBg , baseX - 17 , baseY + 130 , 0.5)
	layer:addChild(valueBg)
	
	layer:addChild( display.newSprite( PATH .. "usertribute_v.png" , baseX - 75  , baseY + 140 , 0 , 0 ) )
	

	

	
	
	--购买数量
	layer:addChild( display.newSprite(TEMPPATH.."num_text.png" , baseX + 55  , baseY + 140 , 0 , 0) )
	
	--购买数量
	local num = 1 
	layer:addChild(display.newSprite(TEMPPATH.."num_bg.png" , baseX + 116 , baseY + 136 , 0 , 0) )
	
	--数量文本
	local numText = display.strokeLabel( 1 .. "" , baseX + 116 , baseY + 136 , 20 , ccc3(0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 36 , dimensions_height = 30 ,align = 1 } )
	layer:addChild(numText)
	local priceText = display.strokeLabel( data.tribute , baseX - 40 , baseY + 135 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil ,{ dimensions_width = 80 , dimensions_height = 30 ,align = 0} )
	layer:addChild(priceText)
	--修改数值
	local function changeValue()
		numText:setString(num)
		priceText:setString( num * data.tribute )
	end
	
	
	
	
	--划动条
	local slider = KNSlider:new( "buy" ,  {
		x = baseX - 106 , 
		y = baseY -53 , 
		minimum = 1 , 
		maximum = 20, 
		value = 1 , 
		callback  = function( _curIndex )
			num = _curIndex
			changeValue()
		end,
		priority = -140
	})
	layer:addChild( slider )
	
	--增减按钮
	local addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX + 128 , baseY + 77 , {
		scale = true,
		priority = -132 ,
		callback = function()
			if num < 99 then
				num = num + 1
				slider:setValue( num )
				changeValue()
			end
		end
	})
	
	local minusBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX - 165 , baseY + 77 ,{
		scale = true,
		priority = -132 ,
		callback = function()
			if num > 1 then
				num = num - 1
				slider:setValue( num )
				changeValue()
			end
		end
	})
	minusBtn:setFlip(true)
	
	addBtn:getLayer():setScale( 0.9 )
	minusBtn:getLayer():setScale( 0.9 )
	layer:addChild(addBtn:getLayer())
	layer:addChild(minusBtn:getLayer())
	

	

	
	
	--确定，取消按钮
	local ok = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"}, baseX - 134 , baseY ,{
		front = COMMONPATH.."ok.png" ,
		scale = true,
		priority = -132,
		callback = function()
			if DATA_Gang:get("list").usertribute_v >= num * data.tribute then
				
				HTTP:call("alliance" , "shopprop" , {
					id = index,
					num = num
				} , {
					success_callback = function()
						mask:remove()
						KNMsg.getInstance():flashShow( "购买成功  " .. "消耗帮威:" .. num * data.tribute .. "  获得" .. data.name .. "X" .. num )
					end
				})
			else
				KNMsg.getInstance():flashShow( "可用帮威不足！" )
			end

		end
	})
	local cancel = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"} , baseX + 54 , baseY ,{front = COMMONPATH.."cancel.png",scale = true,priority = -132,callback=
		function()
			mask:remove()
		end})
	layer:addChild(ok:getLayer())
	layer:addChild(cancel:getLayer())
	
	setAnchPos( layer , 0 , -display.height )
	transition.moveTo( layer , { time = 0.5 , easing = "BACKOUT" , y = 0 })
	mask = KNMask:new( { item = layer ,  priority = -131 } )
	local scene = display.getRunningScene()
	scene:addChild( mask:getLayer() )
end
--帮战主界面
function M:createWars()
	local WARSPATH = PATH .. "wars/"
	SCENETYPE = WARS
	self:refreshGangInfo( { type = 3 , refresh = true } )
	
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_wars_title.png" )
	
	local layer = display.newLayer()
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
		self.viewLayer:addChild( layer )
	end
	
	layer:addChild( display.newSprite( PATH .. "hall/notice_bg2.png" , display.cx , 615 , 0.5 , 0 ) )	--上背景
	local shandLayer = display.newLayer()
	shandLayer:addChild( display.newSprite( SCENECOMMON .. "prop_bg.png" , display.cx , 617 , 0.5 , 0 ) )	--阴影
	shandLayer:addChild( display.newSprite( SCENECOMMON .. "prop_bg.png" , display.cx , 617 , 0.5 , 0 ) )	--阴影
	shandLayer:setScaleX( 1.2 )
	layer:addChild( shandLayer )
	layer:addChild( display.newSprite( PATH .. "appoint/title_vein.png" , display.cx , 705 , 0.5 , 0 ) )	--上饰纹
	layer:addChild( display.newSprite( WARSPATH .. "wars_info_title.png" , display.cx , 705 , 0.5 , 0 ) )	--帮战信息标题
	
	layer:addChild( display.newSprite( COMMONPATH .. "half_bg.png" , display.cx , 109 , 0.5 , 0 ) )	--下背景
	layer:addChild( display.newSprite( WARSPATH .. "shade_bg.png" , display.cx , 200 , 0.5 , 0 ) )	--背景框
	layer:addChild( display.newSprite( PATH .. "appoint/title_vein.png" , display.cx , 570 , 0.5 , 0 ) )	--下饰纹
	layer:addChild( display.newSprite( WARSPATH .. "wars_rule_title.png" , display.cx , 570 , 0.5 , 0 ) )	--帮战信息标题
	
	layer:addChild( display.newSprite( WARSPATH .. "gang_wars_time.png" , 45, 534 , 0 , 0 ) )	--帮战时间
	layer:addChild( display.newSprite( WARSPATH .. "apply_condition.png" , 45, 475 , 0 , 0 ) )	--服名条件
	layer:addChild( display.newSprite( WARSPATH .. "win_condition.png" , 45, 360 , 0 , 0 ) )	--胜利条件
	
	--榜单按钮
	layer:addChild( KNBtn:new( WARSPATH , { "rank.png" } , 358 , 628 , { 
								scale = true , 
								callback = function()
									 self:createWarsRank()
								end}):getLayer())	
	--领取奖励
	layer:addChild( KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" , "long_btn_grey.png" } , 340 , 207 , { 
								scale = true , 
								front = COMMONPATH .. "all_get.png" , 
								callback = function()
									 
								end}):getLayer())	
	--参战人员
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" } , 58 , 115 , { 
								scale = true , 
								front = WARSPATH .. "go_to_war_member.png" , 
								callback = function()
			 						HTTP:call("alliance","eventmovement",{ },{success_callback =
									function()
										self:createWarsMember()
									end})
								end}):getLayer())	
	--参与帮战
	layer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" } , 272 , 115 , { 
								scale = true , 
								front = WARSPATH .. "go_to_gang_wars.png" , 
								callback = function()
			 						HTTP:call("gangbattle", "enter", {}, {
										success_callback = function(data)
											switchScene("war", data)
										end
									})	
								end}):getLayer())	
	--帮战时间
	layer:addChild( display.strokeLabel( "每周一、周三、周五、周六晚上19：00开始" , 150 , 506 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 276 ,
					dimensions_height = 55,
					align = 0 
					}) )	
	--帮战时间
	local str = "由帮主报名筛选 10帮会成员参与帮战，帮主报名参加，帮主需要在本周第一次帮战开启前20分钟的任意时段报名"
	layer:addChild( display.strokeLabel( str , 150 , 395 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 276 ,
					dimensions_height = 104,
					align = 0 
					}) )	
				
	--胜利条件
	local str = "由帮主报名筛选10名帮会成员参与帮战，帮战胜利所有成员将可获得帮威望，帮会获得大量帮贡和荣誉"
	layer:addChild( display.strokeLabel( str , 150 , 287 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 276 ,
					dimensions_height = 100,
					align = 0 
					}) )
	--战胜消息
	layer:addChild( display.strokeLabel( "10月1日本帮战胜了【很腹黑猥琐】" , 32 , 215 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 320 ,
					dimensions_height = 25,
					align = 0 
					}) )
	--下期帮战
	layer:addChild( display.strokeLabel( "10月6日19:00帮理工对手【王者屌丝逆袭】帮会" , 40 , 165 , 20 , ccc3( 0xbd , 0x19 , 0x18 ) , nil , nil , {
					dimensions_width = 414 ,
					dimensions_height = 25,
					align = 0 
					}) )
		
	local warsInfo = {}			
	for i = 1 , 3 do
		warsInfo[i] = display.strokeLabel( "10月1日本帮战胜了【很腹黑猥琐】" , 45 , 700 - i * 24  , 20 , ccc3( 0x2c , 0x00 , 0x00 ))
		layer:addChild( warsInfo[i] )
	end
	
	local totalTime = 60	--刷新总时间
	local coutTime = 0		--计时器
	
	--刷新讯息	
	local function refreshWarsInfo()
		if true then		--帮战时间还没有到则直接返回
			return
		end
		
		coutTime = coutTime + 1
		
		if coutTime > totalTime then
			HTTP:call("alliance","notice",{ notice = str },{success_callback = 
			function(data)
				local infoData = DATA_Gang:get( "wars" )
				for i = 1 , #warsInfo do
					warsInfo[i]:setString( infoData[i] )
				end
			end})	
		end
	end
	
	KNClock:addTimeFun( "wars" , refreshWarsInfo )
end
--参战成员选择
function M:createWarsMember( )
	SCENETYPE = WARSMEBER
	
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_wars_title.png" )
	--查看帮派成员列表
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = display.newLayer()
	end
	
	local data = { event_movement = DATA_Gang:get("event_movement") , info = DATA_Gang:get("info") }
	local listConfig =  {} 
	self:createList( { listConfig = listConfig , defaultType = "wars_member" , data = data , defaultPage = 1 } )
end
--帮战榜单界面
function M:createWarsRank( )
	SCENETYPE = WARSRANK
	local WARSPATH = PATH .. "wars/"
	local speedTime = 0.3	--线路运动时间 
	self:refreshGangInfo( { type = 3 , refresh = true } )
	GLOBAL_INFOLAYER:refreshTitle( PATH.."gang_wars_title.png" )
	local layer = display.newLayer()
	if self.viewLayer then	
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
		self.viewLayer:addChild( layer )
	end
	
	layer:addChild( display.newSprite( WARSPATH .. "wars_rank_title.png" , display.cx , 688 , 0.5 , 0 ) )

	
	layer:addChild( display.newSprite( WARSPATH .. "roadmap.png" , display.cx , 130 , 0.5 , 0 ) )
	local actionLayer = display.newLayer()	--动画层
	layer:addChild( actionLayer )
	layer:addChild( display.newSprite( WARSPATH .. "first_gang.png" , display.cx + 2 , 364 , 0.5 , 0 ) )
	layer:addChild( display.strokeLabel( "天下第一帮派" , display.cx - 60  , 400 , 20 , ccc3( 0xff , 0xe3 , 0x37 ) , nil , nil , {
					dimensions_width = 120,
					dimensions_height = 28,
					align = 1
				}) )
				
				
	local function gangRankCell( params )
		params = params or {}
		local type = params.type
		local data = params.data
		
		local bgBtn = KNBtn:new( WARSPATH , { "rank_item_bg" .. type .. ".png"  } , 0 , 0 , {
								scale = true , 
								callback = function()
--									HTTP:call("alliance","getallianceinfo",{ id = data.id },{success_callback = 
									HTTP:call("alliance","getallianceinfo",{ id = 1 },{success_callback = 
									function(resultData)
										self:lookInfo( { data = resultData or {} } )
									end})
								end} ):getLayer()
		bgBtn:addChild( display.strokeLabel( data.name , 15  , 0 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
						dimensions_width = 65,
						dimensions_height = 55,
						align = 1
					}) )
		return bgBtn
	end
	
	local addX = { 172 , 115 , 0 }
	local distance = { 115 , 230 , 0 }
	local lookBattle = {} 	--查看战斗按钮存储
	for t = 1 , 2 do
		local initY = t==1 and 30 or 714
		local isUp = t==1 and true or false	--是否向上
		local tempY = 0
		for i = 1 , 3 do
			local totalNum = math.floor( 4 / i)
			tempY = tempY + 20 * ( 6 - i )
			local addY = initY + ( isUp and tempY or -tempY )
			local delayValue = ( ( i - 1 ) * ( speedTime * 2 ) )--动画延迟时间
			
			for j = 1 , totalNum do
				local x = display.cx - addX[i]  + ( j - 1 ) * distance[i] -  95/2
				
				local item = gangRankCell( { group = i , color = j%2 , type = ( i == 1 and 1 or 2 ) ,  data = { name = "天下第一帮会" } } )
				setAnchPos( item , x , addY , 0 , 0 )
				layer:addChild( item )
				
				--查看战斗
				local btnOffY = ( i==2 and 60 or 40 )
				local newY = addY - ( isUp and btnOffY or -( btnOffY + 39 ) )
				if i>=2 then
					lookBattle[ t .. ( i - 1 ) .. j ] =  KNBtn:new( PATH .. "wars/" , { "look_battle.png" , "look_battle_pre.png" } , x + 30 , newY , {
										scale = true ,
										id = t .. ( i - 1 ) .. j , 
										callback = function()
											dump( t .. ( i - 1 ) .. j )
										end
									}):getLayer() 
					layer:addChild( lookBattle[ t .. ( i - 1 ) .. j ] )
				end
				
				--横向线条
				local data = { name = "天下第一帮会" }
								
				local color = j%2
				if data and i ~= 3 then
					local scaleFactor = { 0.7 , 1.3 , 0 }
					local str = ( color == 0 and "left_red.png" or "left_blue.png" )
					local line = display.newSprite( WARSPATH .. str )
					setAnchPos( line , x + 95/2 , addY + 22 , math.abs( color - 1 )  , 0 )
					actionLayer:addChild( line )
					line:setScaleX( 0.1 )
					transition.scaleTo( line , { delay = delayValue , scaleX = scaleFactor[i] , time= speedTime  } )
				end
				--竖向线动画
				if color == 0 or i == 3 then
					local winColor = 1
					newY = addY - ( isUp and -39 or -39 ) 
					local scaleFactor = { 1 , 0.4 , 1 }
					local str = winColor == 0 and "up_red.png" or "up_blue.png"
					local line = display.newSprite( WARSPATH .. str )
					setAnchPos( line , x - ( distance[i] - 95 ) / 2 - 1   , newY   , 0.5  , isUp and 0 or 1 )
					actionLayer:addChild( line )
					line:setScaleY( 0.1 )
					transition.scaleTo( line , { delay = ( i == 3 and delayValue or delayValue + speedTime ), scaleY = scaleFactor[i] , time= speedTime  } )
				end
				
			end
		end
	end
	
	
end

return M