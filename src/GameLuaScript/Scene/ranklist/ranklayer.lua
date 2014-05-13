local PATH = IMG_PATH.."image/scene/ranklist/"
local Btn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local RadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local Progress = requires(IMG_PATH, "GameLuaScript/Common/KNProgress")
local Item = requires(IMG_PATH, "GameLuaScript/Scene/ranklist/rankitem")
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local RankLayer = {
	layer,
	group,
	rankLayer,
	page,
	pageText,
	curType,
	noMore
}

function RankLayer:new(kind)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.page = 1
	
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(bg,0,425,0,0.5)
	this.layer:addChild(bg)
	
	this.group = RadioGroup:new()
	
	--榜单类型按钮
	local rankType = {
		{"athletics"},
		{"level"},
		{"ability"},
	}
	
	local x = 80
	for k, v in pairs(rankType) do
		
		local temp = Btn:new(COMMONPATH.."tab/",{"tab_star_normal.png", "tab_star_select.png"},x, 680, {
			id = v[1],
			front = PATH..v[1]..".png",
			callback = function()
				this.page = 1
				this.noMore = false
--				if DATA_Rank:get(v[1]) then
--					if v[1] == "athletics" then
--						HTTP:call("ranking","get",{type = v[1]},{success_callback=function()
--							this:createRankLayer(v[1])
--						end})
--					else
--						this:createRankLayer(v[1])
--					end
--				else
					HTTP:call("ranking","get",{type = v[1]},{success_callback=function()
						this:createRankLayer(v[1])
					end})
--				end
			end
		}, this.group)
		this.layer:addChild(temp:getLayer())
		x = x + 120
	end
	
	bg = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(bg, 10 , 675)
	this.layer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."page_bg.png")
	setAnchPos(bg,240,110,0.5)
	this.layer:addChild(bg)
	
	--翻页按钮
	local pre = Btn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
		scale = true,
		flipX = true,
		callback = function()
			if this.page > 1 then
				this.page = this.page - 1
				this.noMore = false
				this:createRankLayer(this.curType)
			end
		end
	})
	this.layer:addChild(pre:getLayer())
	
	local next = Btn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
		scale = true,
		callback = function()
			if not this.noMore then
				this.page = this.page + 1
				this:createRankLayer(this.curType)
			end
		end
	})
	this.layer:addChild(next:getLayer())
	
	
	-- 需要延迟发包
	local handle
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil
		
		this.group:chooseById(kind,true)
	end , 0.05 , false )
	
	local info = InfoLayer:new("rank", 0, {title_text = PATH.."rank_text.png" })
	this.layer:addChild(info:getLayer())
	
	return this
end

--创建排行列表
function RankLayer:createRankLayer(kind)
	if self.rankLayer then
		self.layer:removeChild(self.rankLayer:getLayer(),true)
	end	
	
	if self.pageText then
		self.layer:removeChild(self.pageText, true)
	end
	
	self.curType = kind
	self.rankLayer = KNScrollView:new(0, 160, 480, 510) 
	
--	local progress = Progress:new(IMG_PATH.."image/start_bar/bar/",{"bg.png","fore.png"},100,300)
--	self.rankLayer:addChild(progress:getLayer())
--	
	local y = 560
	local max = DATA_Rank:get(kind,"count") - (self.page - 1) * 20 
	if max > 20 then
		max = 20 
	else
		self.noMore = true
	end
	for i = 1, max do
		local temp = Item:new(kind, 15, y, i + (self.page - 1) * 20, self.rankLayer)
		self.rankLayer:addChild(temp:getLayer())
		
		y = y - temp:getHeight() - 10
	end
	self.rankLayer:alignCenter()
	
	self.pageText = display.strokeLabel(self.page.."/"..math.ceil(DATA_Rank:get(kind,"count") / 20) ,230,117,20,ccc3(0xff,0xfb,0xd4))
	setAnchPos(self.pageText, 240, 117, 0.5)
	self.layer:addChild(self.pageText)
	
	self.layer:addChild(self.rankLayer:getLayer())
end

function RankLayer:getLayer()
	return self.layer
end

return RankLayer