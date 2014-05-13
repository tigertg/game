local PATH = IMG_PATH .. "image/scene/detail/"
local SKILL_PATH = IMG_PATH .. "image/skill/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Petskill_Config = requires(IMG_PATH , "GameLuaScript/Config/Petskill")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")

--[[装备信息]]
local SkillDetail = {
	layer,
	params
}

function SkillDetail:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index = self

	this.layer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.params = params or {}
	
	local _data = params.data
	local pet_data = params.pet_data
	local skill_lv  = math.floor(pet_data.lv / 10) + 1
	if skill_lv > 10 then
		skill_lv = 10
	end
	
	local cid = tostring(_data["cid"])
	local config_data = Petskill_Config[cid]

	local bg_small = display.newSprite(COMMONPATH .. "bg_small.png")
	local bg = display.newSprite(PATH .. "bg.png")
	local big_icon = display.newSprite(getImageByType(cid , "b"))		-- 临时图片
	local big_icon_bg = display.newSprite(PATH .. "skill_bg.png")
	local name_label = display.strokeLabel( config_data["name"] , 65 , 660 , 24 ,DESCCOLOR)
	local lv_label = display.strokeLabel( "Lv" .. skill_lv , 230 , 660 , 18 ,DESCCOLOR)

	local split_sprite = display.newSprite(PATH .. "spilt.png")


	local title = display.newSprite(PATH .. "skill_info.png")
--
	local descText
	descText = display.strokeLabel( config_data["desc_1"] , 345 , 280 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
		dimensions_width = 110,
		dimensions_height = 400,
		align = 0,
	})
--	end


	setAnchPos(bg_small , 18 , 120)
	setAnchPos(bg , 33 , 345)
	setAnchPos(big_icon , 157 , 502)
	setAnchPos(big_icon_bg , 90 , 400)
	setAnchPos(title , 345 , 690)
	setAnchPos(split_sprite , 7 , 650)


	this.viewLayer:addChild(bg_small)
	this.viewLayer:addChild(bg)
	this.viewLayer:addChild(big_icon_bg)
	this.viewLayer:addChild(big_icon)
	this.viewLayer:addChild(name_label)
	this.viewLayer:addChild(lv_label)
	this.viewLayer:addChild(split_sprite)
	this.viewLayer:addChild(title)
	this.viewLayer:addChild(descText)


	local levelupText = display.strokeLabel( "幻兽每提升十级，技能可自动提升一级" , 50 , 370 , 16 , ccc3( 0x2c , 0x00 , 0x00 ))
	this.viewLayer:addChild(levelupText)


	-- 技能星星
	local temp
	local y = 570
	for i = 1, config_data["star"] do
		temp = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(temp , 303 , y)
		this.viewLayer:addChild(temp)
		y = y - 32
	end

	
	--当前效果
	local effect_bg = display.newSprite(PATH .. "effect_bg.png")
	local effect = display.newSprite(PATH .. "cur_pro.png")

	setAnchPos(effect_bg , 40 , 310)
	setAnchPos(effect , 45 , 312)

	this.viewLayer:addChild(effect_bg)
	this.viewLayer:addChild(effect)
	
	
	--下一阶效果
	effect_bg = display.newSprite(PATH .. "effect_bg.png")
	effect = display.newSprite(PATH .. "next_pro.png")

	setAnchPos(effect_bg , 40 , 225)
	setAnchPos(effect , 45 , 228)

	this.viewLayer:addChild(effect_bg)
	this.viewLayer:addChild(effect)
	

	-- 当前效果，和下一阶效果
	local next_lv
	if skill_lv < 10 then
		next_lv = skill_lv + 1
	end
	
	local content_cur , content_next

	content_cur = config_data[skill_lv .. ""]["desc"] 
	local descText = display.strokeLabel(content_cur, 45 , 255 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
			dimensions_width = 410,
			dimensions_height = 50,
			align = 0,
		})
	this.viewLayer:addChild(descText)
	
	print(next_lv)
	if next_lv ~= nil then
		content_next = config_data[next_lv .. ""]["desc"] 
	else
		content_next = "技能已到最高等级" 
	end
	descText = display.strokeLabel(content_next , 45 , 170 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
			dimensions_width = 410,
			dimensions_height = 50,
			align = 0,
		})
	this.viewLayer:addChild(descText)
	



	this.layer:addChild(this.viewLayer)
	return this
end



function SkillDetail:getLayer()
	return self.layer
end

function SkillDetail:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
	if self.params["parent"] then
		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end


return SkillDetail
