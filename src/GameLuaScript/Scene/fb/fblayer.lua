local MAIN, HERO, PET, SKILL, EQUIP = 0, 1, 2, 3, 4
local LEFT, RIGHT, TOP, BOTTOM = 1, 2, 3, 4
local PATH = IMG_PATH.."image/scene/fb/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local KNMask = requires(IMG_PATH, "GameLuaScript/Common/KNMask")
local Progress = requires(IMG_PATH, "GameLuaScript/Common/KNProgress")
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local Property = requires(IMG_PATH, "GameLuaScript/Config/Property")
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local Lot= requires(IMG_PATH, "GameLuaScript/Scene/fb/lot")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local HomeCard = requires(IMG_PATH,"GameLuaScript/Scene/fb/herocard")
--[[
	副本模块，在首页点击副本按钮进入此模块
]]
local FBLayer = {
	layer,
	mainLayer,
	contentLayer,
	state,
	wait,
	onePt,
	info,
	mask,
	needHeroList
	
}

function FBLayer:new(params)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	this.state = params.state 

	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 0, 425, 0, 0.5)
	this.layer:addChild(title)
	
	if params.state == "hero" then
--		HTTP:call("penglai", "get", {}, {
--			success_callback = function(data)
				this:createHeroFb(params.data) 
--			end
--		})
	elseif  params.state == "pet" then	
		this:createPetFb()
	elseif params.state == "skill" then
		this:createSkillFb()
	elseif params.state == "equip" then
		if params.dig then
			this:createDig(params.map)
		else
			this:createEquipFb(params.map)
		end
	elseif params.state == "rob" then
		this:createRobFb(params.robData, params.star)
	else	
		this:createMain(params.coming)
	end	

	return this
end

function FBLayer:createMain(name)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
		
--	local title = display.newSprite(PATH.."title.png")
--	setAnchPos(title, 245, 730, 0.5)
--	self.mainLayer:addChild(title)
--	
	local bg = display.newSprite(SCENECOMMON.."level_bg.png")
	setAnchPos(bg, 240, 590, 0.5)
	self.mainLayer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."desc_bg.png") 
	setAnchPos(bg, 30, 110)
	self.mainLayer:addChild(bg)
	
	local group = KNRadioGroup:new()
	
	local coming = KNBtn:new(COMMONPATH,{"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 120, {
		scale = true,
		front = COMMONPATH.."coming.png",
		callback = function()
			-- 判断等级开放
			local check_result = checkOpened("fb_"..group:getId())
			if check_result ~= true then
				KNMsg:getInstance():flashShow(check_result)
				return false
			end
			
			if group:getId() == "hero" then
				HTTP:call("penglai","get",{},{success_callback = function(data)
					self:createHeroFb(data)
--						self:createRoleFb("hero")
				end})
			elseif group:getId() == "pet" then
			
				HTTP:call("inspetnew","get",{},{success_callback = function()
					DATA_Instance:clearMessage()
					self:createPetFb()
				end})
			elseif group:getId() == "equip" then
				if DATA_Instance:get("equip", DATA_Instance:get("equip", "max", "map_id")) then
					self:createEquipFb(DATA_Instance:get("equip", "max", "map_id"))
				else
					HTTP:call("insequip", "get",{},{success_callback = function()
						self:createEquipFb(DATA_Instance:get("equip", "max", "map_id"))
					end})
				end
			elseif group:getId() == "skill" then
				if DATA_Instance:get("skill") then
					self:createSkillFb()
				else
					HTTP:call("insskill","get",{},{
						success_callback = function()
						self:createSkillFb()
					end})
				end	
			elseif group:getId() == "rob" then
				HTTP:call("rob", "get", {}, {
					success_callback = function(data)
						self:createRobFb(data)
					end
				})
			end
		end
	})
	self.mainLayer:addChild(coming:getLayer())
	
	local scroll = KNScrollView:new(35, 595, 410, 130, 2, true)
	local des_scroll 
	des_scroll =  KNScrollView:new(35, 90, 405, 490, 0, true, 1, {
		page_callback = function()
			group:chooseByIndex(des_scroll:getCurIndex())
			if checkOpened("fb_"..group:getId()) == true then
				coming:setFront(COMMONPATH.."coming.png")
				coming:setBg(1, {COMMONPATH.."btn_bg_red.png", COMMONPATH.."btn_bg_red_pre.png"})
			else
				coming:setFront(COMMONPATH.."coming_grey.png")
				coming:setBg(1, {COMMONPATH.."btn_bg_red2.png",COMMONPATH.."btn_bg_red2.png"})
			end
		end
	})
	
	local level = {
		"equip",
		"hero",
		"pet",
		"skill",
	}
	
	for i = 1, #level do
		local btn = KNBtn:new(PATH,{level[i].."_icon.png", "select.png"}, 0, 0, {
			id = level[i],
			scale = true,
			parent = scroll,
			noHide = true,
			upSelect = true,
			selectZOrder = 1,
--			other = {PATH..level[i].."_name.png", 17, 0},
			callback = function()
--				self:createContent(level[i])
				des_scroll:setIndex(i)	
				
				if checkOpened("fb_"..level[i]) == true then
					coming:setFront(COMMONPATH.."coming.png")
					coming:setBg(1, {COMMONPATH.."btn_bg_red.png", COMMONPATH.."btn_bg_red_pre.png"})
				else
					coming:setFront(COMMONPATH.."coming_grey.png")
					coming:setBg(1, {COMMONPATH.."btn_bg_red2.png",COMMONPATH.."btn_bg_red2.png"})
				end
				
			end
		},group)
		scroll:addChild(btn:getLayer(), btn)
		
		local desc = self:createContent(level[i])
		des_scroll:addChild(desc)
	end
	scroll:alignCenter()
	des_scroll:alignCenter()
	self.mainLayer:addChild(scroll:getLayer())
	self.mainLayer:addChild(des_scroll:getLayer())
		
	local num 
	for k, v in pairs(level) do
		if v == name then
			num = k
			break
		end
	end 
	
	group:chooseByIndex(num or 1)
	scroll:setIndex(num or 1 , true)
	des_scroll:setIndex(num or 1,true)
	self.state = MAIN

	-- 新手引导
	local guide_step = KNGuide:getStep()
	if guide_step == 801 or guide_step == 3001 or guide_step == 3101 or guide_step == 3201 or guide_step == 3301 then
		local btn = scroll:getItems(num or 1)
		local btn_range = btn:getRange()

		KNGuide:show( btn:getLayer() , {
			x = btn_range:getMinX(),
			y = btn_range:getMinY(),
			callback = function()
				KNGuide:show( coming:getLayer() )
			end
		})
	end
	

	self.layer:addChild(self.mainLayer)
	self:createInfo(PATH.."title.png",function()
			switchScene("home")
	end)
end

function FBLayer:createContent(kind)
--	if self.contentLayer then
--		self.mainLayer:removeChild(self.contentLayer, true)
--	end	
--	
--	self.contentLayer = display.newLayer()
	
	local layer = display.newLayer()
	
	
	local bg = display.newSprite(PATH..kind.."_desc.png")
	setAnchPos(bg, 8, 160)
	layer:addChild(bg)
	
	if kind ~= "rob" then
		layer:addChild( display.newSprite( PATH .. kind .. "_text_tip.png" , display.cx - 33 , 280 + 165 , 0.5 , 0 ))
	end
	
	local text = display.newSprite(PATH..kind.."_text.png")
	setAnchPos(text, 395, 390, 1)
	layer:addChild(text)
	
	local desc = {
		["hero"] =  "英雄殿汇聚唐门奇才，高星级英雄等你来拿, 每天逛逛英雄殿，就可以招募到心仪的英雄",
		["pet"]  =  "狩猎场内有各种珍稀猛兽！ 奇珍异兽！心动不如赶快行动！“主人 快来捕捉我吧”",
		["skill"] = "呼吸吐纳心自在，气沉丹田手心开！ 习武切记仁者无敌！谁练太极风生水起！ 想学好招式！就来如意阁！~",
		["equip"] = "俗话说人靠衣装马靠鞍。 这人在江湖飘，哪能不装备好。 挑战藏宝楼！爆牛B装备助你江湖逍遥！",
		["rob"] = "秋高气爽出门晃晃，英雄武器口袋装装。 每天抢一抢，轻松获得英雄将魂武器碎片！",
		
	 }

   	
	text = display.strokeLabel(desc[kind], 0, 60, 20,nil,nil,nil,{
		dimensions_width = 400,
		dimensions_height = 100,
	} )
	layer:addChild(text)
	

	layer:setContentSize(CCSizeMake(405, 450))
	return layer
end


function FBLayer:createSkillFb(index)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()

	-- 开始按钮，必须放这，因为新手引导要用 - -
	local clickStart
	
	local bg = display.newSprite(PATH.."bg.jpg")
	setAnchPos(bg)
	self.mainLayer:addChild(bg)
	
	self.state = SKILL
	
	--压注选择
	local valueGroup = KNRadioGroup:new()
	for i = 1, 3 do
		local btn = KNBtn:new(PATH, {"v"..i.."_btn.png", "btn_select.png"}, 320 - (i - 1) * 150, 610, {
			id = i,
			noHide = true,
			selectZOrder = 10,
			callback = function()
			end
		}, valueGroup)
		self.mainLayer:addChild(btn:getLayer())

		-- 新手引导
		if i == 2 and KNGuide:getStep() == 3203 then
			KNGuide:show( btn:getLayer() , {
				callback = function()
					KNGuide:show( clickStart:getLayer() , {
						remove = true
					})
				end
			})
		end
	end
	
	local pos = {
		{260,515,RIGHT},
		{380,515,BOTTOM},
		{380,405,BOTTOM},
		{380,295,BOTTOM},
		{380,190,LEFT},
		{260,190,LEFT},
		{140,190,LEFT},
		{20,190,TOP},
		{20,295,TOP},
		{20,405,TOP},
		{20,515,RIGHT},
		{120,505,RIGHT},
	}
	
	local group = KNRadioGroup:new()
	for i = 1, #pos do
		local link = display.newSprite(PATH.."link.png")
		local ox, oy = 0, 0
		
		if pos[i][3] == LEFT then
			ox = -80
			oy = 30
		elseif pos[i][3] == RIGHT then
			oy = 30
			ox = 40
		elseif pos[i][3] == BOTTOM then
			ox = 30
			link:setRotation(90)
		else
			ox = 30
			oy = 120	
			link:setRotation(90)
		end
		
		if i == 12 then
			ox = 60
			oy = 40
		end
		setAnchPos(link,pos[i][1] + ox,pos[i][2] + oy)
		self.mainLayer:addChild(link)
		
		local front,other,text
		local bg = "item_bg.png"
		local data = DATA_Instance:get("skill","list")
		if i == 1 then
			front = PATH.."start.png"
		else
			if data[i..""]["type"] == "silver" or data[i..""]["type"] == "prestige" then
				front = PATH..data[i..""]["type"]..".png"
			elseif data[i..""]["type"] == "thief" then
				front = IMG_PATH.."image/hero/s_general1334.png"
			else
				local pre
				if data[i..""]["type"] ~= "skill" then
					pre = "/s_"	
				else
					pre = "/"
				end
				front = IMG_PATH.."image/"..data[i..""]["type"]..pre..data[i..""]["effect"]..".png"
				
				if getCidType(data[i..""]["effect"]) == "petskill" then
					other = {IMG_PATH.."image/scene/bag/kind_bg.png", 10, 10}
					text = {"兽", 14, ccc3(255, 255, 255), ccp(-20, 22), nil, 17}
				end
			end
		end
		
		if i == 12 then
			bg = "final_item_bg.png"
		end
		local btn = KNBtn:new(PATH, {bg,"cur.png"},pos[i][1],pos[i][2],{
			front = front,
			other = other,
			text = text,
			selectZOrder = 20,
			upSelect = true,
			noHide = true,
			callback = function()
				if i > 1 then
					local k = DATA_Instance:get("skill", "list", i.."")
					if k["type"] == "thief" then
						KNMsg.getInstance():flashShow("小偷：将被偷取"..k["effect"].."银两")
					elseif k["type"] == "silver" then
						KNMsg.getInstance():flashShow("银两:将获得银两"..k["effect"])
					else
						local str = getCidType(k["effect"])
						if str == "petskill" then
							str = "幻兽技能"
						else
							str = "英雄技能"
						end
						str = getConfig(getCidType(k["effect"]), k["effect"],"star").."星"..str
						KNMsg.getInstance():flashShow(str.."【"..getConfig(getCidType(k["effect"]), k["effect"],"name").."】")
					end
					return false
				end
			end
		},group)
		self.mainLayer:addChild(btn:getLayer())
		
		if i > 1 then
			btn = getImageNum(i, COMMONPATH.."small_num.png")
			setAnchPos(btn, pos[i][1] + (i == 12 and 110 or 80) ,pos[i][2] + 10, 1)
			self.mainLayer:addChild(btn)
		end
	end
	
	group:chooseByIndex(index or 1)
	
		--这里是将骰子的点数拆成2数和
	local m, n = math.random(1,6), math.random(1,6)
	if index then
		local max 
		if index > 6 then
			max = 6
		else
			max = index - 1			
		end
		
		n = index - max
		n = math.random(n,max)
		m = index - n
	end
	
	if index and self.onePt then
		m = self.onePt
		n = index - self.onePt
	end
	
	local dice1 = display.newSprite(PATH..m..".png")
	setAnchPos(dice1, 190, 400)
	self.mainLayer:addChild(dice1,1)
	
	local dice2 = display.newSprite(PATH..n..".png")
	setAnchPos(dice2, 230, 360)
	self.mainLayer:addChild(dice2,1)									
										
	
	local stop,pt, add, count, award
	local function playAni(x, y,reverse)
		local frames = display.newFramesWithImage(PATH .. "ani.png" , 5 )
		local sprite 
		sprite = display.playFrames(x, y , frames, 0.1,
						{
							reverse = reverse,
							onComplete = function()
								if stop then
									self.mainLayer:removeChild(sprite,true)
									print(sprite,"停了")
									
									if not add then
										add = true
										
										--这里是将骰子的点数拆成2数和
										local max 
										if pt > 6 then
											max = 6
										else
											max = pt - 1			
										end
										
										self.onePt = pt - max  --其中一个骰子的点数
										self.onePt = math.random(self.onePt, max)
										
										dice1 = display.newSprite(PATH..self.onePt..".png")
										setAnchPos(dice1, 190, 400)
										self.mainLayer:addChild(dice1,1)
										
										dice2 = display.newSprite(PATH..(pt - self.onePt)..".png")
										setAnchPos(dice2, 230, 360)
										self.mainLayer:addChild(dice2,1)									
--										stop = false
									end
								else
									self.mainLayer:removeChild(sprite,true)
									self.mainLayer:addChild(playAni(x ,y,reverse))
								end
							end
						}
					)
--		sprite:runAction(CCJumpTo:create(2,ccp(x,y),50,3))
		return sprite
	end
	
	if DATA_Instance:get("skill", "times") > 0 then
		
		clickStart =  KNBtn:new(PATH,{"click_star.png", "click_star_press.png"}, 180, 345,{
			callback = function()
			
				audio.playSound(IMG_PATH .. "sound/abaca.mp3")
				local mask
				if not self.wait then
					if DATA_Instance:get("skill", "times") > 0 then
						if isBagFull() then
							return false
						end
						
						clickStart:showBtn(false)
						mask = KNMask:new({opacity = 0})
						self.mainLayer:addChild(mask:getLayer())
						self.wait = true
						self.mainLayer:removeChild(dice1, true)
						self.mainLayer:removeChild(dice2, true)
						
						self.mainLayer:addChild(playAni(230, 455))
						self.mainLayer:addChild(playAni(270, 410,true))
						
						local index = 1
						local schedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
								
							index = index + 1
							if index > 12 then
								index = 1
							end	
						
							group:chooseByIndex(index)
							
						end,0.1,false)
						stop = false
						add = false
						HTTP:call("insskill","roll",{yazhu = valueGroup:getId()},{
							no_loading = true,	
							error_callback = function()
								CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
								self.wait = false
								KNMsg.getInstance():flashShow("请求失败，请检查网络或重试")
								self:createSkillFb()
							end,
							success_callback = function(data)
								pt = data.point
								count = 0
								self.wait = false
								award = data["award"]
								CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
								schedule =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
									xpcall(function()
										if count == 2 and pt == index then
											mask:remove()
											-- self.mainLayer:removeChild(mask, true)
											local resultImg
											if pt < 9 then
												resultImg = display.newSprite(PATH.."v1_text.png")
											elseif pt < 12 then
												resultImg = display.newSprite(PATH.."v2_text.png")
											else
												resultImg = display.newSprite(PATH.."v3_text.png")
											end
											setAnchPos(resultImg, 240, 425, 0.5, 0.5)
											self.mainLayer:addChild(resultImg,100)
--											
											CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
											resultImg:setScale(0.1)	
											resultImg:runAction(getSequenceAction(CCEaseElasticOut:create(CCScaleTo:create(0.8,1.5)), CCCallFunc:create(function()
												if DATA_Instance:get("skill","list",index.."","is_battle") == 1 then
													SOCKET:getInstance("battle"):call("insskill" , "execute" , "execute",{})
												else
													self:createSkillFb(pt)
													for k, v in pairs(award) do
														if k == "thief" then
															KNMsg.getInstance():flashShow("运气不好，被小偷偷了钱包,损失银币:"..v)
														elseif k == "silver" then
															KNMsg.getInstance():flashShow("获得银两:"..v)
														elseif k == "drop" then
															KNMsg.getInstance():flashShow("获得技能书:【"..getConfig("skill", v[1].."", "name").."】")
														else
															KNMsg.getInstance():flashShow("获得"..k.."/"..v)
														end
													end
												end
											end)))
										else
											if pt == index then
												count = count + 1 
											end
											index = index + 1
											if index > 12 then
												index = 1
											end
												
											local stopN = pt - 3
											if stopN <= 0 then
												stopN = 12 + stopN
											end
											
											if count == 1 and index == stopN then
												stop = true
											end
											
											group:chooseByIndex(index)
										end
									end,function()
										--异常时停止定时器
										self.wait = false
										stop = false
										
										CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
									end)
								end,0.1,false)
							end})
					else
						KNMsg.getInstance():flashShow("摇点次数已不足，请点增加按钮购买摇点次数")
					end
				else
					print("等待中哦")
				end
			end
		})
		self.mainLayer:addChild(clickStart:getLayer(), 10)
	end
	
	
	
	
	local times = display.newSprite(PATH.."time_text.png")
	setAnchPos(times, 60, 140)
	self.mainLayer:addChild(times)
	
	times = display.strokeLabel(DATA_Instance:get("skill","times").."/"..DATA_Instance:get("skill","max_times"), 120, 145, 20, ccc3(255,255,255))
	setAnchPos(times, 135, 145, 0.5)
	self.mainLayer:addChild(times)
	
	
	local addTimes = KNBtn:new(COMMONPATH,{"add.png", "add_press.png"}, 160, 135, {
		callback = function()
			HTTP:call("insskill","buypoint",{},{
				success_callback = function()
					self:createSkillFb()
				end
			})
		end
	})
	self.mainLayer:addChild(addTimes:getLayer())
	
	local textBtn = KNBtn:new(PATH, {"luck_text.png"}, 160, 280, {
		callback = function()
			KNMsg.getInstance():flashShow("幸运值满30点时100%开出豹子，骰子大于六点+2点幸运值，其余则-1幸运值")
		end
	})
--	local text = display.newSprite(PATH.."luck_text.png")
--	setAnchPos(text, 160,280)
	self.mainLayer:addChild(textBtn:getLayer())
	
	local bar = Progress:new(PATH,{"luck_bg.png","luck_fro.png"}, 240, 280,{
		showText = true,
		cur = DATA_Instance:get("skill","luck"),
		max = DATA_Instance:get("skill","max_luck")
	})
	self.mainLayer:addChild(bar:getLayer())
	
	
	local refresh = KNBtn:new(COMMONPATH,{"btn_bg.png", "btn_bg_pre.png"}, 330, 140, {
		scale = true,
		front = COMMONPATH.."refresh.png",
		callback = function()
			HTTP:call("insskill","refresh",{},{
				success_callback = function()
					self:createSkillFb()
					
				end
			})
		end
	})
	self.mainLayer:addChild(refresh:getLayer())
	
	--刷新金币
	text = display.newSprite(COMMONPATH.."gold.png")
	setAnchPos(text, 340, 110)
	self.mainLayer:addChild(text)
	
	text = display.strokeLabel(DATA_Instance:get("skill", "refresh_price"), 375, 110, 20, ccc3(0xff,0xe5,0xa6))	
	self.mainLayer:addChild(text)
	
	--增加次数金币
	text = display.newSprite(COMMONPATH.."gold.png")
	setAnchPos(text, 90, 110)
	self.mainLayer:addChild(text)
	
		text = display.strokeLabel(DATA_Instance:get("skill", "point_price"), 125, 110, 20, ccc3(0xff,0xe5,0xa6))	
	self.mainLayer:addChild(text)
	
	
	self.layer:addChild(self.mainLayer)
	self:createInfo(PATH.."skill_title.png",function()
			self:createMain("skill")
		end)
end

function FBLayer:createEquipFb(map)
	map = tonumber(map)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()
	
	local bg = display.newSprite(PATH.."equip_bg.jpg")
	setAnchPos(bg, 0, 425, 0, 0.5)
	self.mainLayer:addChild(bg)
	
	self.state = EQUIP
	
	local proBg = display.newSprite(PATH.."pro_bg.png")
	setAnchPos(proBg,20,530)
	self.mainLayer:addChild(proBg)
	
	proBg = display.newSprite(PATH.."power_text.png")
	setAnchPos(proBg,32,600)
	self.mainLayer:addChild(proBg)
	
	
	proBg = CCLabelTTF:create(DATA_Power:get("num").."/"..DATA_Power:get("max"), FONT, 18)
	setAnchPos(proBg, 47, 580, 0.5, 0.5)
--	proBg:setRotation(90)
	self.mainLayer:addChild(proBg)
--	
--	proBg = display.newSprite(PATH.."pro_bg.png")
--	setAnchPos(proBg,20,330)
--	self.mainLayer:addChild(proBg)
--	
--	proBg = display.newSprite(PATH.."shu_text.png")
--	setAnchPos(proBg,32,400)
--	self.mainLayer:addChild(proBg)
--	
--	proBg = CCLabelTTF:create(DATA_Instance:get("equip", "point").."/"..DATA_Instance:get("equip", "point_max"), FONT, 18)
--	setAnchPos(proBg, 47, 380, 0.5, 0.5)
----	proBg:setRotation(90)
--	self.mainLayer:addChild(proBg)
	
	local addPowerBtn = KNBtn:new(COMMONPATH, {"add.png", "add_press.png"}, 25,510, {
		callback = function()
			local list
			list = SelectList:new("prop",self.viewLayer,display.newSprite(COMMONPATH.."title/prop_text.png"),{ 
				btn_opt = "use.png",
				y = 85,
				showTitle = true , 
				filter = {type = "powerdrug"},
				optCallback = function()
					list:destroy()
					HTTP:call("status", "eat", {id = list:getCurItem():getId()},{success_callback=
						function()
							self:createEquipFb(map)
							KNMsg.getInstance():flashShow("使用成功，体力增加")
						end})
				end
			})
			self.layer:addChild(list:getLayer() , 11)
		end
	})
	self.mainLayer:addChild(addPowerBtn:getLayer())	
--	
--	--这里是挑战书
--	local addTimesBtn = KNBtn:new(COMMONPATH, {"add.png", "add_press.png"}, 25,310, {
--		callback = function()
--			local list
--			list = SelectList:new("prop",self.viewLayer,display.newSprite(COMMONPATH.."title/prop_text.png"),{ 
--				btn_opt = "use.png",
--				y = 85,
--				showTitle = true , 
--				filter = {type = "challengebook"},
--				optCallback = function()
--					list:destroy()
--					HTTP:call("insequip","useshu", {id = list:getCurItem():getId()}, {
--						success_callback = function()
--							self:createEquipFb(map)
--							KNMsg.getInstance():flashShow("挑战书已使用，挑战次数增加")
--						end
--					})
--				end
--			})
--			self.layer:addChild(list:getLayer() , 11)
--		end
--	})
--	self.mainLayer:addChild(addTimesBtn:getLayer())	
	
	local tower_bg = display.newSprite(PATH.."tower_bg.png")
	setAnchPos(tower_bg, 4, 98)
	self.mainLayer:addChild(tower_bg)
	
	local group = KNRadioGroup:new()
	local y = 100
	for i = 1, 6 do
		local tower = KNBtn:new(PATH,{"tower"..i.."_bg.png","tower"..i..".png"},5,y, {
			noHide = true,
			upSelect = true,
			disableWhenChoose = true,
			callback = function()
				if i <= tonumber(DATA_Instance:get("equip", "max", "map_id")) then
					if DATA_Instance:get("equip", i) then
						self:createEquipFb(i)
					else
						HTTP:call("insequip", "get", {map_id = i}, {
							success_callback = function()
								self:createEquipFb(i)
							end
						})
					end
				else
					KNMsg.getInstance():flashShow("饭要一口一口吃，塔要一层一层爬，少年")
					return false 
				end
			end
		},group)
		self.mainLayer:addChild(tower:getLayer())
		y = y + tower:getHeight()
	end
--	group:chooseByIndex(DATA_Instance:get("equip","max","map_id"))
	group:chooseByIndex(tonumber(map))
	
	
	local scroll = KNScrollView:new(40, 100, 450, 650)
	

	local bossLayer = display.newLayer()
	--添加boss
	
	local bossOpen

	if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) or tonumber(DATA_Instance:get("equip", "max", "ins_id")) == 25 then
		bossOpen = true
	end
	local boss = KNBtn:new(PATH, {"boss"..map..".png", "boss"..map.."_pre.png"}, 150, 0, {
		callback = function()
			self:createTip(map, 25, function(finish)
				local curData = {map_id = map, ins_id = 25}
				DATA_Instance:setCurEquipData( curData )
				SOCKET:getInstance("battle"):call("insequip" , "execute" , "execute", curData )
				finish()
			end, bossOpen)
		end
	})
	
	--若boss已挑战成功
	if tonumber(DATA_Instance:get("equip", tonumber(map), 25,  "max_dig_times")) > 0  then
		local digBtn = KNBtn:new(COMMONPATH, {"btn_ver_small.png", "btn_ver_small_pre.png"}, 290, 20, {
			front = PATH.."dig_text.png",
			priority = -129,
			callback = function()
				self:createDig(map)
			end
		})
		bossLayer:addChild(digBtn:getLayer(), 1)
	end
	
	bossLayer:setContentSize(CCSizeMake(380, boss:getHeight()))
	bossLayer:addChild(boss:getLayer())
	
	scroll:addChild(bossLayer)
	
	local x, flag = 50, 1
	local str
	for i = 1, 24 do
		local layer = display.newLayer()
		
		if (24 - i - 3 ) % 4 == 0 then  --这个位置是宝箱
			if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) or (25 - i) < tonumber(DATA_Instance:get("equip", "max", "ins_id")) then
				str = {"box_open.png"}
			else
				if tonumber(DATA_Instance:get("equip", "max", "ins_id")) == tonumber(DATA_Instance:get("equip", "current","ins_id")) then
					str = {"box_open.png"}
				else
					str = {"box_disable.png"}
				end
			end
		else
			if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) or (25 - i) < tonumber(DATA_Instance:get("equip", "max", "ins_id")) then
				str = {"equip_enable.png", "equip_enable_pre.png"}
			else
				str = {"equip_disable.png"}
			end
		end
		
		if map == tonumber(DATA_Instance:get("equip", "max", "map_id")) and (25 - i ) == tonumber(DATA_Instance:get("equip", "max" ,"ins_id")) then
			local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/click_tip.png" , 6 )
			local ani = display.playFrames(x + 55,50,frames, 0.2, {
				forever = true,
			})
			layer:addChild(ani,5)
		end
		
		local btn = KNBtn:new(PATH,str,x,0,{
			parent = scroll,
			scale = true,
			callback = function()
				if (25 - i) % 4 == 0 then      --这个是根据位置计算，能被4整除的位置是宝箱
--					if map < DATA_Instance:get("equip", "max", "map_id") or (25 - i) < DATA_Instance:get("equip", "max", "ins_id") then
--						KNMsg.getInstance():flashShow("宝箱已打开，请继续向上爬吧")
--					else 
--						if (25 - i) <= DATA_Instance:get("equip", "max", "ins_id") then
--							HTTP:call("insequip","openbox",{map_id = map, ins_id = 25 - i},{
--								success_callback = function(data)
--									self:createEquipFb(map)
--									local card_popup = KNCardpopup:new(data["drop"][1] , function()
--										end , {
----											init_x =  196,
----											init_y = 211,
----											end_x =  196,
----											end_y =  211,
----											top_tips = display.strokeLabel("锦囊已使用，获得物品:", 0, 0, 20),
--										})
--									display.getRunningScene():addChild(card_popup:play())
--									if i == 1 then --最后一个
--										HTTP:call("insequip", "get", {map_id = map + 1}, {success_callback = function()
--											self:createEquipFb(map + 1)
--										end})
--									end	
--								end
--							})
--						else
					local open 
					if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) or (25 - i) <= tonumber(DATA_Instance:get("equip", "max", "ins_id")) then
						open = true
					end
					
					self:createTip(map, 25 - i, function(finish)
						if isBagFull() then
							return false
						end
						
						HTTP:call("insequip","openbox",{map_id = map, ins_id = 25 - i},{
							success_callback = function(data)
								self:createEquipFb(map)
								local card_popup = KNCardpopup:new(data["drop"][1] , function()
									finish()
									end , {
--											init_x =  196,
--											init_y = 211,
--											end_x =  196,
--											end_y =  211,
--											top_tips = display.strokeLabel("锦囊已使用，获得物品:", 0, 0, 20),
									})
								display.getRunningScene():addChild(card_popup:play())
--								if i == 1 then --最后一个
--									HTTP:call("insequip", "get", {map_id = map + 1}, {success_callback = function()
--										self:createEquipFb(map + 1)
--									end})
--								end	
							end
						})
					end, open)	
--						end
--					end
				else   --副本
					local open 
					if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) or (25 - i) <= tonumber(DATA_Instance:get("equip", "max", "ins_id")) then
						open = true
					end
					self:createTip(map, 25 - i, function()
						if isBagFull() then
							return false
						end
						local curData = {map_id = map, ins_id = 25 - i}
						DATA_Instance:setCurEquipData( curData )
						SOCKET:getInstance("battle"):call("insequip" , "execute" , "execute", curData )
					end, open)	
				end
			end
		})
		
		if i == 1 then
			layer:setContentSize(CCSizeMake(380,100))
			x = x + 95 
		elseif (i - 1) % 4 == 0 then -- 这里是宝箱
			layer:setContentSize(CCSizeMake(380,100))	
			if flag > 0 then
				x = x + flag * 95
			else
				x = x + flag * 95
			end
		elseif i % 4 == 0 then
			flag = -flag
			layer:setContentSize(CCSizeMake(380,50))
		else   --这里是副本挑占的按钮
			if flag > 0 then
				x = x + flag * 95
			else
				x = x + flag * 95
			end
			layer:setContentSize(CCSizeMake(380,30))	
		end
		
		layer:addChild(btn:getLayer())
		scroll:addChild(layer , btn)
	end

	if map < tonumber(DATA_Instance:get("equip", "max", "map_id")) then
		scroll:setIndex(0, true, 50)
	else
		scroll:setIndex( 25 - tonumber(DATA_Instance:get("equip", "max", "ins_id")) , true , 50)
	end
	self.mainLayer:addChild(scroll:getLayer())
	
	self.layer:addChild(self.mainLayer)
	
	self:createInfo(PATH.."equip_title.png",function()
		self:createMain("equip")
	end)


	-- 新手引导
	if KNGuide:getStep() == 803 then
		local btn = scroll:getItems(24)
		local btn_range = btn:getRange()

		KNGuide:show( btn:getLayer() , {
			--remove = true,
			x = btn_range:getMinX(),
			y = btn_range:getMinY(),
		})
	end
end

function FBLayer:createPetFb()
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()
	
	
	local bg = display.newSprite(COMMONPATH.."bg_smaller.png")
	setAnchPos(bg, 240, 110, 0.5)
	self.mainLayer:addChild(bg)
	
	
	local content, tabs = nil, {}
	
	local function createContent(tab,pos)
		if content then
			self:stopTimer()
			self.mainLayer:removeChild(content, true)
		end
		content = display.newLayer()
		 
		local moneyType = "gold"
		if pos == 1 then
			moneyType = "silver"
		end
		local img = display.newSprite(PATH..tab.."_img.png")
		setAnchPos(img, 27, 460)
		content:addChild(img)
		
		img = display.newSprite(PATH.."pet_bottom.png")
		setAnchPos(img, 22, 115)
		content:addChild(img)
		
		local showLayer
		local function show()
			-- 狩猎获得的物品展示
			if showLayer then
				content:removeChild(showLayer,true)
			end
				showLayer = display.newLayer()
			local x, y = 35, 280
			local listNum =  #(DATA_Instance:get("pet", "message", pos.."") or {})
			for i = 1, 15 do
				local front, other, text, cid
				local last
				if DATA_Instance:get("pet", "message", pos.."") and i <= listNum then
					if i <= (DATA_Instance:get("pet", "message", pos.."_last") or 0) then
						last = {COMMONPATH.."select2.png",-12,-10, 15}
					end
					cid = DATA_Instance:get("pet", "message", pos.."", listNum - i + 1 ,"cid")
					front = getImageByType(cid, "s")
					local num = DATA_Instance:get("pet", "message", pos.."", listNum - i + 1, "num")
					if  num and num > 0 then
						other = {{COMMONPATH.."egg_num_bg.png", 50, -5,16},last}
						text = {num, 18, ccc3(255, 255, 255), ccp(28, -27), nil, 17}
					end
				end
				
				local data 
				if cid then			
					data = getConfig(getCidType(cid),cid)
					data["cid"] = cid
				end
				local gift = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, x, y, {
					front = front,
					other = other,
					text = text,
					scale = true,
					noTouch = (cid == nil),
					callback = function()
							pushScene("detail" , {
							detail = getCidType(cid),
							data = data,
						})
					end
				})
				showLayer:addChild(gift:getLayer())
				
				x = x + gift:getWidth() * 1.3
				if i % 5 == 0 then
					x =35 
					y = y  - gift:getHeight() * 1.15
				end
			end
			content:addChild(showLayer)
		end
		
		show()
		
		for i = 1, 3 do
			local get = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 18 + (i - 1) * 150, 415, {
				front = PATH.."p"..DATA_Instance:get("pet", "instance", pos.."", i.."", "count")..".png",
				callback = function()
					if DATA_Instance:get("pet","instance", pos.."", i.."", "free_time") == 0 and DATA_Account:get(moneyType) < tonumber(DATA_Instance:get("pet","instance", pos.."", i.."",moneyType)) then
						KNMsg.getInstance():flashShow(moneyType == "gold" and "金币不足" or "银币不足")
						return false
					end
--					
--					if DATA_Instance:get("pet", "instance",pos.."", i.."", "cool") > 0 then
--						KNMsg.getInstance():flashShow("请休息一下，稍候再来吧*_*")
--						return false
--					end

					if isBagFull() then
						return false
					end

					local success = false
					local aniDone = false
					local http_request
					http_request = HTTP:call("inspetnew", "finish", {map_id = pos, ins_id = i},{
						no_loading = true,
						success_callback = function()
							 success = true
							 if aniDone then
								 local num = 0
								for j = 1, 3 do
									num = num + DATA_Instance:get("pet","instance", pos.."", j.."", "free_time")
								end
								tabs[pos]:setText(num)
								KNMsg.getInstance():flashShow("您获得的物品已放入背包")
								createContent(tab, pos)
							 end
						 end})
						 
					local mask = KNMask:new({opacity = 0})
					content:addChild(mask:getLayer())
					local function getEffect(cur, max) 
						local frame = display.newFramesWithImage(IMG_PATH.."image/scene/battle/skillAction/3903.png",4)
						local sprite
						local x = 50 + math.random(300)
						local y = 500 + math.random(100)
						sprite = display.playFrames(x,y, frame, 0.05,{
							onComplete = function()
								content:removeChild(sprite, true)
								local gift = display.newSprite(PATH.."pet_gift.png")	
								setAnchPos(gift, x, y, 0.5, 0.5)
								gift:runAction(getSequenceAction(CCJumpTo:create(0.1, ccp(x,y),50,1), getSpawnAction(CCMoveTo:create(0.2,ccp(65,310)),CCRotateTo:create(0.2,720)),CCCallFunc:create(function()
									if success  then
										if  cur == max then
											content:removeChild(gift, true)
											-- content:removeChild(mask, true)
											mask:remove()
											local num = 0
											for j = 1, 3 do
												num = num + DATA_Instance:get("pet","instance", pos.."", j.."", "free_time")
											end
											tabs[pos]:setText(num)
											KNMsg.getInstance():flashShow("您获得的物品已放入背包")
											createContent(tab, pos)
										else
--											show()
										end
									else
										if cur == max then
											aniDone = true
											http_request:showLoading()
											content:removeChild(gift, true)
											-- content:removeChild(mask, true)
											mask:remove()
										end
									end
								end)))
								content:addChild(gift)
							end
						} )
						content:addChild(sprite)
					end
					
					for j = 1, i == 1 and 1 or i * i + 1 do
						mask:getLayer():runAction(getSequenceAction(CCDelayTime:create((j - 1) * 0.2), CCCallFunc:create(function()
							getEffect(j, i == 1 and 1 or i * i + 1)
						end)))
					end
				end
			})
			content:addChild(get:getLayer())

			-- 新手引导
			if i == 3 and KNGuide:getStep() == 3104 then
				KNGuide:show( get:getLayer() , {
					remove = true
				})
			end
			
			get = display.newSprite(PATH.."text_bg.png")
			setAnchPos(get, 18 + (i - 1) * 150, 360)
			content:addChild(get)
			
			local y = 375
			get = display.newSprite(COMMONPATH..moneyType..".png")
			setAnchPos(get, 40 + (i - 1) * 150, y)
			content:addChild(get)
			
			local str = DATA_Instance:get("pet", "instance",pos.."", i.."", moneyType)
			if DATA_Instance:get("pet","instance", pos.."", i.."", "free_time") > 0 then
				str = "免费 "
			end
			local get = display.strokeLabel(str == 0 and "免费" or str, 80 + (i - 1) * 150, y, 18, ccc3(0x2c, 0, 0))
			content:addChild(get)
			
--			local time  = DATA_Instance:get("pet", "instance", pos.."", i.."", "cool") 
--			if time > 0 then
--				local timeLabel = display.strokeLabel(timeConvert(time), 40 + (i - 1) * 150, 365, 18, ccc3(0x2c, 0, 0))
--				content:addChild(timeLabel)
--				Clock:addTimeFun("inspet_clock"..i, function()
--					if time > 0 then
--						time = time - 1
--						timeLabel:setString(timeConvert(time))
--					else
--						self:stopTimer(i)
--					end
--				end)
--			end
		end
	
	
		self.mainLayer:addChild(content)
	end
	
	local title = {
		{"farmer"},
		{"town"},
		{"gov"}
	}
	--这里是标签按钮，有纪录其免费狩猎的次数
	local group = KNRadioGroup:new()
	for i = 1, #title do
		if i ~= 2 then
			local freeNum = 0
			for n = 1, 3 do
				freeNum = freeNum + DATA_Instance:get("pet","instance", i.."", n.."", "free_time")
			end
			tabs[i] = KNBtn:new(PATH, {"tab_normal.png", "tab_select.png"}, 20 + ((i - 1) - (i == 3 and 1 or 0)) * 150, 690, {
				front = {PATH..title[i][1]..".png", PATH..title[i][1].."_select.png"},
				other = {COMMONPATH.."egg_num_bg.png", 120, 40},
				text = {freeNum, 18, ccc3(255,255,255), ccp(63, 22), nil, 17},
				callback = function()
--					if i == 1 then
--						HTTP:call("inspetnew", "get", {map_id = 1}, {success_callback = function()
--							createContent(title[i][1], i)
--						end})	
--					else
						createContent(title[i][1], i)
--					end
				end
			},group)
			self.mainLayer:addChild(tabs[i]:getLayer())
		end
	end
	group:chooseByIndex(2, true)
	
	bg = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(bg, 5, 688)
	self.mainLayer:addChild(bg)
	
	
	
	
	self.layer:addChild(self.mainLayer)
	self:createInfo(PATH.."pet_title.png",function()
		self:createMain("pet")
	end)


	-- 新手引导
	if KNGuide:getStep() == 3103 then
		KNGuide:show( tabs[1]:getLayer() )
	end
end

function FBLayer:createHeroFb(data)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	self.state = HERO
	
	local bg = display.newSprite(PATH.."hero_new_bg.jpg")
	setAnchPos(bg, 240, 460, 0.5, 0.5)
	self.mainLayer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."have.png")
	setAnchPos(bg, 300, 700)
	self.mainLayer:addChild(bg)
	
	bg = display.newSprite(COMMONPATH.."gold.png")
	setAnchPos(bg, 350, 700)
	self.mainLayer:addChild(bg)
	
	self.mainLayer:addChild(createLabel({str = DATA_Account:get("gold"), x = 380, y = 702, color = ccc3(0xff,0xd1, 0x39)}))
	
	
	local curStar = 5
	local select = {}
	local function rdHero()
		if not self.needHeroList then
			self.needHeroList = {}
			for k, v in pairs(getConfig("general")) do
				if v.star >= 3 and v.hidden == 0 then
					if not self.needHeroList[v.star] then
						self.needHeroList[v.star] = {}
					end
					table.insert(self.needHeroList[v.star], k)
				end
			end
		end
		
		if not select[curStar] then
			select[curStar] = {}	
		end
		
		if #select[curStar] == 3 then
			curStar = curStar - 1
			select[curStar] = {}
		end
		
		local rd = self.needHeroList[curStar][math.random(1, #self.needHeroList[curStar])]
		
		while table.hasValue(select[curStar], rd) do
			rd = self.needHeroList[curStar][math.random(1, #self.needHeroList[curStar])]
		end
		
		table.insert(select[curStar], rd)
		
		return rd
	end
	--生成主页滑动卡牌
	local items = {}
	for i = 1, 8 do
		items[i] = HomeCard:new(435 , i , rdHero())
		items[i]:addTo(i,self.mainLayer)
	end
	
	for i = 1, 8 do
		items[i]:move(true, self, 1.5)
	end
	
	for i = 1, 2 do
		local kind = i == 1 and "xian" or "shen"
		local btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 20 + (i - 1) * 220, 115, {
		front = PATH..(i == 1 and "normal_text.png" or "advance_text.png"),
		callback = function()
			if data[kind].gold > 0 and not countGold(data[kind].gold) then
				return false
			end
			for i = 1, 8 do
				items[i]:stop()
				items[i]:move(true, self, 0.01)
			end
			HTTP:call("penglai", "rand", {type = kind }, {
				no_loading = true,
				success_callback = function(data)
--					self:createHeroFb(data["_G_penglai"])
					for i = 1, 8 do
						items[i]:stop()
					end					
					self:popCardList(data["awards"]["drop"], data["_G_penglai"])
				end, error_callback = function(msg)
					KNMsg.getInstance():flashShow(msg.msg)
					self:createHeroFb(data)
				end
			})
			end
		})
		self.mainLayer:addChild(btn:getLayer())
		
		if data[kind].curtimes < data[kind].freetimes then
			self.mainLayer:addChild(createLabel({str = "免费", x = 175 + (i - 1) * 220,y = 138, color = ccc3(0xff,0xd1, 0x39)} ))
			self.mainLayer:addChild(createLabel({str = (data[kind].freetimes - data[kind].curtimes).."/"..data[kind].freetimes, x = 180 + (i - 1) * 220,y = 115, color =DESCCOLOR} ))
		else
			local gold = display.newSprite(COMMONPATH.."gold.png")
			setAnchPos(gold, 165 + (i - 1) * 220, 135 )
			self.mainLayer:addChild(gold)
			
			self.mainLayer:addChild(createLabel({str = data[kind].gold, x = 200 + (i - 1) * 220,y = 138, color = ccc3(0xff,0xd1, 0x39)} ))
			
			local cool = data[kind].cool
			local timeText = createLabel({str = timeConvert(data[kind].cool), x = 160 + (i - 1) * 220,y = 115, color = DESCCOLOR, size = 14})
			Clock:addTimeFun("hero_clock"..i, function()
					if cool > 0 then
						cool = cool - 1
						timeText:setString(timeConvert(cool))
					else
						HTTP:call("penglai", "get", {}, {
							success_callback = function(data)
								Clock:removeTimeFun("hero_clock1")
								Clock:removeTimeFun("hero_clock2")
								self:createHeroFb(data) 
							end
						})
					end
				end)
			self.mainLayer:addChild(timeText)
		end

		if i == 1 and KNGuide:getStep() == 3003 then
			KNGuide:show( btn:getLayer() , {remove = true} )
		end

		if i == 2 and KNGuide:getStep() == 3004 then
			KNGuide:show( btn:getLayer() , {remove = true} )
		end
	end
	

	
	
	
--	local posInfo = {
--		--不同位置的锚点，x坐标，旋转角度，z轴，缩放比例
--		[0] = {ccp(0,0.5), -200, -70, 0,0.8},
--	    {ccp(0,0.5),   10, -70, 1, 0.8},
--		{ccp(0,0.5),  80, -70, 2, 0.8},
--		{ccp(0,0.5), 140,   0, 3,  1 },
--		{ccp(1,0.5), 390,  70, 2, 0.8},
--		{ccp(1,0.5), 450,  70, 1, 0.8},
--		{ccp(1,0.5), 600,  70, 0, 0.8},
--		{ccp(1,0.5), 600,  70, -1, 0.8},
--		{ccp(1,0.5), 600,  70, -2, 0.8},
--		{ccp(1,0.5), 600,  70, -3, 0.8},
--	}
--	
--	local function addTo(i)
--		local layer = display.newLayer()
--		local bg =  display.newSprite(IMG_PATH.."image/scene/home/card_bg.png")
--		setAnchPos(bg)
--		layer:addChild(bg)
--		
--		layer:setContentSize(bg:getContentSize())
--		layer:ignoreAnchorPointForPosition(false)
--		setAnchPos(layer,posInfo[i][2] + 10, 425,0.5,0.5)
--		
--		local rotate = posInfo[i][3] 
--		layer:setScale(posInfo[i][5])
--		layer:setAnchorPoint(posInfo[i][1])
--		
--		--使用摄像机进行卡牌的翻转效果实现
--		layer:runAction(CCOrbitCamera:create(0,1,0,rotate,0,0,0))
--		
----		if i ~= 3 then
----			transition.playSprites(layer,"tintTo",{time = 0, r = 100,g=100,b=100})
----		else
----			self:showLight(true)
----		end
--		self.mainLayer:addChild(layer,posInfo[i][4])
--		return layer
--	end
--	
--	local function move(layer, i)
--		local time =2 
--		local index
--		
--		if i == 0 then
--			index = 9
--			layer:setPositionX(posInfo[index][2])
--		else
--			index = i - 1
--			
--		end
--		
--		if index < 7 then
--			layer:runAction(getSequenceAction(getSpawnAction(
--				CCOrbitCamera:create(time,1,0,posInfo[index][3] - layer:getRotation(),0,0,0),
--				CCMoveTo:create(time,ccp(posInfo[index][2],layer:getPositionY())),
--				CCScaleTo:create(time,posInfo[index][5])
--			),CCCallFunc:create(function()
--				move(layer, index)
--			end)))
--		else
--			layer:runAction(getSequenceAction(CCDelayTime:create(time), CCCallFunc:create(function()
--				move(layer, index)
--			end)))
--		end
--		
--	end
--	
--	for i = 1, 8 do
--		local item = addTo(i)
--		move(item, i)
--	end
	
	self.layer:addChild(self.mainLayer)
	
	self:createInfo(PATH.."hero_title.png",function()
		self:createMain("hero")
	end)
end

--修改一次的蓬莱岛
function FBLayer:createHeroFb2(data)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	self.state = HERO
	
	local bg = display.newSprite(PATH.."xian.png")
	setAnchPos(bg, 240, 425, 0.5)
	self.mainLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."shen.png")
	setAnchPos(bg, 240, 100, 0.5)
	self.mainLayer:addChild(bg)
	
--	--普通祈将
--	for i = 1, 2 do
--		local kind = i == 1 and "xianonce" or "shenonce"
--		local btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 20, 430 - (i - 1) * 325, {
--			front = PATH.."normal_want.png",
--			callback = function()
--				HTTP:call("penglai", "rand", {type = kind}, {
--					success_callback = function(data)
--						if i == 1 then
--							self:createHeroFb(data["_G_penglai"]["config"])
--						end
--						local card_popup = KNCardpopup:new(data["awards"]["drop"][1], function()
--						
--						end , {
--							end_x = -80,
--							end_y = -350,
--						})
--						display.getRunningScene():addChild(card_popup:play())
--					end
--				})
--			end
--		})
--		self.mainLayer:addChild(btn:getLayer())
--		
--		local gold = display.newSprite(COMMONPATH.."gold.png")
--		setAnchPos(gold,165, 440 - (i - 1) * 325)
--		self.mainLayer:addChild(gold)
--		
--		gold = createLabel({str = (data[kind]["gold"] == 0 and "免费" or data[kind]["gold"]), x = 200, y = 440 - (i - 1) * 325})
--		self.mainLayer:addChild(gold)
--
--
--	end
	
	--虔诚祈将
	for i = 1, 2 do
		local kind = i == 1 and "xianmuti" or "shenmuti"
		local btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 160, 430 - (i - 1) * 325, {
		front = PATH.."better_want.png",
		callback = function()
			HTTP:call("penglai", "rand", {type = kind }, {
				success_callback = function(data)
					self:createHeroFb(data["_G_penglai"]["config"])
					self:popCardList(data["awards"]["drop"])
				end
			})
			end
		})
		self.mainLayer:addChild(btn:getLayer())
		
		if i == 2 then
			local gold = display.newSprite(COMMONPATH.."gold.png")
			setAnchPos(gold,305, 440 - (i - 1) * 325)
			self.mainLayer:addChild(gold)
			
			gold = createLabel({str = data[kind]["gold"], x = 335, y = 440 - (i - 1) * 325})
			self.mainLayer:addChild(gold)
		else
			local times = createLabel({str = "免费:"..data[kind]["count"].."/"..data[kind]["max"], x = 305, y = 440 - (i - 1) * 325})
			self.mainLayer:addChild(times)
		end

		--if i == 1 and KNGuide:getStep() == 3003 then
		--	KNGuide:show( btn:getLayer() , {remove = true} )
		--end
	end
	
	
	
	self.layer:addChild(self.mainLayer)
	
	self:createInfo(PATH.."hero_title.png",function()
		self:createMain("hero")
	end)
end

--保留原来的抽签功能
function FBLayer:createHeroFb1()
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	self.state = HERO

	local mask
	local http_request
	if #DATA_Instance:get("hero", "roll_temp") > 0 then
		mask = KNMask:new({opacity = 0})
		self.mainLayer:addChild(mask:getLayer())
	
		local lots = {}
--		local rotate = {
--			{-18, 130, 270},
--			{-10, 155, 300},
--			{-3,  188,320},
--			{ 3,  227, 325},
--			{ 10, 260, 303},
--			{ 18, 285, 285}
--		}
--		local lotNum = 6
		
		local rotate = {
			{-18, 150, 270},
--			{-10, 155, 300},
			{-3,  168,320},
			{ 3,  247, 325},
--			{ 10, 260, 303},
			{ 18, 265, 285}
		}
		local lotNum = 4
		local index = 2
		for i = 1, lotNum do
			lots[i] = Lot:new(DATA_Instance:get("hero", "roll_temp", i), DATA_Instance:get("hero", "roll_temp", i) == 1,  rotate[1][2],  rotate[1][3], rotate[1][1])
			self.mainLayer:addChild(lots[i]:getLayer())
		end
		
		--抽签面开始动画
		local function startMove(start)
			for i = start, lotNum do
				lots[i]:runAction(getSequenceAction(getSpawnAction(CCMoveTo:create(0.05,ccp(rotate[start][2],rotate[start][3])),
									CCRotateTo:create(0.05,rotate[start][1])),
										CCCallFunc:create(function()
					if start < lotNum and i == lotNum then
						startMove(start + 1)
					elseif start == lotNum then
						-- self.mainLayer:removeChild(mask, true)
						mask:remove()
					end
				end)))	
			end
		end
		
		local success, aniDone 
		--改签动画
		local function change(num)
			for i = lotNum - num, lotNum do
				lots[i]:runAction(getSequenceAction(getSpawnAction(CCMoveTo:create(0.05,ccp(rotate[lotNum - num][2],rotate[lotNum - num][3])),
					CCRotateTo:create(0.05,rotate[lotNum - num][1])),
						CCCallFunc:create(function()
						if i == lotNum then
							if num < lotNum - 1 then
								 change(num + 1)
							else
								if success then
									self:createHeroFb()
								else
									http_request:showLoading()
									aniDone = true
								end
							end
						end
				end)))	
			end
		end
		
		startMove(2)
		
		
		local tempLayer = display.newLayer() 
		
		local random = display.newSprite(PATH.."random.png")
		setAnchPos(random)
		
		tempLayer:setContentSize(random:getContentSize())
		tempLayer:ignoreAnchorPointForPosition(false)
		setAnchPos(tempLayer, 240, 350, 0.5,0.5)
		tempLayer:addChild(random)
		
		local text = display.strokeLabel("当前签面有机率获得"..DATA_Instance:get("hero", "hero_star_range", "min").."-"..DATA_Instance:get("hero", "hero_star_range", "max").."星的英雄", 15, 10, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil, {
			dimensions_width = 160,
			dimensions_height = 60
		})
		tempLayer:addChild(text)
		
	
		
		text = display.strokeLabel("普通改签有几率获得更好签面,住持改签一定会获得上签", 10, 115, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil) 
		self.mainLayer:addChild(text)
		
		--消耗的黄金
		text = display.newSprite(COMMONPATH.."gold.png")
		setAnchPos(text, 70, 193)
		self.mainLayer:addChild(text)
		
		text = display.strokeLabel(DATA_Instance:get("hero", "alter_gold") == 0 and "免费" or DATA_Instance:get("hero", "alter_gold"),100, 195, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil) 
		self.mainLayer:addChild(text)
		
		--用户当前黄金
		text = display.newSprite(COMMONPATH.."gold.png")
		setAnchPos(text, 342, 721)
		self.mainLayer:addChild(text)
		
		text = display.strokeLabel("黄金:        "..DATA_Account:get("gold"),300, 725, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil) 
		self.mainLayer:addChild(text)
		
		local function changeLot(type)
			local value = 0
			for i = 1, lotNum do
				value = value + DATA_Instance:get("hero", "roll_temp", i)
			end
			if value == lotNum then
				KNMsg.getInstance():flashShow("不需要改签")
				return false
			end

			local needGold 
			if type == 1 then
				needGold = DATA_Instance:get("hero", "alter_gold") 
			else
				needGold = DATA_Instance:get("hero", "adv_alter_gold") 
			end
			
			if not countGold(needGold ) then
				return false
			end
			mask  = KNMask:new({opacity = 0})
			self.mainLayer:addChild(mask:getLayer())
			change(0)
			http_request = HTTP:call("insheronewnew", "alter", {type = type}, {
				no_loading = true,					
				error_callback = function()
					KNMsg.getInstance():flashShow("请求失败，请检查网络或重试!~")
					-- self.mainLayer:removeChild(mask, true)
					mask:remove()
				end,
				success_callback = function()
					success = true
					if aniDone then
						self:createHeroFb()
					end
				end})
		end
		
		--改签 的按钮
		local change = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 40, 150, {
			front = PATH.."change_text.png",
			callback = function()
				changeLot(1)
			end
		})
		self.mainLayer:addChild(change:getLayer())
		-- 新手引导
		--if KNGuide:getStep() == 3004 then
		--	KNGuide:show( change:getLayer() )
		--end
		
		--消耗的黄金
		text = display.newSprite(COMMONPATH.."gold.png")
		setAnchPos(text, 340, 193)
		self.mainLayer:addChild(text)
		
		text = display.strokeLabel(DATA_Instance:get("hero", "adv_alter_gold"),370, 195, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil) 
		self.mainLayer:addChild(text)
		
		--住持改签
		change = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 300, 150, {
			front = PATH.."exchange_text.png",
			callback = function()
				changeLot(2)
			end
		})
		self.mainLayer:addChild(change:getLayer())
		
		self.mainLayer:addChild(tempLayer)
		tempLayer:setTouchEnabled(true)			
		tempLayer:registerScriptTouchHandler(function(type,x,y)
			if CCRectMake(240 - random:getContentSize().width / 2, 350 - random:getContentSize().height / 2, random:getContentSize().width, random:getContentSize().height):containsPoint(ccp(x, y)) then
				if type == CCTOUCHBEGAN then
					self.mainLayer:addChild(KNMask:new({opacity = 0}):getLayer())
					local loadAction = 	getSpawnAction(CCRotateTo:create(20,36000),CCScaleTo:create(0.5,1.3))
					tempLayer:runAction(loadAction)
					HTTP:call("insheronewnew", "exchange", {}, {
						no_loading = true,
						error_callback = function()
							self:createHeroFb()
							KNMsg.getInstance():flashShow("网络连接失败,请检查网络或重试")
						end,
						success_callback = function(cid)
							tempLayer:runAction(getSequenceAction(CCDelayTime:create(1),getSpawnAction(CCRotateTo:create(0.5, 1800),CCScaleTo:create(0.5,0)),CCCallFunc:create(function()
								local card_popup = KNCardpopup:new(cid , function()
									self:createHeroFb()
								end , {
									offset_y = -100
								 })
								display.getRunningScene():addChild(card_popup:play())					
							end)))
						end
					})
				end
			end
		end,false,0,false)

		-- 新手引导
		--[[
		if KNGuide:getStep() == 3005 then
			KNGuide:show( tempLayer , {
				remove = true,
				x = tempLayer.x - tempLayer:getContentSize().width / 2,
				y = tempLayer.y - tempLayer:getContentSize().height / 2,
			} )
		end
		]]
		
	else
		local tips = {
			"1、点击抽签可以获得四支签",
			"2、普通改签有很大机率获得更好的签面" , 
			"3、住持改签必出一个上签",
			"4、点击卡牌可兑换英雄",
			"5、四个上签必出一个四星英雄"
		}
		for i = 1, #tips do
			local text = display.strokeLabel(tips[i], 100, 750	 - i * 25, 18, ccc3(0xff, 0xfb, 0xd4), nil, nil, {
			})
			self.mainLayer:addChild(text)
		end
		
		local lotPot = display.newSprite(PATH.."lot_pot.png")
		setAnchPos(lotPot, 240,350, 0.5, 0.3)
		self.mainLayer:addChild(lotPot)
		
		local count= 0
		local function lotFunc(time)
--			audio.playSound(IMG_PATH .. "sound/draw_lots.mp3")
			
			local action = 	getSequenceAction(CCRotateTo:create(time,20),CCRotateTo:create(time,0),CCRotateTo:create(time, -20),CCRotateTo:create(time,0),CCCallFunc:create(function()
				count = count + 1
				if count < 7 then
					lotPot:runAction(lotFunc(time))
				else
					lotPot:runAction(getSequenceAction(CCFadeOut:create(0.5), CCCallFunc:create(function()
						self:createHeroFb()
					end)))
				end
			end))
			return action
		end
		
		local text = display.strokeLabel("抽签次数:"..DATA_Instance:get("hero", "free_roll_times").."/"..DATA_Instance:get("hero","max_roll_times"), 180, 125, 20, ccc3(0xff, 0xfb, 0xd4))
		self.mainLayer:addChild(text)
		
		
		local start = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 160, {
			front = PATH.."draw_text.png",
			callback = function()
				if DATA_Instance:get("hero", "free_roll_times") > 0 then
					if isBagFull() then
						return false
					end
					mask = KNMask:new({opacity = 0})
					self.mainLayer:addChild(mask:getLayer())
					lotPot:runAction(lotFunc(0.1))
					
					HTTP:call("insheronewnew", "draw", {}, {
						no_loading = true,
						error_callback = function()
							KNMsg.getInstance():flashShow("请求失败，请检查网络或重试!~")
							-- self.mainLayer:removeChild(mask, true)
							mask:remove()
						end,
						success_callback = function()
--							lotPot:runAction(lotFunc(0.1))
						end
					})
				else
					KNMsg.getInstance():flashShow("今日抽签次数已用完，请明天再来吧！~")
				end
			end
		})
		self.mainLayer:addChild(start:getLayer())

		-- 新手引导
		--[[
		if KNGuide:getStep() == 3003 then
			KNGuide:show( start:getLayer() )
		end
		]]
	end
	
	self.layer:addChild(self.mainLayer)
	
	self:createInfo(PATH.."hero_title.png",function()
		self:createMain("hero")
	end)
	
end

function FBLayer:createRoleFb(kind)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()
	
	local space
	if kind == "hero" then
		self.state = HERO
		space = 1.25
	else
		self.state = PET
		space = 1.5
	end
	
	local bg = display.newSprite(COMMONPATH.."bg_small.png")
	setAnchPos(bg, 240, 110, 0.5)
	self.mainLayer:addChild(bg)
	
	 bg = display.newSprite(PATH..kind.."_bg.png")
	setAnchPos(bg, 240, 150, 0.5)
	self.mainLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."gift_bg.png")
	setAnchPos(bg, 245, 620, 0.5)
	self.mainLayer:addChild(bg)
	
	local title = display.newSprite(PATH.."rest_time.png")
	setAnchPos(title,50,590)
	self.mainLayer:addChild(title)
	
	title = display.strokeLabel(DATA_Instance:get(kind,"point"), 130, 590, 20, ccc3(0xff, 0xfb, 0xd4))
	self.mainLayer:addChild(title)
	
	title = display.newSprite(PATH.."gift_text.png")
	setAnchPos(title, 130, 680)
	self.mainLayer:addChild(title)
	
	title = display.strokeLabel(getConfig("prop", DATA_Instance:get(kind,"current_award"),"name"),130, 650, 18)
	self.mainLayer:addChild(title)
	
	local refresh = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"},350, 650, {
		scale = true,
		front = COMMONPATH.."refresh_small.png",
		callback = function()
			HTTP:call("ins"..kind,"refresh",{},{
				success_callback = function()
					self:createRoleFb(kind)
					KNMsg.getInstance():flashShow("恭喜你刷到"..getConfig("prop",DATA_Instance:get(kind,"current_award"),"name"))
				end
			})
		end
		
	})
	self.mainLayer:addChild(refresh:getLayer())
	
	local gift = KNBtn:new(SCENECOMMON,{"skill_frame1.png"}, 50, 640, {
		scale = true,
		front = IMG_PATH.."image/"..getCidType(DATA_Instance:get(kind,"current_award")).."/s_"..DATA_Instance:get(kind,"current_award")..".png"
	})
	self.mainLayer:addChild(gift:getLayer())
	
	
	local x, y, t = 50, 490, DATA_Instance:get(kind, "inscount")
	local pass = DATA_Instance:get(kind,"pass")
	for i = 1,t do
		local bgStr = kind.."_disable.png"	
		for k, v in pairs(pass) do
			if v == i then
				bgStr = kind.."_enable.png"
				break
			end			
		end
		
		local btn = KNBtn:new(PATH,{bgStr}, x, y, {
			id = i,
			scale = true,
			callback = function()
				SOCKET:getInstance("battle"):call("ins"..kind , "execute" , "execute",{ins_id = i})
			end
		})
		self.mainLayer:addChild(btn:getLayer())
		x = x + btn:getWidth() * space 
		if i % 3 == 0 then
			x = 50
			y = y - btn:getHeight() * 1.15
		end
	end
	
	self.layer:addChild(self.mainLayer)
	self:createInfo(PATH..kind.."_title.png",function()
		self:createMain(kind)
	end)
end

function FBLayer:createTip(map, ins, func, open)
	map = tonumber(map)
	ins = tonumber(ins)
	
	local layer = display.newLayer()
	local mask = KNMask:new({item = layer})
	
	local bg = display.newSprite(COMMONPATH.."tip_bg.png")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	layer:addChild(bg)
	
	local isBox = ins % 4 == 0
	local front 
	if isBox then
		if DATA_Instance:get("equip", "max", "map_id") == map and DATA_Instance:get("equip", "max", "ins_id") == ins then
			front = PATH.."open.png" 	
			bg = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		else
			front = PATH..(open and "opened.png" or "open_grey.png") 	
			bg = {"btn_bg_red2.png"}
			open = false
		end
	else
		front = PATH..(open and "challenge.png" or "challenge_grey.png")	
		bg = {"btn_bg_red.png" , "btn_bg_red_pre.png"}
		if not open then
			bg = {"btn_bg_red2.png"}
		end
	end
	
	
	local okBtn = KNBtn:new(COMMONPATH, bg, 70, 310, {
		priority = -131,
		front = front,
		-- noTouch = not open,
		callback = function() 
			if open then
				func(function()
					-- self.layer:removeChild(mask, true)
					mask:remove()
				end)
			else
				if isBox then
					if map < DATA_Instance:get("equip", "max", "map_id") or ins < DATA_Instance:get("equip", "max", "ins_id") then
						KNMsg.getInstance():flashShow("宝箱已打开！~")
					else
						KNMsg.getInstance():flashShow("饭要一口一口吃，塔要一层一层爬，少年")
					end
				else
					KNMsg.getInstance():flashShow("饭要一口一口吃，塔要一层一层爬，少年")
				end
			end
		end
	})
	layer:addChild(okBtn:getLayer())

	-- 新手引导
	if KNGuide:getStep() == 804 then
		KNGuide:show( okBtn:getLayer() )
	end

	
	local cancelBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 270, 310, {
		priority = -131,
		front = COMMONPATH.."back.png",
		callback = function()
			-- self.layer:removeChild(mask, true)			
			mask:remove()
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	local text

	
	if isBox then
	
		text = display.newSprite(PATH.."gift_bg.png")
		setAnchPos(text, 30, 400)
		layer:addChild(text)
	
		text = display.newSprite(PATH.."box_gifts.png")
		setAnchPos(text, 70, 480)
		layer:addChild(text)
		
		for i = 1, #DATA_Instance:get("equip", map, ins, "box") do
			local temp = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, 110 + (i - 1) * 90, 415, {
				front = getImageByType(DATA_Instance:get("equip", map, ins, "box", i),"s"),
				text = {getConfig(getCidType(DATA_Instance:get("equip", map, ins, "box", i)), DATA_Instance:get("equip", map, ins, "box", i), "name"), 20, ccc3(0x2c, 0, 0), ccp(0, -50)}
			})
			layer:addChild(temp:getLayer())
		end
	
	else
		text = display.newSprite(PATH.."challenge_num.png")
		setAnchPos(text, 70, 500)
		layer:addChild(text)
		
		text = display.strokeLabel(DATA_Instance:get("equip", map, ins, "count").."/"..DATA_Instance:get("equip", map, ins, "max"), 170, 500, 20)
		layer:addChild(text)
		
		text = display.newSprite(PATH.."use.png")	
		setAnchPos(text, 270, 500)
		layer:addChild(text)
		
		text = display.strokeLabel("体力 x1", 325, 502, 20)
		layer:addChild(text)
		
--		text = display.strokeLabel("挑战书 x1", 325, 475, 20)
--		layer:addChild(text)
		
			
		text = display.newSprite(PATH.."gift_bg.png")
		setAnchPos(text, 30, 370)
		layer:addChild(text)
		
		text = display.newSprite(PATH.."gifts.png")
		setAnchPos(text, 70, 450)
		layer:addChild(text)
	
	
		text = display.strokeLabel(DATA_Instance:get("equip", map, ins, "star").."星级的"..Property[DATA_Instance:get("equip", map, ins, "type")], 170, 410, 20, ccc3(0x2c, 0, 0))
		layer:addChild(text)
	end		

	self.layer:addChild(mask:getLayer())
end

function FBLayer:getLayer()
	return self.layer
end

function FBLayer:createInfo(title, func)
	if self.info then
		self.layer:removeChild(self.info:getLayer(), true)
	end
	self.info = InfoLayer:new("fb", 0, {tail_hide = true, title_text = title, closeCallback = func})
	self.layer:addChild(self.info:getLayer(),10)
	
end

function FBLayer:createRobFb(data, star)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	local rob = RobLayer:new({data = data, star = star})
	
	self.mainLayer = rob:getLayer()
	self.layer:addChild(self.mainLayer)
	
	self:createInfo(PATH.."rob_title.png",function()
		if rob:getState() == 1 then
			self:createMain("rob")
		else
			self:createRobFb(data, rob:getStar())	
		end
	end)
end

function FBLayer:stopTimer(index)
	if index then
		if Clock:getKeyIsExist("inspet_clock"..index) then
			Clock:removeTimeFun("inspet_clock"..index)
		end
	else
		Clock:removeTimeFun("inspet_clock1")
		Clock:removeTimeFun("inspet_clock2")
		Clock:removeTimeFun("inspet_clock3")
	end
end

function FBLayer:createDig(map)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	local layer = display.newLayer()
	self.mainLayer = KNMask:new({item = layer}):getLayer()
	
	local bg = display.newSprite(IMG_PATH.."image/scene/battle/battle_bg.png")
	setAnchPos(bg, 240, 425, 0.5, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(IMG_PATH.."image/scene/battle/bg_bottom.png")
	setAnchPos(bg, 240, 0, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(IMG_PATH.."image/scene/battle/bg_bottom.png")
	bg:setFlipY(true)
	bg:setFlipX(true)
	setAnchPos(bg, 240, 854, 0.5, 1)
	layer:addChild(bg)
	
	HTTP:call("message", "get_wajue", {}, {
		success_callback = function(data)
			layer:addChild(createLabel({str = formatMsg(data["template"], data["msg"]), width = 290, x = 180, y = 130, size = 16, color = ccc3(255, 255,255)}))
		end
	})
	
	local back = KNBtn:new(IMG_PATH.."image/scene/login/", {"back.png", "back_pre.png"}, 30, 200, {
		priority = -131,
		callback = function()
			self:createEquipFb(map)
		end
	})
	layer:addChild(back:getLayer())
	
	local dig = KNBtn:new(PATH, {"dig_btn.png"}, 160, 220, {
		priority = -131,
		scale = true,
		callback = function()
			HTTP:call("insequip", "dig", {map_id = map}, {
				success_callback = function(data)
					if data["silver"] then
						KNMsg.getInstance():flashShow("恭幸喜您挖到了"..data["silver"].."银币！~")
					else
						local card_popup = KNCardpopup:new(data["drop"][1] , function()
							self:createDig(map)
						end , {})
						display.getRunningScene():addChild(card_popup:play())					
					end
				end
			})
		end
	})
	layer:addChild(dig:getLayer())
	
	local arrow = display.newSprite(PATH.."arrow.png")
	setAnchPos(arrow, 240, 350, 0.5)
	
	local function jump()
		local action = getSequenceAction(CCJumpTo:create(1,  ccp(240,350), 30, 1), CCCallFunc:create(function()
			arrow:runAction(jump())
		end))
		return action
	end
	
	arrow:runAction(jump())
	layer:addChild(arrow)
	
	
	local x = 50
	for k, v in pairs(DATA_Instance:get("equip",map,25,"bossbox")) do
		local front = getImageByType(v, "s")
		local text = {getConfig(getCidType(v), v, "name"), 14, ccc3(0x5c,0x0c,0x0c), ccp(0,-70)}
		local btn = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, x, 570,{
			front = front,
			text = text
		} )
		self.mainLayer:addChild(btn:getLayer())
		
--			star = display.newSprite(COMMONPATH.."star.png")
--			setAnchPos(star, x + (i - 1) * 20, 520)
--			self.mainLayer:addChild(star)
--		end 
		
		local star
		for i = 1, getConfig(getCidType(v), v, "star") do
			star = display.newSprite(COMMONPATH .. "star.png")
			setAnchPos(star, star:getContentSize().width * (i - 1) + (x + btn:getWidth() / 2) - (star:getContentSize().width * getConfig(getCidType(v), v, "star")) / 2, 540 )
			self.mainLayer:addChild(star)
		end
--			
		x = x + 110
	end
	
	local text = display.strokeLabel("点击墓碑进行挖掘，稀世装备等你来拿！", 100, 645, 16, ccc3(0x5c, 0x0c, 0x0c) )
	layer:addChild(text)
	
	local useGold = display.newSprite(PATH.."use.png")
	setAnchPos(useGold,120,190)
	layer:addChild(useGold)
	
	useGold = display.newSprite(COMMONPATH.."gold.png")
	setAnchPos(useGold, 170, 190)
	layer:addChild(useGold)
	
	useGold = display.strokeLabel(DATA_Instance:get("equip", "dig_fee"), 205, 192, 18, ccc3(0x5c, 0x0c, 0x0c))
	layer:addChild(useGold)
	
	local times = display.newSprite(PATH.."times.png")
	setAnchPos(times,260,190)
	layer:addChild(times)
	
	times = display.strokeLabel(DATA_Instance:get("equip", map, 25, "cur_dig_times").."/"..DATA_Instance:get("equip", map, 25, "max_dig_times"), 315, 192, 18, ccc3(0x5c, 0x0c, 0x0c))
	layer:addChild(times)
	
	self.layer:addChild(self.mainLayer, 10)
end

function FBLayer:popCardList(data, new)
	
	local index = 1
	local function pop(index)
		local card_popup = KNCardpopup:new(data[index] , function()
				if index == table.nums(data) then
					self:createHeroFb(new)
				else
					pop(index + 1)
				end
			end , {
				end_x = -80,
				end_y = -350,
			})
		display.getRunningScene():addChild(card_popup:play())						
	end
	pop(index)
end
--祈将弹出的列表
function FBLayer:popCardList1(data)
	if self.mask then
		self.layer:removeChild(self.mask:getLayer(), true)
	end
	
	local layer = display.newLayer()
	local bg = display.newSprite(PATH.."pop_bg.png")
	setAnchPos(bg, 240, 435, 0.5, 0.5)
	layer:addChild(bg)
	
	local btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 305, {
		front = COMMONPATH.."ok.png",
		priority = -131,
		callback = function()
			self.layer:removeChild(self.mask:getLayer(), true)
		end
	})
	layer:addChild(btn:getLayer())
	
	local num = display.newSprite(PATH.."hero_nums.png")
	setAnchPos(num, 20, 310)
	layer:addChild(num)
	
	local n = table.nums(data)
	num = createLabel({str = n, x = 120, y = 310, color =ccc3(255,255,255)})
	layer:addChild(num)
	
	local scroll = KNScrollView:new(22, 330, 435, 250,2,true, 0, {priority = -132})
	layer:addChild(scroll:getLayer())
	
	for i = n, 1, -1 do
		local layer = display.newLayer()
--		local cardBg = display.newSprite(IMG_PATH.."image/scene/uplevel/card_bg.png")
--		layer:setContentSize(cardBg:getContentSize())
		layer:ignoreAnchorPointForPosition(false)
--		
--		setAnchPos(cardBg)
--		layer:addChild(cardBg)
--		
--		scroll:addChild(layer)
		local heroInfo = getConfig("general", data[i])
		heroInfo["cid"] = data[i]
		local card = KNBtn:new(IMG_PATH.."image/scene/uplevel/", {"card_bg.png"}, 0, 0, {
			front = getImageByType(data[i], "b"),
			frontScale = {0.6, 0,10},
			priority = -131,
			parent = scroll,
			other = {PATH.."name_bg.png", 20, 20},
			text = {getConfig("general", data[i], "name"), 18, ccc3(0x2c, 0, 0), ccp(0,-82)},
			callback = function()
				pushScene("detail" , {
						detail = "general",
						data = heroInfo
						})
			end
		})
		layer:setContentSize(CCSizeMake(card:getWidth(), card:getHeight()))
		layer:addChild(card:getLayer())
		
		local star
		for j = 1, getConfig("general", data[i], "star") do
			star = display.newSprite(COMMONPATH .. "star.png")
			setAnchPos(star, (card:getWidth() / 2 - (getConfig("general", data[i], "star") * star:getContentSize().width) / 2) + star:getContentSize().width * (j - 1), 190)
			
			layer:addChild(star)
		end
		scroll:addChild(layer)
	end
	scroll:alignCenter()
	
	self.mask = KNMask:new({item = layer})
	self.layer:addChild(self.mask:getLayer())
	
end


return FBLayer
