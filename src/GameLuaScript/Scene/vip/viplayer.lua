local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local KNBar = requires(IMG_PATH , "GameLuaScript/Common/KNBar")
local KNTextField = requires(IMG_PATH,"GameLuaScript/Common/KNTextField")
local PATH = IMG_PATH.."image/scene/vip/"
local baseElement = requires(IMG_PATH , "GameLuaScript/Scene/common/baseElement")
local M = {
}

function M:new(params)
	params = params or {}
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	local data = DATA_Vip:get("vip")
	this.baseLayer = display.newLayer()
	local layer = display.newLayer()
	
	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild(bg)
	local highLv = 8	--定义最高vip等级
	
	local nextLv = DATA_Vip:get("viplv") + 1
	nextLv = nextLv>highLv and highLv or nextLv
	
	layer:addChild( display.newSprite( IMG_PATH .. "image/scene/gang/hall/notice_bg2.png" , display.cx ,  618 , 0.5 , 0 ) )
	
	local tempBar = KNBar:new("exp_general" , 131 , 183 , { maxValue = data.lvup_exp , curValue = data.cur_exp , color = ccc3(255, 255, 255) })
	tempBar:setIsShowText( nextLv <= highLv )
	layer:addChild( tempBar )
	
	layer:addChild( display.newSprite( PATH .. "cur_vip.png" , 55 ,  654 , 0 , 0 ) )	-- 当前vip等级
	layer:addChild( display.newSprite( PATH .. "cur_vip_title.png" , 150 ,  694 , 0 , 0 ) )	-- 当前vip等级
	if DATA_Vip:get("viplv") <= ( highLv-1 )  then
		layer:addChild( display.newSprite( PATH .. "need_gold.png" , 55 ,  630 , 0 , 0 ) )	--再充值多少黄金即可成为vipN
		layer:addChild( display.strokeLabel( nextLv , 330 , 633 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) ))
		
		local nextGold = data.lvup_exp - data.cur_exp	--到下级还需要充值多少
		nextGold = nextGold<10000 and nextGold or math.floor(nextGold/10000) .. "万"
		layer:addChild( display.strokeLabel( nextGold , 126 , 633 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
				dimensions_width = 53 ,
				dimensions_height = 24,
				align = 1
			}) )
	end 
	layer:addChild( display.strokeLabel( DATA_Vip:get("viplv") , 275 , 696 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
			dimensions_width = 100 ,
			dimensions_height = 24,
			align = 0
		}) )

	

	
	local configData = data.config
	local scroll = KNScrollView:new( 10 , 103 , 460 , 500 , 5 )
	for i = 1 , #configData do
		local tempItem = this:itemCell( { data = configData[i] , parent = scroll , isShowLine = i ~= 6 } )
		scroll:addChild(tempItem , tempItem )
	end
	scroll:alignCenter()
	layer:addChild( scroll:getLayer() )
	
	scroll:setIndex( DATA_Vip:get( "viplv" ) , true )
	
	layer:addChild( display.newSprite( COMMONPATH.."tab_line.png"  , 6 , 607 , 0 , 0 ) )
	this.baseLayer:addChild(layer)
	
	-- 充值按钮
	local charge_btn = KNBtn:new( SCENECOMMON .. "navigation" , {"na_charge.png" , "na_charge_pre.png"} , 363 , 640 , {
		priority = -130,
		callback = function()
			switchScene("pay")
		end,
		scale = true,
	})
	layer:addChild(charge_btn:getLayer())
	
	--导航信息
	local info = InfoLayer:new( "vip" , 0 , {tail_hide = true , title_text = PATH .. "vip_title.png"})
	this.baseLayer:addChild(info:getLayer() , 2)
	return this.baseLayer
end

function M:itemCell( params )
	params = params or {}
	local data = params.data or {}
	local isShowLine = params.isShowLine
	
	local layer = display.newLayer()
	
	if isShowLine then
		layer:addChild( display.newSprite( IMG_PATH .. "image/scene/notice/line.png" 	, display.cx , 3 , 0.5 , 0  ) )
	end
	
	local pathStr
	if data.status == 0 then
		pathStr = "get_grey.png"
	elseif data.status == 1 then
		pathStr = "get_over.png"
	elseif data.status == 2 then
		pathStr = "quick_get.png"
	end
	local getBtn = KNBtn:new( COMMONPATH , 
		{ "btn_bg_red.png" ,"btn_bg_red_pre.png" , "btn_bg_red2.png" } , 
		154 , 15 ,
		{
			parent = params.parent ,
--			priority = -130,
			front = COMMONPATH .. pathStr ,
			callback = 
			function()
				HTTP:call( "vip" , "receive", { lv = data.lv },{success_callback = 
				function()
--					switchScene( "vip" )
				end})
			end
		})
	getBtn:setEnable( data.status == 2 )
	layer:addChild( getBtn:getLayer() )
	
	layer:addChild( display.newSprite( IMG_PATH .. "image/scene/activity_new/shade1.png" , display.cx , 68 , 0.5 , 0  ) )	--奖励背景
	layer:addChild( display.newSprite( PATH .. "vip_awards_title.png"	 	, 100 , 165 , 0 , 0  ) )
	layer:addChild( display.strokeLabel( data.lv , 133 , 167 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) ) )
	
	--奖励
	local awardData = data.gift
	for i = 1 , #awardData do
		local curProp = awardCell( awardData[i] )
		setAnchPos( curProp , 100 + ( i - 1 ) * 84 , 90 )
		layer:addChild( curProp )
	end
	
	local addY = 204 
	local noticeText = KNTextField:create( { str = data.privilege , size = 18  , color = ccc3( 0xff , 0xfb , 0xd5 ) , width = 345 } )
	addY = addY + noticeText:getContentSize().height
	setAnchPos( noticeText ,  110 , addY , 0 , 1 )
	layer:addChild( noticeText )
	
	addY = addY + 20
	layer:addChild( display.newSprite( PATH .. "tip_title.png" 				, 100 , addY , 0 , 0  ) )
	layer:addChild( display.newSprite( PATH .. "vip" .. data.lv .. ".png" 	, 0 , addY + 25  , 0 , 0  ) )
	layer:addChild( display.strokeLabel( data.gold , 177 , addY + 35 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) , nil , nil , {
		dimensions_width = 70 ,
		dimensions_height = 24,
		align = 1
	}) )
	
	addY = addY + 60 + 30
	

	layer:setContentSize( CCSize:new(  460 , addY  ) )
	return layer
end

				
return M