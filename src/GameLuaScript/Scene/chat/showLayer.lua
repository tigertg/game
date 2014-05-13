local PATH = IMG_PATH.."image/scene/chat/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH, "GameLuaScript/Common/KNRadioGroup")
local contentLayer = requires(IMG_PATH,"GameLuaScript/Scene/chat/contentLayer")
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")

--[[
	首页
]]
local showLayer = {
	baseLayer,
	layer,
	infoLayer,
}

function showLayer:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	this.back_data = {}
	this.is_show_dialog = false
	local handle = CCDirector:sharedDirector():getScheduler()
	this.dialog = nil

	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()

	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)
	this.layer:addChild(bg)
	
	
	-- 导航
	local tabConfig = {
		{
			"system",
			"system.png",
			"system_big.png",
		},
		{
			"battle",
			"battle.png",
			"battle_big.png",
		},
		{
			"consume",
			"consume.png",
			"consume_big.png",
		},
		{
			"social",
			"social.png",
			"social_big.png",
		},
	}


	local defaultTab = 1
	local msg_num = DATA_Chat:getNum()
	if msg_num > 0 then
		defaultTab = 2

		DATA_Chat:setNum(0)
	end

	local temp
	local startX , startY = 10 , 690
	this.group = KNRadioGroup:new()
	for i = 1, #tabConfig do
		temp = KNBtn:new(COMMONPATH .. "tab" , { "tab_star_normal.png" , "tab_star_select.png" } , startX , startY , {
			front = { PATH .. tabConfig[i][2] , PATH .. tabConfig[i][3]},
			disableWhenChoose = true,
			id = tabConfig[i][1],
			callback = function()
				if this.infoLayer ~= nil then
					this.layer:removeChild(this.infoLayer:getLayer() , true)
				end

				this.infoLayer = contentLayer:new(tabConfig[i][1] , this)
				this.layer:addChild(this.infoLayer:getLayer())
			end
		} , this.group)

		this.layer:addChild(temp:getLayer())
		startX = startX + temp:getWidth() + 4
	end
	
	--公告按钮
	local noticeBtn = KNBtn:new( COMMONPATH , { "btn_bg.png" ,"btn_bg_pre.png"}, startX , 690 ,
	{
		priority = -149,
		front = COMMONPATH .. "notice.png" ,
		callback = 
		function()
			local noticeLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/notice")
			local curScene = display.getRunningScene()
			local temp = noticeLayer:new()
			if temp ~= "not notice" then
				curScene:addChild( temp:getLayer() )
			else
				KNMsg.getInstance():flashShow( "当前没有公告！" )
			end
			
		end
	}):getLayer()
	this.layer:addChild(noticeBtn)
	


	-- 线
	local line = display.newSprite(COMMONPATH .. "tab_line.png")
	setAnchPos(line , 6 , 685)
	this.layer:addChild(line)

	-- 具体展示数据
	this.group:chooseByIndex( defaultTab , false )
	this.infoLayer = contentLayer:new( tabConfig[defaultTab][1] , this)
	this.layer:addChild(this.infoLayer:getLayer())


	this.baseLayer:addChild( this.layer )
	local info = infoLayer:new("chat" , 0 , {tail_hide = true , title_text = PATH .. "title.png"}):getLayer()
	this.baseLayer:addChild( info )

		
    return this
end


function showLayer:getLayer()
	return self.baseLayer
end


--[[刷新所有聊天消息]]
function showLayer:refreshChatContent(message_type)
	if message_type == "talk" and self.infoLayer ~= nil and self.group:getId() == "talk" then
		self.infoLayer:refresh(message_type)
	end
end

return showLayer
