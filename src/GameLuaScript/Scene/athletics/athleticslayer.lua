
--前十，被打败，可挑战，自己，后方
local TOPTEN, ENEMY, FIGHT,SELF, BACK = 1, 2, 3, 4, 5
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local PATH = IMG_PATH.."image/scene/athletics/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local AthleticsLayer = {
	baseLayer,
	layer,
	fightLayer,
	data
}

function AthleticsLayer:new(data)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.baseLayer = display.newLayer()
	this.data = data

	local bg = display.newSprite(SCENECOMMON.."bg.png")
	local tipBg = display.newSprite(COMMONPATH.."dark_bg.png")

	setAnchPos(bg)
	setAnchPos(tipBg,245,424,0.5,0.5)

	this.baseLayer:addChild(bg)
	this.baseLayer:addChild(tipBg)
	
	local str, front, noTouch
	if data["data"].is_award == 0 then
		if this.data["data"]["yesterday_award"]["fame"] == 0 then
			str = {"btn_bg_red2.png"}
			front = COMMONPATH.."get_grey.png"
		else
			str = {"btn_bg_red.png", "btn_bg_red_pre.png"}
			front = PATH.."get_gift.png"
		end
	elseif data["data"].is_award == 1 then
		str = {"btn_bg_red2.png"}
		front = PATH.."get_gift_grey.png"
		noTouch = true
	else
		str = {"btn_bg_red2.png"}
		front = COMMONPATH.."get_grey.png"
	end
	
	local refresh = KNBtn:new(COMMONPATH,str,330,105,{
		front = front,
		noTouch = noTouch,
		callback=
		function()
			if data["data"].is_award == -1 then
				KNMsg.getInstance():flashShow("您昨天还没有名次，请明天再来吧！~")
			else
				if this.data["data"]["yesterday_award"]["fame"] == 0  then
					KNMsg.getInstance():flashShow("需要在1000名之前才能领取每日奖励哦")
				else
					HTTP:call("athletics", "award", {}, {success_callback = 
						function(data)
							switchScene("athletics", {data = data["get"]},function()
								KNMsg.getInstance():flashShow("成功领取奖励，今天请继续努力吧")
							end)
						end})
				end
			end
		end
	})
	this.baseLayer:addChild(refresh:getLayer())
	
	
	
	local award
	award = display.newSprite(PATH.."fame.png")
	setAnchPos(award, 20, 115)
	this.baseLayer:addChild(award)
	
	award = display.strokeLabel(this.data["data"]["yesterday_award"]["fame"] or 0, 130, 115, 18, ccc3(0xff,0xfb,0x4d))
	this.baseLayer:addChild(award)
	
	
	
	
	this:createMain()
	
	local info = InfoLayer:new("athletics", 0, {title_text = PATH.."tip_text.png", closeCallback = function()
		switchScene("pvp")
	end })
	this.baseLayer:addChild(info:getLayer(),2)
	return this
end


function AthleticsLayer:getLayer()
	return self.baseLayer
end

--竞技排行主页
function AthleticsLayer:createMain(challenge)
	if self.fightLayer then
		self.baseLayer:removeChild(self.fightLayer,true)
	end
	
	if self.layer then
		self.baseLayer:removeChild(self.layer,true)
	end
	self.layer = display.newLayer()
	self.layer:addChild(self:createInfo(self.data["data"]))
	
	local scroll = KNScrollView:new(30,155, 440, 480, 5)
	
	local list = {
		{self.data["data"]["rank"],TOPTEN}, --topTen
		{self.data["data"]["enermy"],ENEMY},
		{self.data["data"]["list"],FIGHT},
		{{{rank = self.data["data"]["my_rank"], name = DATA_User:get("name"), lv = DATA_User:get("lv")}},SELF},
		{self.data["data"]["next"],BACK},
	}
	local count, my = 0, 0
	for i = 1, #list do
		for j = 1, #list[i][1]	do
			local skip 
--			if i == 5 and tonumber(list[i][1]["rank"]) <= 10 then
--				skip = true
--			end
			
			if not skip then
				local item = self:createItem(list[i][2],scroll,list[i][1][j])
				setAnchPos(item,50, 300)
				scroll:addChild(item, item)		
				if list[i][2] ~= SELF then
					count = count + 1
				else
					my = count
				end
				
			end
		end
	end
	self.layer:addChild(scroll:getLayer())
	
	if self.data.offset then
		scroll:setOffset(self.data.offset)
	end
	scroll:setIndex(my, true)
	scroll:effectIn()

	self.baseLayer:addChild(self.layer)
end
--
--竞技挑战页
function AthleticsLayer:createItem(state,parent,data)
	local layer = display.newLayer()
	
	local str, text, offset
	if state == SELF then
		str = PATH.."self_bg.png"
		offset = -20
	else
		str = PATH.."rank_bg.png"
		offset = 0
	end
	
	local itemBg = display.newSprite(str)
	setAnchPos(itemBg)
	layer:addChild(itemBg)
	layer:setContentSize(itemBg:getContentSize())
	
	local icon = KNBtn:new(PATH,{"icon.png"},20,35 + offset,{
		scale = true , 
		parent = parent,
		callback = 
		function()
			if not data.uid  then
				switchScene("userinfo")
			else
				HTTP:call("profile","get",{ touid = data.uid },{success_callback = 
					function()
						local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
						display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
					end})
			end
		end ,
	} )
	layer:addChild(icon:getLayer())
	
	for i = 1, #getTitle() do
		if tonumber(data["rank"]) > getTitle()[i][1] then
			str = getTitle()[i][2]
			break
		end
	end
	text = display.strokeLabel("【"..str.."】"..data["name"], 90, 70 + offset, 20)
	layer:addChild(text)
	
	text = display.strokeLabel("排名：", 90, 30 + offset, 20)
	layer:addChild(text)
	
	text = display.strokeLabel(data["rank"], 150, 25 + offset, 36)
	layer:addChild(text)
	
	local callback
	if state == SELF then
		str = "addTimes.png"
		text = display.strokeLabel("剩余次数："..self.data["data"]["left_times"],300,10,18)
		layer:addChild(text)
		callback = function()
			HTTP:call("athletics","add_times",{},{success_callback = 
				function(data)
					self.data["data"]["left_times"] = data["left_times"]
					switchScene("athletics", {data = self.data["data"], offset = parent:getOffset()})
				end})
		end
		
		local gold = display.newSprite(COMMONPATH.."gold.png")
		setAnchPos(gold, 275, 42)
		layer:addChild(gold)
		
		text = display.strokeLabel(self.data["data"]["add_times_gold"], 310, 45, 18, ccc3(0x2c, 0, 0))
		layer:addChild(text)
	else
		if state == TOPTEN then
			str = "rank_list.png"
			callback = function()
				switchScene("ranklist","athletics")
			end
		elseif state == ENEMY then
			str = "revenge.png"
			text = display.strokeLabel("他曾经击败过您！", 250, 10, 18, ccc3(0xec,0,0))
			layer:addChild(text)
			callback = function()
				SOCKET:getInstance("battle"):call("athletics" , "execute" , "execute",{atkback = 1, userid = data["uid"]})
			end
		elseif state == FIGHT then
			str = "fighting.png"
			callback = function()
				SOCKET:getInstance("battle"):call("athletics" , "execute" , "execute",{pos = data["pos"], userid = data["uid"]})
			end
		else
			str = nil
		end
		text = display.strokeLabel("Lv "..data["lv"], 20, 10, 20)
		layer:addChild(text)
	end
	
	if str then
		local btn = KNBtn:new(COMMONPATH, {"btn_bg.png","btn_bg_pre.png"}, 330, 45 + offset / 2, {
			scale = true,
			parent = parent,
			front = PATH..str,
			callback = callback
		})
		layer:addChild(btn:getLayer())
	end
	
	return layer
end

function AthleticsLayer:createInfo(data)
	local layer = display.newLayer()
	
	local infoBg = display.newSprite(PATH.."info_bg.png")
	setAnchPos(infoBg,0,0,0.5)
	layer:addChild(infoBg)
	
	layer:setContentSize(infoBg:getContentSize())
	setAnchPos(layer,240,640,0.5)
	
--	
--	local gold = display.newSprite(COMMONPATH.."gold.png")
--	setAnchPos(gold,40, 35)
--	layer:addChild(gold)
	
--	gold = display.strokeLabel(self.data["data"]["refresh_gold"], 80, 38, 18, ccc3(0xff, 0xfb, 0xd4))
--	layer:addChild(gold)
--	
----	
--	local achieve = KNBtn:new(COMMONPATH,{"btn_bg.png", "btn_bg_pre.png"},120,30, {
--		front=PATH.."refresh.png",
--		callback = function()
--			HTTP:call("athletics", "refresh", {},{success_callback = 
--				function(data)
--					self.data["data"] = data["get"]
--					switchScene("athletics", {data = self.data["data"]})
--				end})
--		end})
--	layer:addChild(achieve:getLayer())
--	
	

	local curRank = display.newSprite(PATH.."daily.png")
	setAnchPos(curRank,-180, 50)
	layer:addChild(curRank)
	
	curRank = display.newSprite(PATH.."score_text.png")
	setAnchPos(curRank, -180, 18)
	layer:addChild(curRank)
	
	curRank = display.strokeLabel(self.data["data"]["outcome"]["win"],-150,18,20,ccc3(0xff,0xfb,0xd4))
	layer:addChild(curRank)
	
	curRank = display.strokeLabel(self.data["data"]["outcome"]["lose"],-90,18,20,ccc3(0xff,0xfb,0xd4))
	layer:addChild(curRank)
	
	curRank = display.strokeLabel(self.data["data"]["successionwin"],-10,18,20,ccc3(0xff,0xfb,0xd4))
	layer:addChild(curRank)
--	
--	local gift = KNBtn:new(SCENECOMMON,{"btn_bg.png", "btn_bg_pre.png"}, 40, 10, {
--			front = IMG_PATH.."image/prop/s_16009.png"
--		})
--	layer:addChild(gift:getLayer())
--	
	return layer	
end
				
return AthleticsLayer