--活动页面
local M = {}

local PATH = IMG_PATH .. "image/scene/activity_new/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local baseElement = requires(IMG_PATH , "GameLuaScript/Scene/common/baseElement")
local data
local handler
local curClock
function M:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	-- 基础层
	this.baseLayer = display.newLayer()
	this.listLayer = display.newLayer()
	this.viewLayer = display.newLayer()
	
	
	-- 背景
	local bg = display.newSprite( PATH .. "activity_bg.png")
	setAnchPos( bg , 0 , 88 )						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild( bg )
	
	
	local list = DATA_Activity:getlist()
	
--	list["5"] = "payment"
	local scroll = KNScrollView:new( 10, 710, 460, 100, 10 , true )
	local group = KNRadioGroup:new()
	for i = 1 , table.nums(list) do
		local curName = list[ i .. ""]
		local activityBtn = KNBtn:new( PATH .. "list/" , { curName .. ".png" , "select.png" } , 0 , 0 ,
		{
			id = curName , 
			parent = scroll,
			noHide = true,
			upSelect = true,
			selectZOrder = 1,
			disableWhenChoose = true ,
			other = {{ PATH .. "list/" .. curName .. "_name.png" , 5 , 3} , ( curName == "payment" or curName == "singlepaymax" ) and { PATH .. "list/curfew.png" , 5 , 33} or nil} , 
			callback = function()
				this:clearClock()
				DATA_Activity:delWineData()		--清除对酒数据，以停止时钟
				Clock:removeTimeFun( "payTime" )
--				if curName == "payment" then
--					this:paymentActivity()
--				else
					HTTP:call("activity", "get", { type = curName } , {success_callback = 
					function()
						this:selectActivity( curName )
					end})
--				end
			end
		},group)
		scroll:addChild(activityBtn:getLayer(), activityBtn )
	end
	scroll:alignCenter()
	this.listLayer:addChild(scroll:getLayer() )

	
	
	this.baseLayer:addChild(this.viewLayer , 1 )
	this.baseLayer:addChild(this.listLayer)
	
	
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new( "activity" , 5 , { title_hide = false , tail_hide = true } )
	this.baseLayer:addChild( this.infoLayer:getLayer() )	
	
	this:selectActivity( )
	return this.baseLayer 
end
--刷新数据
function M:selectActivity( _activityType )
	local activityType = _activityType or DATA_Activity:getCurType()
	
	data = DATA_Activity:getCurData()
	if self.viewLayer then
		if handler then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
			handler = nil
		end
		self.awardProp = nil
		self.viewLayer:removeFromParentAndCleanup(true)	-- 清除自己
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild(self.viewLayer , 1 )
	end
	
	if 		activityType == "login" 			then self:loginActivity()	--登陆
	elseif 	activityType == "achieve" 			then self:achieveActivity()--好汉
	elseif 	activityType == "lvup" 				then self:lvupActivity()--升级
	elseif 	activityType == "wine" 				then self:wineActivity()--对酒
	elseif 	activityType == "payment" 			then self:paymentActivity()--充值奖励
	elseif 	activityType == "firstpay" 			then self:firstpayActivity()--首充礼包
	elseif 	activityType == "singlepaymax" 		then self:singlepaymaxActivity()--五星英雄
	elseif 	activityType == "welfare" 			then self:welfareActivity()--全民福利
	elseif 	activityType == "xchange" 			then self:xchangeActivity()--超值兑换
	elseif 	activityType == "paycount" 			then self:paycountActivity()--累积冲值 累充大礼
	elseif 	activityType == "logincount" 		then self:logincountActivity()--累积登陆 中秋送礼
	elseif 	activityType == "singlepay" 		then self:singlepayActivity()--单充大礼
	end
	
end
--是否有活动说明
function M:baseLayout( params )
	params = params or {}
	
	if data.tips and data.tips ~= "" then
		local activityTitle = display.strokeLabel( "活动内容：" , 17 , 670 , 18 , ccc3( 0xff , 0xff , 0xfd ) , nil , nil , {
					dimensions_width = 100 ,
					dimensions_height = 24,
					align = 0
				})
		
		local activityText = display.strokeLabel( data.tips , 100 , 645 , 18 , ccc3( 0xff , 0xff , 0xfd ) , nil , nil , {
					dimensions_width = 354,
					dimensions_height = 50,
					align = 0
				})
				
		self.viewLayer:addChild( activityTitle )
		self.viewLayer:addChild( activityText )
	end
	
	--分隔线
	if params.line then
		local lineData = params.frame or {}
		local pathStr = lineData.path or COMMONPATH .. "tab_line.png"
		local addX = lineData.x or display.cx
		local addY = lineData.y or 643
		local line = display.newSprite( pathStr )
		setAnchPos(line , addX , addY , 0.5 , 0.5 )
		self.viewLayer:addChild( line )
	end
	
	--背景
	if params.frame then
		local framsData = params.frame or {}
		local pathStr = framsData.path or PATH .. "frame.png"
		local addX = framsData.x or display.cx
		local addY = framsData.y or 107
		
		local frame = display.newSprite( pathStr )
		setAnchPos(frame , addX , addY , 0.5 )
		self.viewLayer:addChild( frame )
	end
	
end
--删除时钟
function M:delHandler()
	if handler then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
		handler = nil
	end
end
function M:downTime( key , timeTextAry ,downFun )
	local timeText = {}
	local function refreshTime()
		local curTime = downFun()
		if curTime < 0 then curTime = 0 end
		local dayNum = math.floor( tonumber(timeConvert( curTime , "hour"))/24 )
		curTime = curTime - dayNum * 86400
		timeTextAry[1]:setString( dayNum )												--天
		timeTextAry[2]:setString( math.mod( timeConvert( curTime , "hour") , 24 )  )	--时
		timeTextAry[3]:setString( timeConvert( curTime , "min")  )						--分
		timeTextAry[4]:setString( timeConvert( curTime , "sec")  )						--秒
		if curTime <= 0 then
			Clock:removeTimeFun( key )
		end
	end
	curClock = key  
	Clock:addTimeFun( key , refreshTime )
end
--清除当前运行的时钟
function M:clearClock()
	Clock:removeTimeFun( curClock )
end
--领取动画，暂时不做
function M:getAction( params )
	local awardProp = params.awardProp	or {}--奖励道具
	local completeFun = params.onComplete or function()end
	completeFun()
--	KNMsg.getInstance():flashShow( "今天奖励已领取！" )
end

--五星英雄
function M:singlepaymaxActivity()
	self:baseLayout({ line = {} , frame = {} })
	
	local baseY = 107
	
	self.viewLayer:addChild( display.newSprite( PATH .. "down_time_tip.png" , display.cx , 558 , 0.5 , 0  ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "singlepaymax_tip.png" , display.cx , 475 , 0.5 , 0  ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "singlepaymax_tip.png" , display.cx , 475 , 0.5 , 0  ) )
	local awardBg = display.newSprite( PATH .. "shade1.png" , display.cx , 275 , 0.5 , 0  ) 
	awardBg:setScaleY(1.4)
	self.viewLayer:addChild( awardBg )
	
	local timeText = {}
	local timeX , timeY = 215 , 562
	for i = 1 , 4 do
		timeText[i] = display.strokeLabel( "00"  , timeX + ( i - 1 )* 50 , timeY , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
				dimensions_width = 25,
				dimensions_height = 20,
				align = 1
			})
		self.viewLayer:addChild( timeText[i] )
	end
	self:downTime( "singlepaymax" , timeText , function() return DATA_Activity:getSinglepaymaxDataTime() end ) 
	
	--今天奖励
	local awardProp = {}
	local curAward = data.config.award
	for i = 1 , #curAward do
		local curProp = awardCell( curAward[i] ,{ name = true , star = true } )
		setAnchPos( curProp ,display.cx + ( i - 1 ) * 94 - 33 , 340 )
		self.viewLayer:addChild( curProp )
		awardProp[ #awardProp + 1 ] = curProp
	end
	
	--充值与领取	
	local isPay =  tonumber( data.paynum ) < tonumber( data.config.paymax )
	local isGet =  tonumber( data.received ) ~= 1
	
	local getBtn = KNBtn:new( COMMONPATH , 
		isGet and { "btn_bg_red.png" ,"btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
		display.cx - 72 , 
		222 ,
		{
			priority = -130,
			front = COMMONPATH .. ( isPay and "quick_pay.png" or ( isGet and "quick_get.png" or "quick_get_gray.png") ) ,
			callback = 
			function()
				if isPay then
					pushScene("pay" , { closeFun = function() popScene() end })
				else
					if isGet then
						HTTP:call("activity", "receive_singlepaymax", {},{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					end
				end
			end
		}):getLayer()
	self.viewLayer:addChild( getBtn )
	
	
	self.viewLayer:addChild( display.strokeLabel( "活动说明:" , 54 , 186 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) ) )
	self.viewLayer:addChild( display.strokeLabel( "1.单笔充值满30元即可获1个5星英雄锦囊" , 70 , 163 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) ) )
	self.viewLayer:addChild( display.strokeLabel( "2.请在活动结束前充值，仅此1次，切勿错过" , 70 , 141 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) ) )
		
end
--首充礼包
function M:firstpayActivity()
	self:baseLayout({ line = {} , frame = {} })
	
	local baseY = 107
	
	self.viewLayer:addChild( display.newSprite( PATH .. "firstpay_tip.png" , display.cx , 513 , 0.5 , 0  ) )
	local awardBg = display.newSprite( PATH .. "shade1.png" , display.cx , 275 , 0.5 , 0  ) 
	awardBg:setScaleY(1.4)
	self.viewLayer:addChild( awardBg )
	self.viewLayer:addChild( display.newSprite( PATH .. "firstpay_award_title.png" , 42 , 409 , 0 , 0  ) )
	
	--今天奖励
	local awardProp = {}
	local curAward = data.config.award
	for i = 1 , #curAward do
		local curProp = awardCell( curAward[i] ,{ name = true })
		setAnchPos( curProp ,67 + ( i - 1 ) * 94 , 330 )
		self.viewLayer:addChild( curProp )
		awardProp[ #awardProp + 1 ] = curProp
	end
	
	--领取按钮
	local getBtn = KNBtn:new( COMMONPATH , 
		{ "btn_bg_red.png" ,"btn_bg_red_pre.png"} , 
		60 , 
		145 ,
		{
			priority = -130,
			front = PATH .. "cost_text.png"  ,
			callback = 
			function()
				pushScene("pay" , { closeFun = function() popScene() end })
			end
		}):getLayer()
	self.viewLayer:addChild( getBtn )
	
	local isEnable =  ( tonumber( data.paygold ) ~= 0 and  tonumber( data.received ) == 0 )
	local getBtn = KNBtn:new( COMMONPATH , 
		isEnable and { "btn_bg_red.png" ,"btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
		270 , 
		145 ,
		{
			priority = -130,
			front = COMMONPATH .. ( isEnable and "all_get.png" or "no_all_get.png" ) ,
			callback = 
			function()
				if isEnable  then
					HTTP:call("activity", "receive_firstpay", {},{success_callback = 
					function()
						self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
					end})
				else
--					KNMsg.getInstance():flashShow( "今天奖励已领取！" )
				end
			end
		}):getLayer()
	self.viewLayer:addChild( getBtn )
end
--登陆活动
function M:loginActivity()
	self:baseLayout({ line = {} , frame = {} })
	
	local baseY = 107
	
	local todayBg = display.newSprite( PATH .. "shade1.png" )
	setAnchPos( todayBg , display.cx , baseY + 360 , 0.5 )
	self.viewLayer:addChild( todayBg )
	
	local todayTitle = display.newSprite( PATH .. "today_title.png" )
	setAnchPos(todayTitle , 40 , baseY + 360 + 102 , 0 , 0 )
	self.viewLayer:addChild( todayTitle )
	
	local lastDay = display.newSprite( PATH .. "shade1.png" )
	setAnchPos(lastDay , display.cx , baseY + 193 , 0.5 )
	self.viewLayer:addChild( lastDay )
	local lastTitle = display.newSprite( PATH .. "last_title.png" )
	setAnchPos(lastTitle , 40 , baseY + 193 + 102 , 0 , 0 )
	self.viewLayer:addChild( lastTitle )
	
	--今天奖励
	local awardProp = {}
	for i = 1 , #data.base_award do
		local curProp = awardCell( data.base_award[i] )
		setAnchPos( curProp , ( #data.base_award > 2 and 100 or 140 ) + ( i - 1 ) * 94 , 490)
		self.viewLayer:addChild( curProp )
		awardProp[ #awardProp + 1 ] = curProp
	end
	
	--连续登陆奖励
	local lastData = data.config[data.count .. "" ]["award"]
	for i = 1 , #lastData do
		local curProp = awardCell( lastData[i] )
		setAnchPos( curProp ,( #lastData > 2 and 100 or 140 )+ ( i - 1 ) * 94 , 319)
		self.viewLayer:addChild( curProp )
		awardProp[ #awardProp + 1 ] = curProp
	end
	
	local lastDay = display.strokeLabel( data.count , 163 , 406 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
			dimensions_width = 20,
			dimensions_height = 20,
			align = 1
		})
	self.viewLayer:addChild( lastDay )
	
	--ps
	
--	if CHANNEL_ID == "cmge" then
--		self.viewLayer:addChild( display.strokeLabel( "第2天登录将额外获得500黄金，连续登录天数越多，额外奖励黄金越多" , 60 , 240 , 18 , ccc3( 0xfe , 0x00 , 0x00 ) ,  nil , nil , {
--				dimensions_width = 371,
--				dimensions_height = 50,
--				align = 0
--			})  )
--	end

		
	local str = "连续登陆天数每七天一轮，若登陆中间出现中断，连续天数将重新计算"

	local lastDay = display.strokeLabel( str , 60 , 190 , 18 , ccc3( 0xfe , 0x00 , 0x00 ) , nil , nil , {
			dimensions_width = 371,
			dimensions_height = 50,
			align = 0
		})
	self.viewLayer:addChild( lastDay )
	
	--领取按钮
	local isEnable =  ( tonumber( data.received ) == 0 )
	local getBtn = KNBtn:new( COMMONPATH , 
		isEnable and { "btn_bg_red.png" ,"btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
		display.cx - 72 , 
		140 ,
		{
			priority = -130,
			front = COMMONPATH .. ( isEnable and "all_get.png" or "no_all_get.png" ) ,
			callback = 
			function()
				if isEnable  then
					HTTP:call("activity", "receive_login", {},{success_callback = 
					function()
						self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
					end})
				else
--					KNMsg.getInstance():flashShow( "今天奖励已领取！" )
				end
			end
		}):getLayer()
	self.viewLayer:addChild( getBtn )
	
end

--对酒活动
function M:wineActivity()
	self:baseLayout({ line = {} , frame = {} })
	
	local baseY = 155 
	
	
	local roleSp = display.newSprite( PATH .. "wine_role.png" )
	setAnchPos( roleSp , display.cx , baseY + 275 , 0.5 , 0 )
	self.viewLayer:addChild( roleSp )
	
--	local everydayTime = display.newSprite( PATH .. "everyday_time.png" )
--	setAnchPos( everydayTime , display.cx , baseY + 470  , 0.5 , 0.5 )
--	self.viewLayer:addChild( everydayTime )
	
	local shade = display.newSprite( PATH .. "shade1.png" )
	setAnchPos( shade , display.cx , baseY + 200 - 28  , 0.5 , 0 )
	self.viewLayer:addChild( shade )
	
	local wineTimeSp1 = display.newSprite( PATH .. "wine_one.png" )
	setAnchPos( wineTimeSp1 , 110 - 30  , baseY + 200   , 0 , 0 )
	self.viewLayer:addChild( wineTimeSp1 )
	
	local wineTimeSp2 = display.newSprite( PATH .. "wine_two.png" )
	setAnchPos( wineTimeSp2 , 283  , baseY + 200   , 0 , 0 )
	self.viewLayer:addChild( wineTimeSp2 )
	
	local wineTimeBg = display.newSprite( PATH .. "wine_time_bg.png" )
	setAnchPos( wineTimeBg , display.cx  , baseY + 130  , 0.5 , 0 )
	self.viewLayer:addChild( wineTimeBg )
	
	local wineFlag = display.newSprite( PATH .. "wine_flag.png" )
	setAnchPos( wineFlag , 80  , baseY - 35  , 0 , 0 )
	self.viewLayer:addChild( wineFlag )
	
	local wineTimeText = display.strokeLabel( ""  , display.cx - 316 / 2, baseY + 128 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 316 , dimensions_height = 30 , align = 1 } )
	self.viewLayer:addChild( wineTimeText )
	
	local tempAwardData = { [1] = { cid = data.award.cid , num = data.award.num } , }
	for i = 1 , #tempAwardData do
		local curProp = awardCell( tempAwardData[i] )
		setAnchPos( curProp , display.cx + ( i - 1 ) * 85 + 43 , 190 )
		self.viewLayer:addChild( curProp )
	end
	
	
	
	
	
	local isEnable = false	--是否修改
	local isFrist = true	--是否修改过
	local getBtn
	local function createGetBtn()
		if getBtn then
			getBtn:removeFromParentAndCleanup(true)	-- 清除自己
			getBtn = nil
		end
		getBtn = KNBtn:new( COMMONPATH , 
		isEnable and { "btn_bg_red.png" ,"btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
		display.cx , 
		baseY - 25 ,
		{
			priority = -130,
			front = PATH .. ( isEnable and "my_wine.png" or "my_wine_grey.png" ) ,
			callback = 
			function()
				if isEnable then
					HTTP:call("activity", "receive_wine", {},{success_callback = 
					function()
						self:getAction( { awardProp = "" , onComplete = function() self:selectActivity() end } )
					end})
				else
--					KNMsg.getInstance():flashShow( "今天奖励已领取！" )
				end
			end
		}):getLayer()
		self.viewLayer:addChild( getBtn )
	end
	
	local function refreshTime()
		local str , isShow =  DATA_Activity:getWineInfo()
		wineTimeText:setString( str )
		if isFrist then
			isFrist = false
			isEnable = isShow
			createGetBtn()
		end
		if isEnable ~= isShow then
			isEnable = isShow
			createGetBtn()
		end
	end
	handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(refreshTime , 1 , false)
	refreshTime()
end

--升级活动
function M:lvupActivity()
	
	self:baseLayout({ line = {} })
	
	local function createItem( params )
		params = params or {}
		
		local layer = display.newLayer()
		
		local bg = display.newSprite( PATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		local getTitle = display.newSprite( PATH .. "get_title.png" )
		setAnchPos( getTitle , 14 , 88 )
		bg:addChild( getTitle )
		
		local giftFlag = display.newSprite( PATH .. "gift_flag.png" )
		setAnchPos( giftFlag , 382 , 100 )
		bg:addChild( giftFlag )
		
		local lvBg = display.newSprite( IMG_PATH .. "image/scene/mission/power_bg.png" )
		setAnchPos( lvBg , 108 , 130 )
		bg:addChild( lvBg )
		
		
		local lvGiftText = display.strokeLabel( params.lv .. "级升级大礼包" , 135, 135 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 180 , dimensions_height = 25 , align = 1 } )
		bg:addChild( lvGiftText )
		
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] )
			setAnchPos( curProp , 28 + ( i - 1 ) * 85 , 17 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		
		
		local isEnable =  ( tonumber( DATA_User:get("lv") ) >= tonumber( params.lv ) )
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if tonumber( data.received[j]) == tonumber( params.lv ) then
					isComplete = true
					break
				end
			end
		end
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "btn_bg_dis.png" }  or { "btn_bg.png" ,"btn_bg_pre.png"} ) or { "btn_bg_dis.png" } , 
			360 , 
			18 ,
			{
				priority = -130,
				front = COMMONPATH .. ( isEnable and (isComplete and "get_complete.png" or  "get.png" ) or "get_grey.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						HTTP:call("activity", "receive_lvup", { lv = params.lv },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	local scroll = KNScrollView:new( 0, 94, 480, 543 , 10 , false )
	local sort = {}
	for key , v in pairs(data.config) do
		sort[ #sort + 1 ] = key
	end
	local sortFunc = function(a, b) return b > a end
	table.sort(sort, sortFunc)
	for i = 1 , #sort do
		local curData = data.config[ sort[i].."" ]
		local item = createItem({ lv = sort[i] , data = curData })
		scroll:addChild( item )
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
end

--全民福利
function M:welfareActivity()

	self:baseLayout({ line = {} })
	local scroll = KNScrollView:new( 0, 94, 480, 470 , 10 , false )
	local function createItem( params )
		params = params or {}
		local layer = display.newLayer()
		
		local bg = display.newSprite( COMMONPATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		
		layer:addChild( display.newSprite( PATH .. "vip_bg_bar.png" , 107 , 82 , 0 , 0 ) )
		layer:addChild( display.strokeLabel( "VIP" .. params.viplv .. "及以上用户可领取" , 107, 80 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 231 , dimensions_height = 25 , align = 1 } ) )
		
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] , { parent = scroll } )
			setAnchPos( curProp , 28 + ( i - 1 ) * 85 , 10 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		
		local isEnable =  true
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if tonumber( data.received[j]) == tonumber( params.viplv ) then
					isComplete = true
					break
				end
			end
		end
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "long_btn_grey.png" }  or { "long_btn.png" ,"long_btn_pre.png"} ) or { "long_btn_grey.png" } , 
			305 , 
			18 ,
			{
--				priority = -130,
				parent = scroll , 
				front = COMMONPATH .. ( isEnable and (isComplete and "get_over.png" or  "all_get.png" ) or "get_over.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						
						if params.viplv == 0 and tonumber( DATA_User:get("lv") ) < 10 then
							KNMsg.getInstance():flashShow( "玩家等级达到10级才可领取该奖励，赶快去关卡升级吧！" )
							return 
						end
						
						if  DATA_Vip:get("viplv") < params.viplv then
							KNMsg.getInstance():boxShow( "您的VIP等级未达到，暂不能领取该奖励！" ,{ 
																	confirmText = PATH .. "become_vip.png" , 
																	cancelText = COMMONPATH .. "back.png" , 
																	confirmFun = function() switchScene("pay") end , 
																	cancelFun = function() end 
																	} )
							return
						end
						HTTP:call("activity", "receive_welfare", { index = params.viplv },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	
	local sort = data.config 
	
	for i = 1 , #sort do
		local curData = sort[i]
		local item = createItem( { viplv = i - 1 , data = curData } )
		scroll:addChild( item )
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "activity_awards_title.png" , 25 , 562 , 0 , 0 ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "down_time_tip.png" , display.cx , 605 , 0.5 , 0  ) )
	
	local timeText = {}
	local timeX , timeY = 215 , 610
	for i = 1 , 4 do
		timeText[i] = display.strokeLabel( "00"  , timeX + ( i - 1 )* 50 , timeY , 18 , ccc3( 0xff , 0xfc , 0xd1 ) , nil , nil , {
				dimensions_width = 25,
				dimensions_height = 20,
				align = 1
			})
		self.viewLayer:addChild( timeText[i] )
	end
	self:downTime( "welfare" , timeText , function() return DATA_Activity:getwelfareDataTime() end ) 
end
--超值兑换
function M:xchangeActivity()
	self:baseLayout({ line = {} })
	local scroll = KNScrollView:new( 0, 94, 480, 470 , 10 , false )
	local function createItem( params )
		params = params or {}
		local layer = display.newLayer()
		
		local bg = display.newSprite( COMMONPATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		
		layer:addChild( display.newSprite( PATH .. "add.png" , 102 , 50 , 0 , 0 ) )
		layer:addChild( display.newSprite( PATH .. "equal.png" , 223 , 50 , 0 , 0 ) )
		layer:addChild( display.strokeLabel( "(" .. params.data.have_num .."/" .. params.data.num .. ")" , 370 , 27 , 20 , ccc3( 0 , 0 , 0 ) ) )
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] , { parent = scroll ,  name = true } )
			setAnchPos( curProp , 28 + ( i - 1 ) * 120 , 30 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		
		local isEnable =  tonumber( params.data.have_num ) < tonumber( params.data.num )
		local isComplete = tonumber( params.data.have_num ) >= tonumber( params.data.num )
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "btn_bg_dis.png" }  or { "btn_bg.png" ,"btn_bg_pre.png"} ) or { "btn_bg_dis.png" } , 
			350 , 
			54 ,
			{
				parent = scroll , 
				front = COMMONPATH .. ( isEnable and (isComplete and "get_over.png" or  "xchange.png" ) or "get_over.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						
						if  DATA_Vip:get("viplv") < params.viplv then
							KNMsg.getInstance():boxShow( "您的VIP等级未达到，暂不能领取该奖励！" ,{ 
																	confirmText = PATH .. "become_vip.png" , 
																	cancelText = COMMONPATH .. "back.png" , 
																	confirmFun = function() switchScene("pay") end , 
																	cancelFun = function() end 
																	} )
							return
						end
						HTTP:call("activity", "receive_xchange", { index = params.data.id },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	local sort = data.config 
	for i = 0 , 10 do
		local curData = sort[ i .. "" ]
		if curData then
			local tempLayer = display.newLayer()
			if i ~= 0 then
				local vipFlag = display.newSprite( IMG_PATH .. "image/scene/vip/vip" .. i .. ".png" , 0 , 0 , 0 , 0 ) 
				tempLayer:addChild( display.strokeLabel( "VIP" .. i .. "以上用户可兑换" , 154 , 0 , 20 , ccc3( 0xff , 0xfb , 0xd6 ) ) )
				tempLayer:addChild( vipFlag )
				tempLayer:setContentSize( CCSizeMake( 460 , vipFlag:getContentSize().height  ) )
			else
				tempLayer:addChild( display.strokeLabel( "VIP0以上用户可兑换" , 154 , 0 , 20 , ccc3( 0xff , 0xfb , 0xd6 ) ) )
				tempLayer:setContentSize( CCSizeMake( 460 , 28 )  )
			end
			scroll:addChild( tempLayer )
			for j = 1 , #curData do
				local itmeData = curData[j]
				local item = createItem( { viplv = i - 1 , data = itmeData } )
				scroll:addChild( item )
			end
		end
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "activity_awards_title.png" , 25 , 562 , 0 , 0 ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "down_time_tip.png" , display.cx , 605 , 0.5 , 0  ) )
	
	local timeText = {}
	local timeX , timeY = 215 , 610
	for i = 1 , 4 do
		timeText[i] = display.strokeLabel( "00"  , timeX + ( i - 1 )* 50 , timeY , 18 , ccc3( 0xff , 0xfc , 0xd1 ) , nil , nil , {
				dimensions_width = 25,
				dimensions_height = 20,
				align = 1
			})
		self.viewLayer:addChild( timeText[i] )
	end
	
	self:downTime( "xchange" , timeText , function() return DATA_Activity:getxchangeDataTime() end ) 
end

--好汉目标活动
function M:achieveActivity()
	data.tips = nil
	local text = {}		--任务文字
	local textFlag = {}	--是否完成标记
	local function createPage( index )
		if self.awardProp then
			for i ,v in pairs(self.awardProp) do
				v:removeFromParentAndCleanup(true)	-- 清除自己
			end
		end
		
		local award = data.config[ index .. "" ].award
		
		self.awardProp = {}
		for i = 1 , #award do
			local curProp = awardCell( award[i] )
			setAnchPos( curProp , 50 + ( i - 1 ) * 75 , 220 )
			self.viewLayer:addChild( curProp )
			self.awardProp[ #self.awardProp + 1 ] = curProp
		end
		
		--文字设置
		self.taskText = {}
		local condition = data.config[ index .. "" ].condition
		local isEnable = true
		for i = 1 , 5 do
			local curData = condition[i]
			if i <= #condition then
				local completeState = "  (".. curData.cur .. "/" .. curData.max ..")"
				text[i]:setString( i .. ":" .. curData.str .. completeState)
				if curData.cur >= curData.max then
					text[i]:setColor( ccc3( 0xef , 0x00 , 0x00 ) )
					textFlag[i]:setVisible( true )
				else
					text[i]:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )
					textFlag[i]:setVisible( false )
					isEnable = false 
				end
			else
				text[i]:setString( "" )
				textFlag[i]:setVisible( false )
			end
		end
		
		
		--领取按钮
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if data.received[j] == tonumber( index ) then
					isComplete = true
					break
				end
			end
		end
		
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "btn_bg_red2.png" } or { "btn_bg_red.png" ,"btn_bg_red_pre.png"} )  or { "btn_bg_red2.png" } , 
			display.cx - 72 , 
			140 ,
			{
				priority = -130,
				front = COMMONPATH .. ( isEnable and  (isComplete  and "get_complete.png" or "get.png") or ( isComplete and "get_complete.png" or "get_grey.png" ) ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						HTTP:call("activity", "receive_achieve", { index = index },{success_callback = 
						function()
							self:getAction( { awardProp = self.awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "当前任务未完成不可领取！" )
					end
				end
			}):getLayer()
		self.viewLayer:addChild( getBtn )
		
	end
	
	local group = KNRadioGroup:new()
	for i = 1 , table.nums( data.config ) do
		local tempBtn = KNBtn:new(COMMONPATH.."tab/",{"tab_star_normal.png","tab_star_select.png"} , 10 + (i - 1) * 94 , 643,{
				disableWhenChoose = true,
				upSelect = true,
				id = i,
				front = {COMMONPATH.."tab/tab_target".. i ..".png",COMMONPATH.."tab/tab_target".. i .."_select.png"},
				callback=
				function()
					createPage( i )
				end
			},group):getLayer()
			
		self.viewLayer:addChild( tempBtn )
	end
	
	self:baseLayout({ line = {} , frame = {}  })
	
	local baseY = 107
	
	local shade1 = display.newSprite( PATH .. "shade2.png" )
	setAnchPos( shade1 , display.cx , baseY + 255 , 0.5 )
	self.viewLayer:addChild( shade1 )
	
	local todayTitle = display.newSprite( PATH .. "target_task.png" )
	setAnchPos(todayTitle , 40 , shade1.y + shade1:getContentSize().height - 20 , 0 , 0 )
	self.viewLayer:addChild( todayTitle )
	
	local shade2 = display.newSprite( PATH .. "shade1.png" )
	setAnchPos(shade2 , display.cx , baseY + 91 , 0.5 )
	self.viewLayer:addChild( shade2 )
	local lastTitle = display.newSprite( PATH .. "target_award.png" )
	setAnchPos(lastTitle , 40 , shade2.y + shade2:getContentSize().height - 20 , 0 , 0 )
	self.viewLayer:addChild( lastTitle )
	
	for i = 1 , 5 do
		text[i] = display.strokeLabel( "" , 70, 550 - i * 35 , 18, ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 360 , dimensions_height = 30 , align = 0 } )
		self.viewLayer:addChild( text[i] )
		
		textFlag[i] = display.newSprite( PATH .. "complete_flag.png")
		setAnchPos( textFlag[i] , 48, 566 - i * 35 )
		self.viewLayer:addChild( textFlag[i] )
	end
	
	--生成默认奖励页面
	createPage( 1 )
end



--充值奖励
function M:paymentActivity()
	self:baseLayout({ line = {} , frame = {} })
	local baseY = 107
	
	local todayBg = display.newSprite( PATH .. "payment_bg.png" )
	setAnchPos( todayBg , display.cx , baseY + 30 , 0.5 )
	self.viewLayer:addChild( todayBg )
	
	
	--充值按钮
	local payBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" ,"btn_bg_pre.png"}, 357 , 510 ,
	{
		priority = -149,
		front = COMMONPATH .. "pay.png" ,
		callback = 
		function()
			switchScene("pay")
		end
	}):getLayer()
	self.viewLayer:addChild( payBtn )
	
	
	--累计充值黄金数
	local totalGold = display.strokeLabel( "您已累计充值黄金：" .. data.paygold , 115 , 517 , 18 , ccc3( 0xff , 0xfe , 0xfe ) , nil , nil , {
			dimensions_width = 250,
			dimensions_height = 25,
			align = 0
		})
	self.viewLayer:addChild( totalGold )
	
	
--	local timeText = {}
--	local function refreshTime()
--		local curTime = DATA_Activity:getPayTime()
--		if curTime < 0 then curTime = 0 end
--		for i = 1 , #timeText do
--			if timeText[i] then
--				timeText[i]:removeFromParentAndCleanup(true)
--				timeText[i] = nil
--			end
--		end
--		
--		if curTime <= 0 then
--			Clock:removeTimeFun( "payTime" , refreshTime )
--		end
--		
--		--天
--		local dayNum = math.floor( tonumber(timeConvert( curTime , "hour"))/24 )
--		timeText[1] = display.strokeLabel( dayNum  , 226 , 572 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
--				dimensions_width = 25,
--				dimensions_height = 20,
--				align = 1
--			})
--		self.viewLayer:addChild( timeText[1] )
--		curTime = curTime - dayNum * 86400
--		
--		--时
--		timeText[2] = display.strokeLabel( math.mod( timeConvert( curTime , "hour") , 24 )  , 226 + 42 , 572 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
--				dimensions_width = 25,
--				dimensions_height = 20,
--				align = 1
--			})
--		self.viewLayer:addChild( timeText[2] )
--		--分
--		timeText[3] = display.strokeLabel( timeConvert( curTime , "min")  , 226 + 42 + 42 , 570 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
--				dimensions_width = 25,
--				dimensions_height = 20,
--				align = 1
--			})
--		self.viewLayer:addChild( timeText[3] )
--		--秒
--		timeText[4] = display.strokeLabel( timeConvert( curTime , "sec")  , 226 + 42 + 41 + 40 , 572 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
--				dimensions_width = 25,
--				dimensions_height = 20,
--				align = 1
--			})
--		self.viewLayer:addChild( timeText[4] )
--		
--	end
--	Clock:addTimeFun( "payTime" , refreshTime )
--	上边注销的部分为未做优化前的代码，下面为优化后的代码
		
	local timeText = {}
	local timeX , timeY , offsetX = 226 , 572 , 41
	for i = 1 , 4 do
		timeText[i] = display.strokeLabel( ""  , timeX + ( i - 1 )* offsetX , timeY , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
				dimensions_width = 25,
				dimensions_height = 20,
				align = 1
			})
		self.viewLayer:addChild( timeText[i] )
	end
	self:downTime( "payTime" , function() return DATA_Activity:getPayTime() end)

	
	local function createGet( index )
		local curData = data.config[index .. ""]
		
		local isOne = index == 1
		
		local costGold = tonumber( curData.condition ) - tonumber( data.paygold )
		local isEnable = costGold <= 0	--是否可领取
		costGold = isEnable and 0 or costGold	--保证不能出现负数
		
		
		local payGold = display.strokeLabel( costGold , 107 , isOne and 473 or 348 , 18 , ccc3( 0x2e , 0x00 , 0x03 ) , nil , nil , {
			dimensions_width = 44,
			dimensions_height = 20,
			align = 1
		})
		self.viewLayer:addChild( payGold )
		
		
		for i = 1 , #curData.award do
			local curProp = awardCell( curData.award[i] )
			setAnchPos( curProp , 100 , isOne and 390 or 260 )
			self.viewLayer:addChild( curProp )
		end
		
		
		
		--领取按钮
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if data.received[j] == tonumber( index ) then
					isComplete = true
					break
				end
			end
		end
		
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "btn_bg_red2.png" } or { "btn_bg_red.png" ,"btn_bg_red_pre.png"} )  or { "btn_bg_red2.png" } , 
			245 , 
			isOne and 400 or 274 ,
			{
				priority = -130,
				front = COMMONPATH .. ( isEnable and  (isComplete  and "get_complete.png" or "get.png") or ( isComplete and "get_complete.png" or "get_grey.png" ) ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						HTTP:call("activity", "receive_payment", { index = index },{success_callback = 
						function()
							self:getAction( { awardProp = self.awardProp , onComplete = function() self:selectActivity() end } )
						end})
					end
				end
			}):getLayer()
		self.viewLayer:addChild( getBtn )
	end
	
	for i = 1 , table.nums( data.config ) do
		createGet( i )
	end
	
end

--累积登陆 中秋送礼
function M:logincountActivity()
	self:baseLayout({ line = {} })
	local scroll = KNScrollView:new( 0, 164, 480, 400 , 10 , false )
	local function createItem( params )
		params = params or {}
		local layer = display.newLayer()
		
		local bg = display.newSprite( COMMONPATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		
		layer:addChild( display.newSprite( PATH .. "vip_bg_bar.png" , 107 , 82 , 0 , 0 ) )
		layer:addChild( display.strokeLabel( "累计登陆" .. params.condition .. "天可领" , 107, 80 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 231 , dimensions_height = 25 , align = 1 } ) )
		
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] , { parent = scroll } )
			setAnchPos( curProp , 28 + ( i - 1 ) * 85 , 10 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		local isEnable =  true
--		local isEnable =  tonumber( data.payyuan ) >= tonumber( params.condition )
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if tonumber( data.received[j]) == tonumber( params.index ) then
					isComplete = true
					break
				end
			end
		end
		
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "long_btn_grey.png" }  or { "long_btn.png" ,"long_btn_pre.png"} ) or { "long_btn_grey.png" } , 
			305 , 
			18 ,
			{
				parent = scroll , 
				front = COMMONPATH .. ( isEnable and (isComplete and "get_over.png" or  "get_award.png" ) or "get_award_grey.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						
						if tonumber( data.daycount ) < tonumber( params.condition ) then
							KNMsg.getInstance():flashShow( "未达到领取要求,暂不能领取！" )
							return
						end
						
						HTTP:call("activity", "receive_logincount", { index = params.index },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	local sort = data.config 
	for i = 1 , table.nums( sort ) do
		local curData = sort[i .. "" ]
		local item = createItem( { index = i , condition = curData.condition , data = curData } )
		scroll:addChild( item )
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "activity_awards_title.png" , 25 , 562 , 0 , 0 ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "end_time.png" , 20 , 605 , 0 , 0  ) )
	self.viewLayer:addChild(display.strokeLabel( data.endtime  , 160 , 610 , 20 , ccc3( 0xff , 0xfc , 0xd1 ) ) )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "add_up_day.png" , 286 , 562 , 0 , 0 ) )	--累计登陆天数
	self.viewLayer:addChild( display.strokeLabel( data.daycount  , 407  , 563 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 32 , dimensions_height = 25 , align = 1 } ) )	--累计登陆天数
	
	
	
	
	self.viewLayer:addChild( display.newSprite( PATH .. "vip3_taste.png" , 40 , 120 , 0 , 0  ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "down_time_text.png" , display.cx + 75 , 120 , 0.5 , 0  ) )
	
	local timeText = {}
	local timeX , timeY = 215 , 125
	for i = 1 , 4 do
		timeText[i] = display.strokeLabel( "00"  , timeX + ( i - 1 )* 50 , timeY , 18 , ccc3( 0xff , 0xfc , 0xd1 ) , nil , nil , {
				dimensions_width = 25,
				dimensions_height = 20,
				align = 1
			})
		self.viewLayer:addChild( timeText[i] )
	end
	self:downTime( "logincount" , timeText , function() return DATA_Activity:getlogincountDataTime() end ) 
end
--单充大礼
function M:singlepayActivity()
	
	self:baseLayout({ line = {} })
	local scroll = KNScrollView:new( 0, 94, 480, 470 , 10 , false )
	local function createItem( params )
		params = params or {}
		local layer = display.newLayer()
		
		local bg = display.newSprite( COMMONPATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		
		layer:addChild( display.newSprite( PATH .. "vip_bg_bar.png" , 107 , 82 , 0 , 0 ) )
		layer:addChild( display.strokeLabel( "单笔充值" .. params.condition .. "元可领" , 107, 80 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 231 , dimensions_height = 25 , align = 1 } ) )
		
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] , { parent = scroll } )
			setAnchPos( curProp , 28 + ( i - 1 ) * 85 , 10 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		local isEnable =  true
--		local isEnable =  tonumber( data.payyuan ) >= tonumber( params.condition )
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if tonumber( data.received[j]) == tonumber( params.index ) then
					isComplete = true
					break
				end
			end
		end
		
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "long_btn_grey.png" }  or { "long_btn.png" ,"long_btn_pre.png"} ) or { "long_btn_grey.png" } , 
			305 , 
			18 ,
			{
				parent = scroll , 
				front = COMMONPATH .. ( isEnable and (isComplete and "get_over.png" or  "get_award.png" ) or "get_award_grey.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						
						local isExist = false
						for key , v in pairs( data.pay ) do
							if tonumber(v) == tonumber( params.condition ) then
								isExist = true
								break
							end
						end
						
						if not isExist then
							KNMsg.getInstance():boxShow( "只有单笔充值" .. params.condition .. "元才可领取该奖励,你当前充值的金额未达到,暂不能领取该奖励" ,{ 
																	confirmText = COMMONPATH .. "pay.png" , 
																	cancelText = COMMONPATH .. "back.png" , 
																	confirmFun = function() switchScene("pay") end , 
																	cancelFun = function() end 
																	} )
							return
						end
						
						HTTP:call("activity", "receive_singlepay", { index = params.index },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	local sort = data.config 
	for i = 1 , table.nums( sort ) do
		local curData = sort[i .. "" ]
		local item = createItem( { index = i , condition = curData.condition , data = curData } )
		scroll:addChild( item )
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "activity_awards_title.png" , 25 , 562 , 0 , 0 ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "end_time.png" , 20 , 605 , 0 , 0  ) )
	self.viewLayer:addChild(display.strokeLabel( data.endtime  , 160 , 610 , 20 , ccc3( 0xff , 0xfc , 0xd1 ) ) )
	
end
--累积冲值 累充大礼
function M:paycountActivity()
	self:baseLayout({ line = {} })
	local scroll = KNScrollView:new( 0, 94, 480, 470 , 10 , false )
	local function createItem( params )
		params = params or {}
		local layer = display.newLayer()
		
		local bg = display.newSprite( COMMONPATH .. "item_bg.png" )
		setAnchPos( bg , 0 , 0 )
		layer:addChild( bg )
		
		
		layer:addChild( display.newSprite( PATH .. "vip_bg_bar.png" , 107 , 82 , 0 , 0 ) )
		layer:addChild( display.strokeLabel( "累积充值" .. params.condition .. "元可领" , 107, 80 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) , nil , nil , { dimensions_width = 231 , dimensions_height = 25 , align = 1 } ) )
		
		local itemAwardData = params.data.award
		local awardProp = {}
		for i = 1 , #itemAwardData do
			local curProp = awardCell( itemAwardData[i] , { parent = scroll } )
			setAnchPos( curProp , 28 + ( i - 1 ) * 85 , 10 )
			layer:addChild( curProp )
			awardProp[ #awardProp + 1 ] = curProp
		end
		
		local isEnable =  true
--		local isEnable =  tonumber( data.payyuan ) >= tonumber( params.condition )
		local isComplete = false
		if data.received then
			--是否已经领取
			for j = 1 , #data.received do
				if tonumber( data.received[j]) == tonumber( params.index ) then
					isComplete = true
					break
				end
			end
		end
		
		local getBtn = KNBtn:new( COMMONPATH , 
			isEnable and ( isComplete and { "long_btn_grey.png" }  or { "long_btn.png" ,"long_btn_pre.png"} ) or { "long_btn_grey.png" } , 
			305 , 
			18 ,
			{
				parent = scroll , 
				front = COMMONPATH .. ( isEnable and (isComplete and "get_over.png" or  "get_award.png" ) or "get_award_grey.png" ) ,
				callback = 
				function()
					if isEnable and not isComplete then
						if isBagFull() then
						    return false
						end
						
						if  tonumber( data.payyuan ) < tonumber( params.condition ) then
							KNMsg.getInstance():boxShow( "累计充值" .. params.condition .. "元才可领取该奖励,你当前充值的金额未达到,暂不能领取该奖励" ,{ 
																	confirmText = COMMONPATH .. "pay.png" , 
																	cancelText = COMMONPATH .. "back.png" , 
																	confirmFun = function() switchScene("pay") end , 
																	cancelFun = function() end 
																	} )
							return
						end
						
						HTTP:call("activity", "receive_paycount", { index = params.index },{success_callback = 
						function()
							self:getAction( { awardProp = awardProp , onComplete = function() self:selectActivity() end } )
						end})
					else
--						KNMsg.getInstance():flashShow( "今天奖励已领取！" )
					end
				end
			}):getLayer()
		layer:addChild( getBtn )
		
		
		layer:setContentSize( bg:getContentSize() )
		return layer
	end
	
	local sort = data.config 
	for i = 1 , table.nums( sort ) do
		local curData = sort[i .. "" ]
		local item = createItem( { index = i , condition = curData.condition , data = curData } )
		scroll:addChild( item )
	end
	scroll:alignCenter()
	self.viewLayer:addChild(scroll:getLayer() )
	
	self.viewLayer:addChild( display.newSprite( PATH .. "activity_awards_title.png" , 25 , 562 , 0 , 0 ) )
	self.viewLayer:addChild( display.newSprite( PATH .. "add_up_pay.png" , 239 , 562 , 0 , 0 ) )	--累计充值
	self.viewLayer:addChild( display.strokeLabel( data.payyuan .. "元" , 380, 566 , 18, ccc3( 0xfd , 0xfa , 0xd7 ) ) )	--累计充值
	self.viewLayer:addChild( display.newSprite( PATH .. "end_time.png" , 20 , 605 , 0 , 0  ) )
	self.viewLayer:addChild(display.strokeLabel( data.endtime  , 160 , 610 , 20 , ccc3( 0xff , 0xfc , 0xd1 ) ) )
	
end

return M