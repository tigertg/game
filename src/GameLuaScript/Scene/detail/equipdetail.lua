local PATH = IMG_PATH .. "image/scene/detail/"
local EQUIP_PATH = IMG_PATH .. "image/equip/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config = requires(IMG_PATH , "GameLuaScript/Config/Equip")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local Config_max = requires(IMG_PATH , "GameLuaScript/Config/equipstrongmax")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")
local GroupConf = requires(IMG_PATH, "GameLuaScript/Config/equipgroup")

--[[装备信息]]
local EquipDetail = {
	layer,
	params
}

function EquipDetail:new(params)
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
		_data = isOther and DATA_OTHER:getBag( "equip" , pid ) or DATA_Bag:get("equip" , pid)
	elseif params.data ~= nil then
		_data = params.data
		pid = _data["id"]
	end

	pid = tonumber(pid)

	local cid = tostring(_data["cid"])
	local config_data = Config[cid]


	local bg_small = display.newSprite(COMMONPATH .. "bg_small.png")
	local bg = display.newSprite(PATH .. "bg.png")
	local big_icon = display.newSprite(getImageByType(cid , "b"))
	local maxLv = createLabel({str = "当前品质装备最高强化到"..Config_max[config_data["star"]]["levmax"].."级", width = 300})
	
	local name_label = display.strokeLabel( config_data["name"] , 65 , 660 , 24 ,DESCCOLOR )
	_data["lv"] = _data["lv"] or 1
	local lv_label = display.strokeLabel( "Lv" .. _data["lv"] , 250 , 660 , 18 ,DESCCOLOR )
	local split_sprite = display.newSprite(PATH .. "spilt.png")

	local effect_label = nil
	local str, proName
	
	if _data["effect"] ~= nil and _data["effect"] ~= "" then
		proName = Config_Property[_data["effect"]] 
		 str =  proName .. " +" .. (_data["figure"] or "")
	else
		if _data["type"] then
			if _data["type"] == "weapon" then
				proName = "攻击 "
			elseif _data["type"] == "defender" then
				proName = "防御 "
			elseif _data["type"] == "jewelry" then
				proName = "生命 "
			elseif _data["type"] == "shoe" then
				proName = "敏捷 "
			end
			str = proName.."+".._data["initial"]
		end			
	end
	
	if str then
		effect_label = display.strokeLabel(str , 35 , 250 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
			dimensions_width = 300,
			dimensions_height = 30,
		})
	end

	local title = display.newSprite(PATH .. "equip_info.png")

	local descText = display.strokeLabel( config_data["desc"] , 350 , 360 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
		dimensions_width = 105,
		dimensions_height = 300,
		align = 0,
	})


	setAnchPos(bg_small , 18 , 120)
	setAnchPos(bg , 33 , 338)
	setAnchPos(big_icon , 110 , 450)
	setAnchPos(maxLv, 185, 620, 0.5)	
	setAnchPos(title , 345 , 673)
	setAnchPos(split_sprite , 7 , 650)


	this.viewLayer:addChild(bg_small)
	this.viewLayer:addChild(bg)
	this.viewLayer:addChild(big_icon)
	this.viewLayer:addChild(maxLv)
	this.viewLayer:addChild(name_label)
	this.viewLayer:addChild(lv_label)
	this.viewLayer:addChild(split_sprite)
	this.viewLayer:addChild(title)
	this.viewLayer:addChild(descText)

	-- 装备星星
	local temp
	local y = 550
	for i = 1, config_data["star"] do
		temp = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(temp , 303 , y)
		this.viewLayer:addChild(temp)
		y = y - 32
	end
	
	--套装属性
	if config_data.group ~= 0 then
		local group_text = display.newSprite(PATH.."group_list.png")
		setAnchPos(group_text, 60, 420)
		this.viewLayer:addChild(group_text)
		
		local info = GroupConf[config_data.group]
		local count = 1
		local x, y = 80, 400
		--套装信息
		local list
		for k, v in pairs(info.condition) do
			local use, items = self:checkActive(pid, v, info.condition)
			list = items
			
			local active = display.newSprite(COMMONPATH..(use and "tianfu_1.png" or "tianfu_2.png"))
			setAnchPos(active, x - active:getContentSize().width - 5, y)
			this.viewLayer:addChild(active)
			
			this.viewLayer:addChild(createLabel({str = getConfig("equip", v, "name"), x = x, y = y, size = 16, color = (use and ccc3(255,0,0) or nil)}))
			x = x + 120
			if count % 2 == 0 then
				x = 80
				y = y - 25 
			end
			count = count + 1
		end
		
		--属性加成
		count = 0
		local key = {}
		for k, v in pairs(info.result) do
			for sk, sv in pairs(v) do
				if table.hasValue(key, sk) then
					
				else
					table.insert(key, sk)
					this.viewLayer:addChild(createLabel({str = "("..k.."件)"..Config_Property[sk].."+"..sv, x = x, y = y, size = 14,width = 200, color = (#list >= k and ccc3(255,0,0) or nil) }))
					x = x + 120
				end
			end
		end
		
	end


	if effect_label ~= nil then
		local effect_bg = display.newSprite(PATH .. "effect_bg.png")
		local effect = display.newSprite(PATH .. "effect.png")

		setAnchPos(effect_bg , 40 , 295)
		setAnchPos(effect , 45 , 298)

		this.viewLayer:addChild(effect_bg)
		this.viewLayer:addChild(effect)

		this.viewLayer:addChild(effect_label)
		
		effect_bg = display.newSprite(PATH .. "effect_bg.png")
		effect = display.newSprite(PATH .. "append.png")

		setAnchPos(effect_bg , 40 , 225)
		setAnchPos(effect , 45 , 228)

		this.viewLayer:addChild(effect_bg)
		this.viewLayer:addChild(effect)
		
		
		local role = {"人杰","鬼雄","英豪"}
		--查看他人时 自己背包中不存在pid，就报错，所以，屏蔽加成
		local appendText = display.strokeLabel(getConfig("equip", cid, "apstar").."星【"..role[getConfig("equip", cid, "apstype")].."】穿戴:附加"..proName.."+"..getConfig("equip", cid,"apinit"), 80, 198, 18, ccc3(0x2c, 0 , 0))
		this.viewLayer:addChild(appendText)
		
		
		local activeImg = COMMONPATH.."tianfu_2.png"
		
		if pid and checkActive("equip", {id = pid, cid = cid}) then
			activeImg = COMMONPATH.."tianfu_1.png"
			appendText:setColor(ccc3(255, 0, 0))
		end
		
		local appendImg = display.newSprite(activeImg)
		setAnchPos(appendImg, 60, 200)
		this.viewLayer:addChild(appendImg)
	end

	-- 按钮
	if pid ~= 0 then
		local useBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png","btn_bg_red_pre.png" } , 70 , 140 , {
			scale = true,
			front = COMMONPATH .. "change_equip.png",
			callback = function()
				if params.heroData then
					--从英雄页面传进 heroData
					local list
					local tempTypeAry = { weapon = 1 , defender = 2 , shoe = 3 , jewelry = 4 }	--装备四个位置
					list = SelectList:new("equip" , this.viewLayer,display.newSprite(COMMONPATH .. "title/equip_text.png") , {
						btn_opt = "equipment.png",
						target = true,
						filter = _data.type,
						equipType = _data.type,
						y = 85 ,
						showTitle = true , 
						optCallback = function()
							list:destroy()
							local targetId = list:getCurItem():getId()
							--请求换装备
							HTTP:call("equip" , "dress", {
								gid = params.heroData.id ,
								eid = targetId ,
								pos = "e" .. tempTypeAry[ _data.type ]
							} , {
								success_callback = function(_data)
									switchScene("hero" , { gid = params.heroData.id } , function()
										local equip_info = DATA_Bag:get("equip" , targetId)

										KNMsg:getInstance():flashShow( equip_info["name"] .. "装备成功，" .. Config_Property[equip_info["effect"]] .. "增加" .. equip_info["figure"])
									end)
								end
							})
						end
					})

					this.layer:addChild(list:getLayer())	
				end
			end
		}):getLayer()
		this.viewLayer:addChild(useBtn)
		

		local btn_bg = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		local btn_front = "strengthen.png"
		if checkOpened("equip_strenthen") ~= true then
			btn_bg = {"btn_bg_red2.png"}
			btn_front = "strengthen_grey.png"
		end

		local strengthBtn = KNBtn:new(COMMONPATH, btn_bg , 270 , 140 , {
			scale = true,
			front = COMMONPATH .. btn_front,
			callback = function()
				-- 判断等级开放
				local check_result = checkOpened("equip_strenthen")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				if pid == 0 then
					KNMsg.getInstance():flashShow("该装备不能强化")
					return
				end
				
				pushScene("strengthen",{ type = "strength_equip" , targetID = pid, main = params.main}) 
			end
		}):getLayer()
		this.viewLayer:addChild(strengthBtn)
		
		
		if params.heroData then
			useBtn:setVisible(true)
			setAnchPos(strengthBtn , 270 , 140)
		else
			useBtn:setVisible(false)
			setAnchPos(strengthBtn , 170 , 140)
		end
		
		if isOther then
			strengthBtn:setVisible( false )
			useBtn:setVisible( false )
		end
		
	
		-- 新手引导
		local guide_step = KNGuide:getStep()
		if guide_step == 204 then KNGuide:show( strengthBtn ) end
	end
	
	this.layer:addChild(this.viewLayer)
	return this
end



function EquipDetail:getLayer()
	return self.layer
end

function EquipDetail:checkActive(eid, cid, info)
    local roleId = DATA_ROLE_SKILL_EQUIP:getRoleId(eid, "equip")
	if not roleId then
		return false, {}
	end
	
	local active = false
	local list = {}
	local data = DATA_ROLE_SKILL_EQUIP:get(roleId)
	for k, v in pairs(data) do
		if string.find(k, "e") then
			if not active then
				if cid.."" == v.cid.."" then
					active = true
					table.insert(list, v.cid)
				else
					for sk, sv in pairs(info) do
						if sv.."" == v.cid.."" then
							table.insert(list, sv.."")
						end
					end
				end
			else
				for sk, sv in pairs(info) do
					if sv.."" == v.cid.."" then
						table.insert(list, sv.."")
					end
				end
			end
		end
	end
	
	return active, list
end

function EquipDetail:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
	if self.params["parent"] then
		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end


return EquipDetail
