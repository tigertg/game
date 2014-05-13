local PATH = IMG_PATH .. "image/scene/detail/"
local SKILL_PATH = IMG_PATH .. "image/skill/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Skill_Config = requires(IMG_PATH , "GameLuaScript/Config/Skill")
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
	
	local isOther =  params.isOther or false	--是否是他人信息展示
	local pid = 0
	local _data = {}
	if params.id ~= nil then
		pid = params.id
		_data = isOther and DATA_OTHER:getBag( "skill" , pid ) or DATA_Bag:get( "skill" , pid )
	elseif params.data ~= nil then
		_data = params.data
		pid = _data["id"]
	end

	pid = tonumber(pid)

	--[[
	local _data
	if params.montageData then
		_data = params.montageData 
	else
		_data = DATA_Bag:get( "skill" , pid )
	end
	]]
	
	local cid = tostring(_data["cid"])
	local skill_type = "skill"
	local config_data = Skill_Config[cid]
	if not tonumber(_data["lv"]) or tonumber(_data["lv"]) == 0 then
		_data["lv"] = 1
	end
	
	if config_data == nil then
		config_data = Petskill_Config[cid][_data["lv"] .. ""]
		skill_type = "petskill"
	end

	local bg_small = display.newSprite(COMMONPATH .. "bg_small.png")
	local bg = display.newSprite(PATH .. "bg.png")
	local big_icon = display.newSprite(getImageByType(cid , "b"))		-- 临时图片
	local big_icon_bg = display.newSprite(PATH .. "skill_bg.png")
	local name_label = display.strokeLabel( config_data["name"] , 65 , 660 , 24 ,DESCCOLOR)

	local lv_label = display.strokeLabel( "Lv" .. _data["lv"] , 250 , 660 , 18 , DESCCOLOR )
	local split_sprite = display.newSprite(PATH .. "spilt.png")

	local effect_label = nil
	if _data["effect"] ~= nil and _data["effect"] ~= "" and Config_Property[_data["effect"]] then
		effect_label = display.strokeLabel( Config_Property[_data["effect"]] .. " +" .. (_data["figure"] or "?") , 35 , 250 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
			dimensions_width = 300,
			dimensions_height = 30,
		})
	end


	local title = display.newSprite(PATH .. "skill_info.png")
--
	local descText
	descText = display.strokeLabel( config_data["desc2"] or  config_data["desc_1"] , 345 , 280 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
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
	
	if params.skillSeat == 1 then
		this.viewLayer:addChild(createLabel({str = "英雄每升10级，天生技能等级提升1级", x = 37, y = 360,size = 18, width = 350}))
	end

	-- 技能星星
	local temp
	local y = 570
	for i = 1, config_data["star"] do
		temp = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(temp , 303 , y)
		this.viewLayer:addChild(temp)
		y = y - 32
	end


	if effect_label ~= nil then
		local effect_bg = display.newSprite(PATH .. "effect_bg.png")
		local effect = display.newSprite(PATH .. "effect.png")

		setAnchPos(effect_bg , 20 , 235)
		setAnchPos(effect , 45 , 292)

		this.viewLayer:addChild(effect_bg)
		this.viewLayer:addChild(effect)

		this.viewLayer:addChild(effect_label)
	end


	--更换技能
	if pid ~= 0 then
		local changeSkillBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png" , "btn_bg_red_pre.png"} , 70 , 125 , {
			scale = true,
			front = PATH .. "change_skill.png",
			callback = function()
				if params.heroData then
					--从英雄页面传进 heroData
					local list
					list = SelectList:new("skill",this.viewLayer,display.newSprite(COMMONPATH .. "title/skill_text.png"),{ btn_opt = "equipment.png",target = true, equipType = _data.type ,
							y = 85 ,
							showTitle = true , 
							filter = "generalskill",
							optCallback = function()
								list:destroy()
								local targetId = list:getCurItem():getId()	
								--请求换装备
								HTTP:call("skill" , "dress", 
								{ id = params.heroData.id ,skill_id = targetId , pos = params.skillSeat } ,
								{success_callback= 
								function()
									switchScene("hero",{ gid = params.heroData.id})
								end})		
							end
							})
					this.layer:addChild(list:getLayer())
				end
				if params.petID then
					--从幻兽页面传进 heroData
					local list
					list = SelectList:new("skill",this.viewLayer,display.newSprite(COMMONPATH.."/title/skill_text.png"),{ btn_opt = "ok.png",target = true, equipType = _data.type ,
							y = 85 ,
							showTitle = true , 
							filter = "petskill",
							optCallback = function()
								list:destroy()
								local targetId = list:getCurItem():getId()	
								--请求换装备
								HTTP:call("skill" , "petskill_dress_new", 
								{ id = params.petID,skill_id = targetId , pos = params.skillSeat } ,
								{success_callback= 
								function()
--									switchScene("pet",{ gid = params.petID })
									params.changeOpt()
								end})		
							end
							})
					this.layer:addChild(list:getLayer())
				end
			end
		}):getLayer()
		this.viewLayer:addChild(changeSkillBtn)
		
		-- 升级按钮
		local upSkillBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png" , "btn_bg_red_pre.png"} , 270 , 125 , {
			scale = true,
			front = COMMONPATH .. "dunwu.png",
			callback = params.upOpt or function()
				if pid == 0 then
					KNMsg.getInstance():flashShow("该技能不可升级")
					return
				end
				
				
				local type_skill = getCidType(DATA_Bag:get("skill" , _data.id)["cid"])
				if type_skill == "skill" then
					--pushScene("strengthen" , { type = "strength_skill" , targetID = _data.id ,mode = "heroskill"})
					
					switchScene("strengthen", {gid = _data.id,mode = "heroskill",data = params.data,heroData = params.heroData,id = params.id,skillSeat = params.skillSeat,types = 1})
				else
					switchScene("strengthen", {gid = _data.id,mode = "petplainskill",data = params.data,filter = params.filter,id = params.id,petID = params.petID,skillSeat = params.skillSeat ,types = 1})
					--pushScene("strengthen" , { type = "strength_skill" , targetID = _data.id ,mode = "petplainskill"})
				end
					
			end
		}):getLayer()
		this.viewLayer:addChild(upSkillBtn)
		

		if params.heroData or params.petID then
			changeSkillBtn:setVisible(true)
			setAnchPos(upSkillBtn , 270 , 125)
		else
			changeSkillBtn:setVisible(false)
			setAnchPos(upSkillBtn , 170 , 125)
		end
		
		if isOther then
			changeSkillBtn:setVisible( false )
			upSkillBtn:setVisible( false )
		end
		
	 end
		 
		 
	--当前效果
	local effect_bg = display.newSprite(PATH .. "effect_bg.png")
	local effect = display.newSprite(PATH .. "cur_pro.png")

	setAnchPos(effect_bg , 40 , 310)
	setAnchPos(effect , 45 , 312)

	this.viewLayer:addChild(effect_bg)
	this.viewLayer:addChild(effect)
	
	
	--下一级效果
	effect_bg = display.newSprite(PATH .. "effect_bg.png")
	effect = display.newSprite(PATH .. "next_pro.png")

	setAnchPos(effect_bg , 40 , 225)
	setAnchPos(effect , 45 , 228)

	this.viewLayer:addChild(effect_bg)
	this.viewLayer:addChild(effect)
	
	local descText , content_cur , content_next
	content_cur =  config_data[_data["lv"]..""]["desc"]
	if config_data[(_data["lv"] + 1) .. ""] then
		content_next = config_data[(_data["lv"] + 1) .. ""]["desc"]
	else
		content_next = "技能已达到最高等级"
	end

	
	descText = display.strokeLabel(content_cur, 45 , 255 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
			dimensions_width = 410,
			dimensions_height = 50,
			align = 0,
		})
	this.viewLayer:addChild(descText)
	
	if content_next then
		descText = display.strokeLabel(content_next , 45 , 170 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
				dimensions_width = 410,
				dimensions_height = 50,
				align = 0,
			})
		this.viewLayer:addChild(descText)
	end
	



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