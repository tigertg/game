-- 设置界面
local PATH = IMG_PATH .. "image/scene/notice/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNTextField = requires(IMG_PATH,"GameLuaScript/Common/KNTextField")
local M = {

}


function M:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	local mask
	local layer = display.newLayer()
	
	local noticeData = DATA_Notice:get()
	if not noticeData.broadcast then
		return "not notice"
	end
	
	
	local height = 0
	local addY = 0
	-- 背景
	local bg = display.newSprite(PATH .. "bg.png")
	setAnchPos( bg , display.cx , display.cy , 0.5 , 0.5 )
	layer:addChild( bg )
	layer:addChild( display.newSprite( PATH .. "title.png" , display.cx , 674 , 0.5 , 0  ) )
	
	--游戏公告标题
	local contentLayer = display.newLayer()
	
	
	local scroll = KNScrollView:new( 20 , 200 , 440 , 490 , 20 , false , 0 , { priority = -150} )
	
	local function createTitle( name )
		local titleBg = display.newSprite( PATH .. "title_bg.png")
		local nameSp = display.newSprite( PATH .. name .. ".png" )
		titleBg:addChild( nameSp )
		setAnchPos( nameSp , 6 , 0 , 0 , 0 )
		return titleBg
	end

	--公告标题
	addY = addY - 40
	local noticeTitle = createTitle("notice_title")
	setAnchPos( noticeTitle , 33 , addY   )
	contentLayer:addChild( noticeTitle )
	
	local str = noticeData.broadcast.content
	local noticeText = KNTextField:create( { str = str , size = 18  , color = ccc3( 0x38 , 0xff , 0xfd ) , width = 380 } )
	addY = addY - noticeText:getContentSize().height - 10
	setAnchPos( noticeText ,  50 , addY )
	contentLayer:addChild( noticeText )
	
	
	--活动标题
	local activityTitle = createTitle("activity_title")
	addY = addY - activityTitle:getContentSize().height - 10
	setAnchPos( activityTitle , 33 , addY )
	contentLayer:addChild( activityTitle )
	
	local function createItem( params )
		params = params or {}
		local titleStr = params.title		--文字标题
		local titleColor = params.titleColor or ccc3( 0xfe , 0x00 , 0x00 )	--标题文字颜色
		local titleSize = params.titleSize or 20	--标题文字大小
		
		local contextStr = params.content	--文字内容
		local contextColor = params.contextColor or ccc3( 0xff , 0xfb , 0xd4 )	--文字颜色
		local contextSize = params.contextSize or 18	--文字大小
		
		local isLine = params.isShowLine	--是否显示分割线
		
		local tempY = 0
		local itemLayer = display.newLayer()
		

		
		--活动标题
		local itemTitleText = KNTextField:create( { str = titleStr , size = titleSize  , color = titleColor , width = 380 } )
		tempY = tempY - itemTitleText:getContentSize().height
		setAnchPos( itemTitleText ,  0 , tempY , 0 , 0 )
		itemLayer:addChild( itemTitleText )
		
		--活动内容
		local itemTitleText = KNTextField:create( { str = contextStr , size = contextSize  , color = contextColor , width = 380 } )
		tempY = tempY - itemTitleText:getContentSize().height - 10
		setAnchPos( itemTitleText ,  0 , tempY , 0 , 0)
		itemLayer:addChild( itemTitleText )
		
		if isLine then
			local lineSp = display.newSprite(PATH .. "line.png")
			tempY = tempY - 10
			setAnchPos( lineSp , 0 , tempY , 0 , 0)
			itemLayer:addChild( lineSp )
		end
		itemLayer:setContentSize( CCSizeMake( 380 , math.abs( tempY ) ) )
		return itemLayer		
	end
	
	local activityTable = noticeData.activity or {}
--	activityTable = {
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--		{title = "测试数据7" , content = "一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二一二三二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二三一二" } , 
--	}
	
	addY = addY - 10
	for i = 1 , #activityTable do
		local tempData = { title = activityTable[i].title ,  content = activityTable[i].content , isShowLine = i ~= #activityTable  }
		local item = createItem( tempData )
		setAnchPos( item , 50 , addY , 0 , 0 )
		addY = addY - item:getContentSize().height - 10
		contentLayer:addChild( item )
	end
	
	
	addY = addY - 20
	local tempLayer = display.newLayer()
	tempLayer:addChild( contentLayer )
	setAnchPos(contentLayer , 0 , math.abs( addY ) ,0 , 0 )
	tempLayer:setContentSize( CCSizeMake( 480 , math.abs( addY ) ) )
	
	scroll:addChild( tempLayer )
	scroll:alignCenter()
	layer:addChild(scroll:getLayer() )
	
	
	
	
	
	--关闭
	local closeBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, display.cx - 72 , 130 ,
	{
		priority = -149,
		front = COMMONPATH .. "colse_text.png" ,
		callback = 
		function()
			mask:remove()
		end
	}):getLayer()
	layer:addChild( closeBtn )
	
	layer:setScale(0.1)
	transition.scaleTo(layer , {time = 0.1 , scale = 1 , easing = "BACKOUT" })
	setAnchPos( layer , 0 , 26 )
	
	mask = KNMask:new({ item = layer , priority = -148 })
	return mask
end



return M