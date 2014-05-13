local MAIN, HERO, PET, SKILL, EQUIP = 0, 1, 2, 3, 4
local LEFT, RIGHT, TOP, BOTTOM = 1, 2, 3, 4
local PATH = IMG_PATH.."image/scene/pvp/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local KNMask = requires(IMG_PATH, "GameLuaScript/Common/KNMask")
local Progress = requires(IMG_PATH, "GameLuaScript/Common/KNProgress")
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local Property = requires(IMG_PATH, "GameLuaScript/Config/Property")
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local RobLayer = requires(IMG_PATH, "GameLuaScript/Scene/pvp/roblayer")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
--[[
	副本模块，在首页点击副本按钮进入此模块
]]
local PVPLayer = {
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

function PVPLayer:new(params)
	local this = {}
	setmetatable(this , self)
	self.__index = self
	params = params or {}

	this.layer = display.newLayer()
--	this.state = params.state 

	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 0, 425, 0, 0.5)
	this.layer:addChild(title)
--	
--	if params.state == "hero" then
----		HTTP:call("penglai", "get", {}, {
----			success_callback = function(data)
--				this:createHeroFb(params.data) 
----			end
----		})
--	elseif  params.state == "pet" then	
--		this:createPetFb()
--	elseif params.state == "skill" then
--		this:createSkillFb()
--	elseif params.state == "equip" then
--		if params.dig then
--			this:createDig(params.map)
--		else
--			this:createEquipFb(params.map)
--		end
	if params.state == "rob" then
		this:createRobFb(params.robData, params.star)
	else	
		this:createMain(params.coming)
	end	

	return this
end

function PVPLayer:createMain(name)
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
			if group:getId() == "diggings" then
				local check_result = checkOpened("diggings")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				HTTP:call("mining","get",{},{success_callback = 
					function(data)
						switchScene("diggings", data)
					end})
			elseif group:getId() == "athletics" then
				local check_result = checkOpened("athletics")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				HTTP:call("athletics","get",{},{success_callback = 
					function(data)
						switchScene("athletics",{data = data })	
					end})
			elseif group:getId() == "rob" then
				local check_result = checkOpened("fb_rob")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

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
		"athletics",
		"rob",
		"diggings",
	}
	local open_level = {
		"athletics",
		"fb_rob",
		"diggings",
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
				
				if checkOpened(open_level[i]) == true then
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

function PVPLayer:createContent(kind)
--	if self.contentLayer then
--		self.mainLayer:removeChild(self.contentLayer, true)
--	end	
--	
--	self.contentLayer = display.newLayer()
	
	local layer = display.newLayer()
	
	
	local bg = display.newSprite(PATH..kind.."_desc.png")
	setAnchPos(bg, 8, 160)
	layer:addChild(bg)

	local text = display.newSprite(PATH..kind.."_text.png")
	setAnchPos(text, 395, 390, 1)
	layer:addChild(text)
	
	local desc = {
		["rob"] = "秋高气爽出门晃晃，英雄武器口袋装装。\n 每天抢一抢，轻松获得英雄将魂武器碎片！",
		["diggings"] = " 每天可以挖矿6小时来获得大量银两。\n 还可以邀请比自己实力高的好友来保护。\n 巨矿、大矿、散矿在等着你哟~",
		["athletics"] = "演武之地英雄场，战斗切磋酣畅爽！\n竞技场不仅可以挑战众高手证明自己实力\n每天还可以额外领取银两奖励哦! "
		
	 }

   	
	text = display.strokeLabel(desc[kind], 0, 60, 20,nil,nil,nil,{
		dimensions_width = 400,
		dimensions_height = 100,
	} )
	layer:addChild(text)
	

	layer:setContentSize(CCSizeMake(405, 450))
	return layer
end



function PVPLayer:createRoleFb(kind)
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

function PVPLayer:getLayer()
	return self.layer
end

function PVPLayer:createInfo(title, func)
	if self.info then
		self.layer:removeChild(self.info:getLayer(), true)
	end
	self.info = InfoLayer:new("fb", 0, {tail_hide = true, title_text = title, closeCallback = func})
	self.layer:addChild(self.info:getLayer(),10)
end

function PVPLayer:createRobFb(data, star)
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


function PVPLayer:popCardList(data, new)
	
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

return PVPLayer
