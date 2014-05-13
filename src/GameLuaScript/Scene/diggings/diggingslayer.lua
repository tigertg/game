local TOPTEN, ENEMY, FIGHT,SELF, BACK = 1, 2, 3, 4, 5
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local PATH = IMG_PATH.."image/scene/diggings/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local silverCfg = requires(IMG_PATH, "GameLuaScript/Config/wakuangsilver")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")

local DiggingsLayer = {
	baseLayer,
	layer,
	data,
	detail,
	timeLabel,
	valueLabel
}

function DiggingsLayer:new(data)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.baseLayer = display.newLayer()
	this.data = data
	this.detail = {}
	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.baseLayer:addChild(bg)
	
	local tipBg = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(tipBg,0,424,0,0.5)
	this.baseLayer:addChild(tipBg)
	
	this:createContent()
	return this
end

function DiggingsLayer:createContent(data)
	if self.layer then
		self.baseLayer:removeChild(self.layer, true)
	end
	
	if data then
		self.data = data
	end
	
	self.layer = display.newLayer()
	
	local bg = display.newSprite(PATH.."bg.jpg")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	self.layer:addChild(bg)
	
	local showImg
	if self.data.obtain_type == 0 then
		showImg = {"no_diggings.png"}
	else
		showImg = {self.data.obtain_type.."_big.png"}
	end
	
	local diggingsBtn = KNBtn:new(PATH, showImg, 120, 400, {
		scale = true,
		callback = function()
			local kind = tonumber(self.data.obtain_type) > 0 and tonumber(self.data.obtain_type) or 1
--			if self.detail[kind] then
--				self:createDiggings(kind)
--			else		
			if self.data.history_money > 0 then
				KNMsg.getInstance():flashShow("请先领取您的奖励再抢夺新的矿山吧！~")
			else
				HTTP:call("mining", "get_list", {type = tonumber(self.data.obtain_type) > 0 and tonumber(self.data.obtain_type) or 1}, {
					success_callback = function(data)
						self.detail[kind] = data
						self:createDiggings(kind)
					end
				})
			end
		end
	})
	self.layer:addChild(diggingsBtn:getLayer())
	
	if tonumber(self.data.obtain_type) == 0 then
		self.layer:addChild(createLabel({str = "可前往野矿区夺矿", size = 40, color = ccc3(255,255,255), x = 100, y = 470, width = 400}))
	end
	
	local my = display.newSprite(PATH.."my_diggings.png")
	setAnchPos(my, 240, 690, 0.5)
	self.layer:addChild(my)
	
	local dayTip = display.newSprite(PATH.."day_tip.png") 
	setAnchPos(dayTip, 240, 300, 0.5)
	self.layer:addChild(dayTip)
	
	if tonumber(self.data.obtain_type) > 0 then
		local produce = display.newSprite(PATH.."produce_text.png")
		setAnchPos(produce, 180, 350)
		self.layer:addChild(produce)
		
		self.layer:addChild(createLabel({str = silverCfg[tonumber(self.data.obtain_type)][self.data.last_lv]["num"].."银/分", size = 18, color = ccc3(255, 255, 255), x = 230, y = 350, width = 400}))	
	end
	
	self.layer:addChild(createLabel({str = "每天可累计挖矿6个小时，当天满6小时即可领取奖励", size = 18, width = 480, color = ccc3(0x6a, 0xf8, 0xf0), x = 35, y = 120 }))
	
	local achieveText = display.newSprite(PATH.."achieve_count.png") 
	setAnchPos(achieveText, 80, 200)
	self.layer:addChild(achieveText)
	
	local askPro = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 20, 680, {
		front = self.data.guard_rest > 0 and PATH.."protecting.png" or PATH.."ask_protect.png",
		callback = function()
			HTTP:call("mining", "get", {}, {
				success_callback = function(data)
					self.data = data
					self:askProtect()
				end
			})
		end
	})
	self.layer:addChild(askPro:getLayer())
	
	local toRob = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 350, 680, {
		front = PATH.."to_rob.png",
		callback = function()
			diggingsBtn:call()	
		end
	})
	self.layer:addChild(toRob:getLayer())
	
	local btnBg, free, adv, legal
	if (self.data.sec_count >= self.data.sec_max or self.data.history_money > 0) and self.data.is_finish == 0 then
		legal =  true
		btnBg = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		free = PATH.."free_get.png"
		adv = PATH.."adv_get.png"
	else
		legal = false
		btnBg = {"btn_bg_red2.png"}
		free = PATH.."free_get_grey.png"
		adv = PATH.."adv_get_grey.png"
	end
	
	local freeGet = KNBtn:new(COMMONPATH, btnBg, 170, 140, {
		front = free,
		callback = function()
			if legal then
				HTTP:call("mining", "receive", {method = 1}, {
					success_callback = function(data)
						self:getResult(data)
					end
				})
			else
				if self.data.is_finish == 1 then
					KNMsg.getInstance():flashShow("您今天已领过奖励了，明天再来试试吧")	
				else
					KNMsg.getInstance():flashShow("累计挖矿六小时才可领取奖励，骚年，继续努力吧")	
				end	
			end
		end
	})
	self.layer:addChild(freeGet:getLayer())
	
--	local advGet = KNBtn:new(COMMONPATH, btnBg, 250, 140, {
--		front = adv,
--		callback = function()
--			if legal then
--				HTTP:call("mining", "receive", {method = 2}, {
--					success_callback = function(data)
--						self:getResult(data)
--					end
--				})
--			else
--				KNMsg.getInstance():flashShow("累计挖矿六小时才可领取奖励，骚年，继续努力吧")	
--			end
--		end
--	})
--	self.layer:addChild(advGet:getLayer())
--	
--	local goldImg = display.newSprite(COMMONPATH.."gold.png")
--	setAnchPos(goldImg, 390, 155)
--	self.layer:addChild(goldImg)
--	
--	self.layer:addChild(createLabel({str = "99", x = 420, y = 158, color = ccc3(255,255,255), size = 18}))
--	
	local silverImg = display.newSprite(COMMONPATH.."silver.png")
	setAnchPos(silverImg, 265, 200)
	self.layer:addChild(silverImg)
	

	--时间计时
	self.timeLabel = createLabel({str = self.data.is_finish == 1 and "您今天挖矿时间已满" or timeConvert(self.data.sec_count), x = 280, y = 248, color = ccc3(255, 255, 255), width = 400, size = 18})
		self.layer:addChild(self.timeLabel)
	
	--银币显示
	self.valueLabel = createLabel({str = self.data.today_money == 0 and self.data.history_money or self.data.today_money, x = 300, y = 203, color = ccc3(255,255,255), size = 18})
	self.layer:addChild(self.valueLabel)
	
	if tonumber(self.data.obtain_type) > 0 and self.data.sec_count < self.data.sec_max and self.data.is_finish == 0 then
		--添加时间与银币的计时器
		local time = self.data.sec_count % 60 
		Clock:addTimeFun("digings_time", function()
			self.data.sec_count = self.data.sec_count + 1
			
			if self.data.sec_count >= self.data.sec_max then
				Clock:removeTimeFun("digings_time")
				Clock:removeTimeFun("digings_silver")
				HTTP:call("mining", "get", {}, {
					success_callback = function(data)
						switchScene("diggings", data)
					end
				})
			else
				time = time + 1
				self.timeLabel:setString(timeConvert(self.data.sec_count))
			end
		end)
		
		Clock:addTimeFun("digings_silver", function()
			if self.data.sec_count % 60 == 0 then
				self.valueLabel:setString(math.floor(self.data.today_money + time / 60 * silverCfg[tonumber(self.data.obtain_type)][self.data.last_lv]["num"]))
				local text = getImageNum(silverCfg[tonumber(self.data.obtain_type)][self.data.last_lv]["num"], COMMONPATH.."cirt.png")
				setAnchPos(text, 240, 400, 0.5)
				text:setScale(0)
				self.layer:addChild(text)
				text:runAction(getSequenceAction(CCEaseElasticOut:create(CCScaleTo:create(0.5, 1)),CCMoveTo:create(1.5, ccp(240, 600)), CCCallFunc:create(function()
					self.layer:removeChild(text, true)
				end)))
			end
		end)
	end
	
--	self.layer:addChild(createLabel({str = "说明：黄金领取可以获得额外的10%的银两收益", color = ccc3(0x6a, 0xf8, 0xf0), width = 400,size = 16, x = 80, y = 115}))
	self.baseLayer:addChild(self.layer)
	
	local info = InfoLayer:new("athletics", 0, {title_text = PATH.."tip_text.png", tail_hide = true, closeCallback = function()
		switchScene("pvp")
	end })
	self.layer:addChild(info:getLayer(),2)
end

--创建野矿区信息
function DiggingsLayer:createDiggings(index)
	if self.layer then
		self.baseLayer:removeChild(self.layer, true)
	end
	self.layer = display.newLayer()
	
	
	local title = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(title, 240, 690, 0.5)
	self.layer:addChild(title)
	
	local pos = {
		{10, 500},
		{290, 500},
		{150, 350},
		{10, 200},
		{290, 200},
	}
	
	local layer
	local function diggingsInfo(kind)
		if layer then
			self.layer:removeChild(layer, true)
		end
		layer = display.newLayer()
		
		for k, v in pairs(pos) do
				local item = KNBtn:new(PATH, {kind.."_small.png"}, v[1], v[2], {
					text = {{"Lv "..self.detail[kind]["list"][k]["lv"], 20, ccc3(255,255,255), ccp(0, -55)}, {"占领:"..self.detail[kind]["list"][k]["name"], 20, ccc3(255, 255, 255), ccp(0, -80)}},
					scale = true,
					callback = function()
						self:detailInfo(kind, k)
					end
				})
				layer:addChild(item:getLayer())
				
				if self.detail[kind]["list"][k]["guard_uid"] ~= 0 then
					local icon = display.newSprite(PATH.."player_pro.png")
					setAnchPos(icon, v[1] + 155, v[2] + 100)
					layer:addChild(icon)
				end
				
				if self.detail[kind]["list"][k]["sys_guard"] > 0 then
					local icon = display.newSprite(PATH.."sys_pro.png")
					setAnchPos(icon, v[1] + 130, v[2] + 100)
					layer:addChild(icon)
				end
		end
		
		
		
		local produce = display.newSprite(PATH.."produce_text.png")
		setAnchPos(produce, 20, 650)
		layer:addChild(produce)
		
		layer:addChild(createLabel({str = silverCfg[kind][self.data.last_lv == 0 and DATA_User:get("lv") or self.data.last_lv]["num"].."银/分", size = 18, color = ccc3(255, 255, 255), x = 75, y = 650, width = 400}))	
		self.layer:addChild(layer)
	end
	
	--1，2，3分别表示金矿银矿和铜矿
	local group = KNRadioGroup:new()
	for i = 1, 3 do
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png","tab_star_select.png"},10 + (i - 1) * 90 , 695, {
			id = i,
			front =  {PATH..i.."_normal.png", PATH..i.."_select.png"},
			callback = function()
--				if self.detail[i] then
--					diggingsInfo(i)
--				else
					HTTP:call("mining", "get_list", {type = i}, {
					success_callback = function(data)
						self.detail[i] = data
						diggingsInfo(i)
					end
					})
--				end
			end
		}, group)
		self.layer:addChild(btn:getLayer(), -1)
	end
	group:chooseByIndex(index or 1, true)
	
	local mask
	local record = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 340, 700, {
		front = PATH.."record.png",
		callback = function()
		  local recordLayer = display.newLayer()
		   recordLayer:ignoreAnchorPointForPosition(false)
		   setAnchPos(recordLayer, 240, 427, 0.5, 0.5)
		   recordLayer:setScale(0)
		   
		   local bg =  display.newSprite(SCENECOMMON.."rob_msg_bg.png")
		   setAnchPos(bg, 240, 325, 0.5)
		   recordLayer:addChild(bg)
		   
		   local robRecord = KNScrollView:new(40, 330, 200, 310, 20)
		   recordLayer:addChild(robRecord:getLayer())
		   for i = 1, #self.data["message"]["rob_message"] do  
			   local msg = createLabel({str = self.data["message"]["rob_message"][#self.data["message"]["rob_message"] + 1 - i], color = ccc3(0x34, 0x7bf, 0xbe), width = 200})
			   setAnchPos(msg)
			   robRecord:addChild(msg)
		   end
		   robRecord:alignCenter()
		   
		   local robbedRecord =KNScrollView:new(245,330, 200, 310, 20)
		   recordLayer:addChild(robbedRecord:getLayer())
		   for i = 1, #self.data["message"]["robbed_message"] do  
   			   local msg = createLabel({str =self.data["message"]["robbed_message"][#self.data["message"]["robbed_message"] + 1 - i], color = ccc3(0xe7, 0x2a, 0x2a), width = 200})
   			   setAnchPos(msg)
			   robbedRecord:addChild(msg)
		   end
		   robbedRecord:alignCenter()
		   
		   recordLayer:runAction(getSequenceAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1)),CCCallFunc:create(function()
		   
		   end)))
		   
		   
		   mask = KNMask:new({item = recordLayer, click = function(x, y)
			   if CCRectMake(240 - bg:getContentSize().width / 2, 325, bg:getContentSize().width, bg:getContentSize().height):containsPoint(ccp(x, y)) then
			   else
				   recordLayer:runAction(getSequenceAction(CCScaleTo:create(0.3,0),CCCallFunc:create(function()
					-- this.baseLayer:removeChild(mask, true)
					mask:remove()
				   end)))
			   end
		   end})
		   self.layer:addChild(mask:getLayer())
		end
	})
	self.layer:addChild(record:getLayer())
	local change = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 140, {
		front = PATH.."change.png",
		callback = function()
			HTTP:call("mining", "get_list", {type = group:getId()}, {
					success_callback = function(data)
						self.detail[group:getId()] = data
						diggingsInfo(group:getId())
					end
					})
		end
	})
	self.layer:addChild(change:getLayer())
	
	self.layer:addChild(createLabel({str = "说明：每天00：00重置矿山占有者", x = 100, y = 110, size = 18, color = ccc3(0x6a, 0xf8, 0xf0), width = 400}))
	

	
	self.baseLayer:addChild(self.layer)
		
	local info = InfoLayer:new("athletics", 0, {title_text = PATH.."tip_text.png", tail_hide = true, closeCallback = function()
		HTTP:call("mining", "get", {}, {
			success_callback = function(data)
				self:createContent(data)
			end
			})
	end })
	self.layer:addChild(info:getLayer(),2)
end

function DiggingsLayer:detailInfo(index, pos)
	local layer = display.newLayer()
	local mask
	index = index or 1
	
	local bg = display.newSprite(IMG_PATH.."image/scene/mission/wipe_bg.png")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(IMG_PATH.."image/scene/mission/title_bg.png")
	setAnchPos(bg, 250, 570, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH.."detail.png")
	setAnchPos(bg, 250, 570, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH..index.."_small.png")
	setAnchPos(bg, 240, 440, 0.5)
	layer:addChild(bg)
	
	if self.detail[index]["list"][pos].guard_uid  ~= 0 then
		local icon = display.newSprite(PATH.."player_pro.png")
		setAnchPos(icon, 310, 530)
		layer:addChild(icon)
	end
	
	bg = display.newSprite(PATH.."produce_text.png")
	setAnchPos(bg, 300, 560)
	layer:addChild(bg)
	
	layer:addChild(createLabel({str = silverCfg[index][self.data.last_lv == 0 and DATA_User:get("lv") or self.data.last_lv]["num"].."银/分 ", size = 18, color = ccc3(0x2c, 0, 0), x = 350, y = 560, width = 400}))
	
	
	--详情信息
	bg = display.newSprite(PATH.."cur_have.png")
	setAnchPos(bg, 130, 430)
	layer:addChild(bg)
	
	layer:addChild(createLabel({str = self.detail[index]["list"][pos].name.." Lv"..self.detail[index]["list"][pos].lv, size = 20, color = ccc3(0x2c, 0, 0), x = 230, y = 430, width = 400}))
	
	bg = display.newSprite(PATH.."cur_have_time.png")
	setAnchPos(bg, 130, 400)
	layer:addChild(bg)
	
	local haveTime = createLabel({str = timeConvert(self.detail[index]["list"][pos].sec_count), size = 20, color = ccc3(0x2c, 0, 0), x = 230, y = 400, width = 400})
	if self.detail[index]["list"][pos].uid ~= 0 then
		Clock:addTimeFun("haveTime", function()
			self.detail[index]["list"][pos].sec_count =	self.detail[index]["list"][pos].sec_count + 1 
			haveTime:setString(timeConvert(self.detail[index]["list"][pos].sec_count))
		end)
	end
	layer:addChild(haveTime)
	
	bg = display.newSprite(PATH.."cur_pro.png")
	setAnchPos(bg, 130, 370)
	layer:addChild(bg)
	
	local pro_name, time 
	if self.detail[index]["list"][pos].sys_guard > 0 then
		time = self.detail[index]["list"][pos].sys_guard
	end
	
	if self.detail[index]["list"][pos].guard_man ~= "" then
		pro_name = self.detail[index]["list"][pos].guard_man
		time = 0
	else
		pro_name = "无"	
		time = 0
	end
	layer:addChild(createLabel({str = pro_name, size = 20, color = ccc3(0x2c, 0, 0), x = 240, y = 370}))
	
	bg = display.newSprite(PATH.."cur_pro_time.png")
	setAnchPos(bg, 130, 340)
	layer:addChild(bg)
	
	local restTime = createLabel({str = timeConvert(time), size = 20, color = ccc3(0x2c, 0, 0), x = 260, y = 338, width = 400})
	if self.detail[index]["list"][pos].sys_guard > 0 then
		local icon = display.newSprite(PATH.."sys_pro.png")
		setAnchPos(icon, 280, 530)
		layer:addChild(icon)
		
		Clock:addTimeFun("restTime", function()
			self.detail[index]["list"][pos].sys_guard =self.detail[index]["list"][pos].sys_guard - 1 
			if self.detail[index]["list"][pos].sys_guard > 0 then
				restTime:setString(timeConvert(self.detail[index]["list"][pos].sys_guard))
			else
				Clock:removeFunc("restTime")
				Clock:removeFunc("haveTime")
				 HTTP:call("mining", "get_list", {index}, {
					success_callback = function(data)
						self.detail[index] = data
						mask:remove()
						self:detailInfo(index, pos)
					end
					})
			end
		end)
	end
	layer:addChild(restTime)
	
	layer:addChild(createLabel({str = "抢夺成功后，此矿山会替换你当前的矿山 ", color = ccc3(255,0,0), size = 18, x = 70, y = 255, width = 400}))
	
	
	local back = KNBtn:new(COMMONPATH, {"back_img.png", "back_img_press.png"}, 40, 540, {
		priority = -131,
		callback = function()
			mask:remove()
		end
	})
	layer:addChild(back:getLayer())
	
	local btnBg, front, canLook
	if self.detail[index]["list"][pos]["uid"] == 0 then
		btnBg = {"btn_bg_red2.png"}
		front = PATH.."look_grey.png"
	else
		btnBg = {"btn_bg_red.png", "btn_bg_red_pre.png"}	
		front = PATH.."look.png"
		canLook = true
	end
	
	local look = KNBtn:new(COMMONPATH, btnBg, 70, 280, {
		priority = -131,
		front = front,
		callback = function()
			if canLook then
				HTTP:call("profile","get",{ touid = self.detail[index]["list"][pos].guard_uid ~= 0 and self.detail[index]["list"][pos].guard_uid or self.detail[index]["list"][pos].uid },{success_callback = 
					function()
						local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
						display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
					end})
			end
		end
	})
	layer:addChild(look:getLayer())
	
	local fight = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 260, 280, {
		priority = -131,
		front = PATH.."fight.png",
		callback = function()
				SOCKET:getInstance("battle"):call("mining" , "execute" , "execute" , {type = index, target = self.detail[index]["list"][pos]["uid"]} )
		end
	})
	layer:addChild(fight:getLayer())
	
	mask = KNMask:new({item = layer})
	self.layer:addChild(mask:getLayer())	
end

function DiggingsLayer:askProtect()
	local layer = display.newLayer()
	local mask
	
	local bg = display.newSprite(IMG_PATH.."image/scene/mission/wipe_bg.png")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(IMG_PATH.."image/scene/mission/title_bg.png")
	setAnchPos(bg, 250, 570, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH.."protect_title.png")
	setAnchPos(bg, 250, 570, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH.."1_small.png")
	setAnchPos(bg, 240, 440, 0.5)
	layer:addChild(bg)
	
	--详情信息
	bg = display.newSprite(PATH.."my_protecter.png")
	setAnchPos(bg, 100, 410)
	layer:addChild(bg)
	
	layer:addChild(createLabel({str = self.data.guard_man == "" and "无" or self.data.guard_man, color = ccc3(0x2c,0,0), size = 20, x = 240, y = 412, width = 400}))
	
	bg = display.newSprite(PATH.."rest_time.png")
	setAnchPos(bg, 100, 370)
	layer:addChild(bg)
	
	local proTime = createLabel({str = timeConvert(self.data.guard_rest), color = ccc3(0x2c,0,0), size = 20, x = 240, y = 372, width = 400})
	if self.data.guard_rest > 0 then
		Clock:addTimeFun("pro_time", function()
			self.data.guard_rest = 	self.data.guard_rest - 1 
			if self.data.guard_rest > 0 then
				proTime:setString(timeConvert(self.data.guard_rest))
			else
				Clock:removeTimeFun("pro_time")
				HTTP:call("mining", "get", {}, {
					success_callback = function(data)
						switchScene("diggings", data, function()
							KNMsg.getInstance():flashShow("好友保护时间已结束，骚年靠你自己了")
						end)
					end
				})
			end
		end)
	end
	layer:addChild(proTime)
	
	layer:addChild(createLabel({str = "保护会抽取保护时间内挖掘银两的10%给保护者 ", color = ccc3(255,0,0), size = 18, x = 50, y = 280, width = 400}))
	layer:addChild(createLabel({str = "每天可邀请2次好友进行保护，每次保护2小时 ", color = ccc3(255,0,0), size = 18, x = 50, y = 255, width = 400}))
	
	
	local back = KNBtn:new(COMMONPATH, {"back_img.png", "back_img_press.png"}, 40, 540, {
		priority = -131,
		callback = function()
			mask:remove()
			self:createContent(self.data)
		end
	})
	layer:addChild(back:getLayer())
	
	
	local btnBg, front, legal
	if self.data.guard_rest > 0 then
		btnBg = {"btn_bg_red2.png"}		
		front = PATH.."choose_friend_grey.png"
		legal = false 
		
		local icon = display.newSprite(PATH.."player_pro.png")
		setAnchPos(icon, 300, 530)
		layer:addChild(icon)
	else
		btnBg = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		front = PATH.."choose_friend.png"
		legal = true
		
	end
	
	local choose = KNBtn:new(COMMONPATH, btnBg, 150, 310, {
		priority = -131,
		front = front,
		callback = function()
			if legal then
				HTTP:call("friends", "get", {}, {
					success_callback = function()
						if DATA_Friend:get("frd_count") == 0 then
							KNMsg.getInstance():flashShow("您还没有好友！~")
						else
							mask:remove()
							self:createList( { alonePageNum = 10 , data = DATA_Friend:get() , defaultPage = 1 } )
						end
					end
				})
			end
		end
	})
	layer:addChild(choose:getLayer())

	
	mask = KNMask:new({item = layer})
	self.baseLayer:addChild(mask:getLayer())	
end

function DiggingsLayer:getResult(result)
	local layer = display.newLayer()
	local mask
	
	local bg = display.newSprite(IMG_PATH.."image/scene/mission/des_bg.png")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH.."self_achieve.png")
	setAnchPos(bg, 100, 465)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH.."give_money.png")
	setAnchPos(bg, 100, 425)
	layer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."silver.png")
	setAnchPos(bg, 260, 465)
	layer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."silver.png")
	setAnchPos(bg, 260, 425)
	layer:addChild(bg)
	
	layer:addChild(createLabel({str = result.awards.silver, color = ccc3(0x2c, 0, 0), size = 18, x = 290, y = 467, width = 400}))
	layer:addChild(createLabel({str = result.guard_award, color = ccc3(0x2c, 0, 0), size = 18, x = 290, y = 427, width = 400}))
	
--	layer:addChild(createLabel({str = "说明：黄金领取能额外获得10%的银两收益 ", color = ccc3(255,0,0), size = 18, x = 70, y = 500, width = 400}))
	layer:addChild(createLabel({str = "抽取保护时间内挖掘银两的10%给保护者 ", color = ccc3(255,0,0), size = 18, x = 70, y = 400, width = 400}))
	
	local ok = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 160, 340, {
		priority = -131,
		front = COMMONPATH.."ok.png",
		callback = function()
			mask:remove()
			self:createContent(result.get)
		end
	})
	layer:addChild(ok:getLayer())
	
	mask = KNMask:new({item = layer})
	self.baseLayer:addChild(mask:getLayer())	

end

function DiggingsLayer:getLayer()
	return self.baseLayer
end


--生成list列表
function DiggingsLayer:createList( params )
	params = params or {}
	
	local mask
	local listLayer = display.newLayer()
	
	mask = KNMask:new({item = listLayer})
		-- 背景
	local bg = display.newSprite( COMMONPATH .. "dark_bg.png")
	setAnchPos( bg , 0 , 88 )						-- 70 是底部公用导航栏的高度
	listLayer:addChild( bg )
			
	local info = InfoLayer:new("diggings", 0, {priority = -129, title_text = IMG_PATH.."image/scene/friend/scene_title.png", tail_hide = true, closeCallback = function()
		mask:remove()
--		HTTP:call("mining", "get", {}, {
--			success_callback = function(data)
--				self:createContent(data)
--			end
--			})
	end })
	listLayer:addChild(info:getLayer())
	
	
	local data , totalPage , curPage , curType , group , pageText , curData , alonePageNum , listConfig , pageBg , rankText ,  addFriend
	local scroll = nil
	listConfig = params.listConfig							--选项按钮
	data = params.data or {}								--展示的数据
	curType = params.defaultType 							--默认激活table
	curPage = params.defaultPage or 1 						--默认展示页面
	alonePageNum = params.alonePageNum or 0					--单页item个数
	local isPaging = params.alonePageNum and true or false	--是否分页
	local heightType = 0
	
	
	
	local function refreshData()
		curData = data.frd or {} 
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
		listLayer:addChild( pageBg )
		--页数文字
		pageText = display.strokeLabel( curPage .. "/" .. 1  , 230 , 117 , 20 , ccc3(0xff,0xfb,0xd4) )
		setAnchPos( pageText , 240, 117, 0.5 )
		listLayer:addChild(pageText)
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
--		self.curTitle = display.newSprite( textPath , 260 , 704 , 0 , 0 ) 
--		self.listLayer:addChild( self.curTitle )	--当前好友/当前仇人
--		self.curNumText = display.strokeLabel( str , 350 , 705 , 20 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , {
--					dimensions_width = 83 ,
--					dimensions_height = 24,
--					align = 1
--				}) 
--		self.listLayer:addChild( self.curNumText )	--当前好友
		
		
		refreshData()
		
		local scrollX , scrollY , scrollWidth , scrollHeihgt
		scrollX			= 15
		scrollY			= isPaging and 155 or 105
		scrollWidth		= 450
		scrollHeihgt	= isPaging and 530 or 580
		
--		if heightType == 1 then
--			scrollY 		= 155
--			scrollHeihgt 	= 392
--		elseif heightType == 2 then
			scrollY 		= 155
			scrollHeihgt 	= 590
--		end
		
		scroll = KNScrollView:new( scrollX , scrollY , scrollWidth , scrollHeihgt , 5 )
		for i = 1 , ( isPaging and alonePageNum or #curData ) do
			local itemData = curData[ ( curPage - 1 ) * alonePageNum + i ]
			if itemData then
				local tempItem = self:listCell( { data = itemData , type = curType , parent = scroll , index = ( curPage - 1 ) * alonePageNum + i }, mask )
				scroll:addChild(tempItem, tempItem )
			end
		end
		scroll:alignCenter()
		listLayer:addChild( scroll:getLayer() )
	end
	
	--翻页按钮
	if isPaging then
		local pre = KNBtn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
			scale = true,
			flipX = true,
			priority = -131,
			callback = function()
				if curPage > 1 then
					curPage = curPage - 1
					createList( curType )
				end
			end
		})
		listLayer:addChild(pre:getLayer())
		local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
			scale = true,
			priority = -131,
			callback = function()
				if curPage < totalPage then
					curPage = curPage + 1
					createList( curType )
				end
			end
		})
		listLayer:addChild(next:getLayer())
	end
	
	local startX,startY = 10,690
	if heightType == 1 then startX,startY = 10 , 556 end
	createList()
	
	self.baseLayer:addChild(mask:getLayer(), 10)
end

--生成列表item
function DiggingsLayer:listCell( params, mask )
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
								front = COMMONPATH.."ok.png" ,
								priority = -131,
								parent = parent , 
								callback = function()
									HTTP:call("mining", "guard_request", {to_uid = data.uid}, {
										success_callback = function()
											mask:remove()
											KNMsg.getInstance():flashShow("您已成功发送申请，请耐心等待好友回复吧")
										end
									})
								end
								} ):getLayer())
		
		
	end
	
	createItem()
	
	layer:setContentSize( bg:getContentSize() )
	return layer
end

return DiggingsLayer