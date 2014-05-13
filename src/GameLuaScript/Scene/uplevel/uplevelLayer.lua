--[[

		升阶界面

]]

local PATH = IMG_PATH .. "image/scene/uplevel/"
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local BagItem = requires(IMG_PATH , "GameLuaScript/Scene/common/listitem")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")


local M = {
	baseLayer,
	layer,
	upLayer
}

function M:new( params )
local this = {}
	setmetatable(this , self)
	self.__index = self
	if params then
		if params.target then
			this.target = params.target
		end
	end
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.curInfo = {}
	this.nextInfo = {}

	local bg = display.newSprite(PATH.."bg.png")
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	
	--警告信息
	local warningInfo = display.newSprite(PATH.."warningInfo.png")
	--进化前
	local acceptTitle = display.newSprite(PATH.."accept.png")
	--进化后
	local impartTitle = display.newSprite(PATH.."impart.png")
	--箭头
	local arrows = display.newSprite(PATH.."arrow.png")
	
	local isMax = (this.target.lv == (DATA_Uplevel:get(this.target.star.."")["initial_lv"] + this.target.stage * DATA_Uplevel:get(this.target.star.."")["lvadd"]))
	
	
	local baseY = 438
	setAnchPos(title , 0 , 420 , 0 , 0.5 )
	setAnchPos(bg, 240, 410, 0.5, 0.5)
	
	setAnchPos(warningInfo , display.cx  , baseY + 255 , 0.5 , 0.5 )
	setAnchPos(acceptTitle , 84 , 420 )
	setAnchPos(impartTitle , 335 , 420 )
	setAnchPos(arrows , display.cx + 5  , display.cy - 80 , 0.5 , 0.5 )
	
	this.layer:addChild(title)
	this.layer:addChild(bg)
	this.layer:addChild(warningInfo)
	this.layer:addChild(acceptTitle)
	this.layer:addChild(impartTitle)
	this.layer:addChild(arrows)
	
	for i = 1, 2 do
		local pb = display.newSprite(PATH.."property_bg.png")
		setAnchPos(pb, 35 + (i - 1) * 230, 280)
		this.layer:addChild(pb)
	end
	
	local use = display.newSprite(PATH.."use_bg.png")
	setAnchPos(use, 10, 160)
	this.layer:addChild(use)
	
	use = display.newSprite(PATH.."use.png")
	setAnchPos(use,50,250)
	this.layer:addChild(use)
		
	this:refresh(isMax)
	
	local legal, bg, front
	if isMax then
		bg = {"btn_bg_red.png", "btn_bg_red.png"}
		front =  COMMONPATH .. "uppet.png"
	else
		bg = {"btn_bg_red2.png"}
		front = COMMONPATH.."uppet_grey.png"
	end
	
	--升阶按钮
	local conveyingBtn = KNBtn:new(COMMONPATH,bg,168,119,{scale = true,
		front = front, callback=
		function()
				if not isMax then
					KNMsg.getInstance():flashShow("英雄未达到进化等级， 请继续努力吧!~")
					return false
				end
				
				if not this.source  then
					KNMsg.getInstance():flashShow("请选择消耗的进化符")
					return false
				end
				HTTP:call("general","upgrade",{
					id = this.target.id  , 
					destroy = this.source , 
				},{success_callback=
					function()
						this.target = nil
						this.source = nil
						switchScene("hero",{gid = params.target.id}, function()
							KNMsg.getInstance():flashShow("恭喜您，英雄成功进化到"..DATA_Bag:get("general", params.target.id, "stage").."阶，最大等级上限提升！~")
						end)
					end})
		end})
	this.layer:addChild(conveyingBtn:getLayer())
	
	
	this.baseLayer:addChild( this.layer )
	return this.baseLayer
end

--刷新界面
function M:refresh(isMax)
	if self.acceptBtn then
		self.acceptBtn:removeFromParentAndCleanup( true )
	end
	
	self.acceptBtn = self:createHeroSeat(self.target, isMax)
	self.layer:addChild(self.acceptBtn)
	
	
end

--生成英雄位
function M:createHeroSeat( _data, isMax)
	local data = _data
	local tempBtn
	
	if self.upLayer then
		self.layer:removeChild(self.upLayer,true)
	end
	self.upLayer = display.newLayer()

	--生成参数
	local function createParams()
		local params
			params = { 
				frontScale = { 0.78, 0, -10 } , 
				front = data and getImageByType(data.cid , "b") or nil}
		return params
	end
	
	tempBtn = KNBtn:new(PATH , {"card_bg.png"} , 155 , 440 , createParams() ) 
	self.upLayer:addChild(tempBtn:getLayer())
	
	local star = self.target.star 
	local img
	local w
	for i = 1, star do
		img = display.newSprite(COMMONPATH.."star.png")
		img:setScale(0.75)
		w = img:getContentSize().width * 0.75
--		setAnchPos(img, 20 + (i - 1) * 20, 195, 0.5)
		setAnchPos(img, 255 - (w * star) / 2 + (i - 1) * 20, 635)
		self.upLayer:addChild(img,1)
	end
	
	--进化前
	--等级
	local text = display.strokeLabel((self.target.lv.."/"..DATA_Uplevel:get(star.."")["initial_lv"] + self.target.stage * DATA_Uplevel:get(star.."")["lvadd"]) , 90, 390, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--攻
	text = display.strokeLabel(self.target.atk, 90, 355, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--血
	text = display.strokeLabel(self.target.hp, 175, 355, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--防
	text = display.strokeLabel(self.target.def, 90, 320, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--敏
	text = display.strokeLabel(self.target.agi, 175, 320, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--槽位
	local num =1 + math.floor(self.target.stage / DATA_Uplevel:get(star.."")["pulseadd"])
	num = (num > DATA_Uplevel:get(star.."")["pulse_max"]) and DATA_Uplevel:get(star.."")["pulse_max"] or num
	text = display.strokeLabel(num, 140, 290, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text)
	
	
	if self.target.stage > 0 then
		text = display.newSprite(COMMONPATH.."stage/"..self.target.stage..".png")
		setAnchPos(text,180, 385)
		self.upLayer:addChild(text)
	end
	
	--进化后
	--等级
	text = display.strokeLabel(self.target.lv.."/"..(DATA_Uplevel:get(star.."")["initial_lv"] + (self.target.stage + 1) * DATA_Uplevel:get(star.."")["lvadd"]) , 320, 390, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--攻
	text = display.strokeLabel(self.target.atk + DATA_Uplevel:get(star.."")["atk"], 320, 355, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--血
	text = display.strokeLabel(self.target.hp + DATA_Uplevel:get(star.."")["hp"], 405, 355, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--防
	text = display.strokeLabel(self.target.def + DATA_Uplevel:get(star.."")["def"], 320, 320, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	--敏
	text = display.strokeLabel(self.target.agi + DATA_Uplevel:get(star.."")["agi"], 405, 320, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text,1)
	
	num = 1 + math.floor((self.target.stage + 1) / DATA_Uplevel:get(star.."")["pulseadd"])
	num = (num > DATA_Uplevel:get(star.."")["pulse_max"]) and DATA_Uplevel:get(star.."")["pulse_max"] or num
	
	text = display.strokeLabel(num, 360, 290, 18, ccc3(0x2c, 0, 0))
	self.upLayer:addChild(text)
	
	
	
	
	if self.target.stage then
		text = display.newSprite(COMMONPATH.."stage/"..(self.target.stage + 1)..".png")
		setAnchPos(text,410, 385)
		self.upLayer:addChild(text)
	end
	
	
	local front, text
	if self.source then
		front = getImageByType(DATA_Bag:get("prop", self.source, "cid"), "s")
		text = {DATA_Bag:get("prop", self.source, "name"), 18, ccc3(0x2c, 0, 0), ccp(100,10)}
		
		local starImg
		for i = 1, star do
			starImg = display.newSprite(COMMONPATH .. "star.png")
			setAnchPos(starImg, 220 + (i - 1) * starImg:getContentSize().width, 185)
			self.upLayer:addChild(starImg)
		end
	else
		text = {"点击选择消耗的进化符", 18, ccc3(0x2c, 0, 0), ccp(130,0)}
	end
	local useHero = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, 150, 185, {
		scale = true,
		front = front,
		text = text,
		callback = function()
			if not isMax then
				--KNMsg.getInstance():flashShow("英雄未达到进化等级， 请继续努力吧!~")
				--return false
			end
			
			if DATA_Bag:countItems("prop", false, {type = "herojinhuafu", star = star}) < 1 then
				KNMsg.getInstance():flashShow("没有相应进化符，您可以前往进化池中打造")
				return false
			end
				
			local list 
			list = SelectList:new("prop",nil,nil,{ btn_opt = "ok.png", 
			filter = {star = star, type = "herojinhuafu"},
			generalType = "uplevel2",
			optCallback = function()
				self.source = list:getCurItem():getId()
				list:destroy()
				self.layer:addChild(self:createHeroSeat(_data, isMax))
			end})
			self.layer:addChild(list:getLayer())
			
		end
	})
	self.upLayer:addChild(useHero:getLayer())
	
	return self.upLayer
end

return M
