local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local PATH = IMG_PATH.."image/scene/userinfo/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local UserInfoLayer = {
	baseLayer,
	layer,
	timeLayer,
	timeSchedule,
	timeItems
}

function UserInfoLayer:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	
	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度

	local infoBg = display.newSprite(PATH.."info_bg.png")	
	setAnchPos(infoBg,245,670,0.5,0.5)
	this.layer:addChild(infoBg)
	
	--玩家头像
	local bg_big = display.newSprite(COMMONPATH .. "bg_big.png")
	setAnchPos(bg_big , 18 , 108)
	
	infoBg = display.newSprite(COMMONPATH .."sex" .. DATA_User:get("sex") .. ".jpg")
	setAnchPos(infoBg,60,635)
	this.layer:addChild(infoBg)
	
	infoBg = display.newSprite(COMMONPATH.."role_frame.png")
	setAnchPos(infoBg,57,630)
	this.layer:addChild(infoBg)
	--名称显示
	local text = display.newSprite(PATH.."name.png")
	setAnchPos(text,130,680)
	this.layer:addChild(text)
	local curVipLv = DATA_Vip:get("viplv")
	
	if DATA_Vip:isVip() then
		this.layer:addChild( display.newSprite( IMG_PATH .. "image/scene/vip/v" .. curVipLv.. ".png" , 210 , 680  , 0 , 0 ) )
	end
	
	text = display.strokeLabel( DATA_User:get("name") , ( DATA_Vip:isVip() and 250 or 210 ) , 678 , 24 , ccc3(0x4a,0x08,0x08) )
	this.layer:addChild(text)
	
	--称号显示
	text = display.newSprite(PATH.."title.png")
	setAnchPos(text,130,635)
	this.layer:addChild(text)
	
	local str ="v0.png"
	for i = 1, #getTitle() do
		if tonumber(params.rank) > 10 then
		elseif tonumber(params.rank) > getTitle()[i][1] then
			str = "v"..(i - 1)..".png"
			break
		end
	end
	text = display.newSprite(PATH..str)
	setAnchPos(text, 210, 635)
	this.layer:addChild(text)
	this.layer:addChild( display.newSprite(PATH.."detail_bg.png" , display.cx , 300 , 0.5 , 0 ) )
	
	local showElement = {
			{ text = "id" 		, value = DATA_User:get("uid") 	} ,										--玩家id
			{ text = "level" 	, value = DATA_User:get("lv")	} ,										--玩家等级
			{ text = "exp"		, value = DATA_User:get("cur_exp").."/"..DATA_User:get("lvup_exp")	} ,	--玩家经验
			{ text = "value"	, value = params.ability	} ,											--玩家战力
			{ text = "on"		, value = DATA_Formation:get_lenght().."/8"	} ,							--上阵武将
			{ text = "commander", value = DATA_User:getLead()	} ,										--统帅
			{ text = "gang"		, value = params.gang	} ,												--帮会
			{ text = ""			, value = 0	} ,															--空
			{ text = "vip_text"	, value = DATA_Vip:get("viplv")	} ,										--vip等级
			{ text = ""			, value = 0	} ,															--空
			{ text = "gold"		, value = DATA_Account:get("gold")	} ,									--黄金
			{ text = "silver"	, value = DATA_Account:get("silver")	} ,								--银两
	}
	local addX , addY
	for i = 1 , #showElement do
		local curData = showElement[i]
		if curData.text ~= "" then
			addX = 60 + ( i - 1 ) % 2 * 212
			addY = 560 - math.floor( ( i - 1 ) / 2 ) * 50
			local pathStr = PATH .. curData.text .. ".png"
			if curData.text == "gold" or curData.text == "silver" then
				pathStr = COMMONPATH .. curData.text .. ".png"
			end
			
			this.layer:addChild( display.newSprite( pathStr , addX , addY , 0 , 0  ) )
			addX = addX + 93
			if curData.text == "on" then
				addX = addX + 18
			elseif curData.text == "vip_text" then
				addX = addX + 10
			elseif curData.text == "gold" or curData.text == "silver" then
				addX = addX - 50
			end
			this.layer:addChild( display.strokeLabel(curData.value , addX  , addY , 24 , ccc3( 0xff , 0xfb , 0xd4 ) ) )
		end
	end
	
	
	local lookVipBtn = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 311 , 354, {
			front = PATH.."look_privilege.png",
			callback = function()
				HTTP:call("vip", "get", {},{success_callback = 
				function()
					switchScene("vip")
				end})
			end}):getLayer()
	this.layer:addChild(lookVipBtn)
	
	--体力信息，当前值下次恢复值，总时间 
	this.layer:addChild( display.newSprite(PATH.."data_bg.png" , display.cx , 134 , 0.5 , 0 )	 )			--体力背景
	this.layer:addChild( display.newSprite( PATH .. "power.png"  		, display.cx , 260 , 0.5 , 0 ) )	--体力文字title
	this.layer:addChild( display.newSprite( PATH .. "power_value.png" 	, 60 , 220 , 0 , 0 ) )				--当前体力值
	this.layer:addChild( display.newSprite( PATH .. "next_power.png" 	, 60 , 180 , 0 , 0 ) )				--下个恢复时间
	this.layer:addChild( display.newSprite( PATH .. "all_power.png" 	, 60 , 140 , 0 , 0 ) )				--所有恢复时间
	this.layer:addChild( display.strokeLabel( DATA_Power:get("num").."/"..DATA_Power:get("max"),140,220,22,ccc3(0x4a,0x08,0x08) ) )	--当前体力值/最大体力值
	
	
--	--斗志信息，当前值下次恢复值，总时间 
--	dataBg = display.newSprite(PATH.."data_bg.png")	
--	setAnchPos(dataBg,245,180,0.5,0.5)
--	this.layer:addChild(dataBg)
--
--	text = display.newSprite(PATH.."energy.png")
--	setAnchPos(text,245,225,0.5)
--	this.layer:addChild(text)
--	
--	text = display.newSprite(PATH.."energy_value.png")
--	setAnchPos(text,60,205)
--	this.layer:addChild(text)
--	
--	text = display.strokeLabel(DATA_Energy:get("num").."/"..DATA_Energy:get("max"),140,205,22,ccc3(0x4a,0x08,0x08))
--	this.layer:addChild(text)
--	
--	text = display.newSprite(PATH.."next_energy.png")
--	setAnchPos(text,60,165)
--	this.layer:addChild(text)
--	
--	text = display.newSprite(PATH.."all_energy.png")
--	setAnchPos(text,60,125)
--	this.layer:addChild(text)
	
	--体力与斗志的更新时间
	this.timeItems = {
		DATA_Power:get("next_recover_time"),
		DATA_Power:get("all_recover_time"),
--		DATA_Energy:get("next_recover_time"),
--		DATA_Energy:get("all_recover_time"),
	}
	
	--生成倒计时信息
	this:createTimeLayer()
	
	
	
	this.baseLayer:addChild(bg)
	this.baseLayer:addChild(bg_big)
	this.baseLayer:addChild(this.layer)
	
	--导航信息
	local info = InfoLayer:new("userinfo" , 0 , {tail_hide = true , title_text = PATH .. "user_title.png"})
	this.baseLayer:addChild(info:getLayer() , 2)
	return this
end


function UserInfoLayer:getLayer()
	return self.baseLayer
end

function UserInfoLayer:createTimeLayer()
	if self.timeLayer then
		self.layer:removeChild(self.timeLayer,true)
	end
	
	
	
	self.timeLayer = display.newLayer()
	
	local time = display.strokeLabel( timeConvert(self.timeItems[1]) , 250 , 182 , 20 )
	self.timeLayer:addChild(time)
	
	time = display.strokeLabel(timeConvert(self.timeItems[2]) , 250 , 142 , 20 )
	self.timeLayer:addChild(time)
--	
--	time = display.strokeLabel(timeConvert(self.timeItems[3]),250,165,20)
--	self.timeLayer:addChild(time)
--	
--	time = display.strokeLabel(timeConvert(self.timeItems[3]),250,125,20)
--	self.timeLayer:addChild(time)
	
	
	if not self.timeSchedule then
		self.timeSchedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
			function()
				local refresh = false
				for i = 1, #self.timeItems do
					if self.timeItems[i] > 0 then
						self.timeItems[i] = self.timeItems[i] - 1
						if self.timeItems[i] == 0 then  --计时到0时请求一次数据
							refresh = true
						end
					end
				end
				if refresh then
					HTTP:call("status","get",{},{success_callback=
						function()
							switchScene("userinfo")
						end
					})
				else
					self:createTimeLayer()
				end
			end,1,false)
	end
	self.layer:addChild(self.timeLayer)	
end

function UserInfoLayer:stopSchedule()
	if self.timeSchedule then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeSchedule)
	end
end

				
return UserInfoLayer