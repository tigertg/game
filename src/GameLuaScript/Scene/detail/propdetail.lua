local PATH = IMG_PATH .. "image/scene/detail/"
local PROP_PATH = IMG_PATH .. "image/prop/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config = requires(IMG_PATH , "GameLuaScript/Config/Prop")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local Stone = requires(IMG_PATH, "GameLuaScript/Config/data_stonefigure")

--[[道具信息]]
local PropDetail = {
	layer,
	params
}

function PropDetail:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index = self

	this.layer = display.newLayer()
	this.params = params or {}

	local pid = 0
	local _data = {}
	if params.id ~= nil then
		pid = params.id
		_data = DATA_Bag:get("prop" , pid)
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
	local name_label = display.strokeLabel( config_data["name"] , 65 , 660 , 24 , DESCCOLOR )
	local lv_label = nil
	if _data["lv"] then
		lv_label = display.strokeLabel( "Lv" .. _data["lv"] , 250 , 660 , 18 ,DESCCOLOR )
	end
	local split_sprite = display.newSprite(PATH .. "spilt.png")

	local effect_label, effect_next = nil
	if _data["type"] == "stone" then
		if _data["lv"] then
			effect_label = display.strokeLabel( Config_Property[_data["effect"]] .. " +".. Stone[_data["cid"]..""][_data["lv"]..""], 35 , 250 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
				dimensions_width = 300,
				dimensions_height = 30,
			})
			
			effect_next = display.strokeLabel( Config_Property[_data["effect"]] .. " +" ..(Stone[_data["cid"]..""][(_data["lv"] + 1)..""] or "max") , 35 , 190 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
				dimensions_width = 300,
				dimensions_height = 30,
			})
		end
	end

	
	local title = display.newSprite(PATH .. "prop_info.png")

	local descText = display.strokeLabel( config_data["desc"] , 350 , 360 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
		dimensions_width = 105,
		dimensions_height = 300,
		align = 0,
	})

	setAnchPos(bg_small , 18 , 120)
	setAnchPos(bg , 33 , 338)
	setAnchPos(big_icon , 85 , 400)
	setAnchPos(title , 345 , 673)
	setAnchPos(split_sprite , 7 , 650)


	this.layer:addChild(bg_small)
	this.layer:addChild(bg)
	this.layer:addChild(big_icon)
	this.layer:addChild(name_label)
	if lv_label ~= nil then this.layer:addChild(lv_label) end
	this.layer:addChild(split_sprite)
	this.layer:addChild(title)
	this.layer:addChild(descText)

	if effect_label ~= nil then
		--当前效果
		local effect_bg = display.newSprite(PATH .. "effect_bg.png")
		local effect = display.newSprite(PATH .. "cur_pro.png")

		setAnchPos(effect_bg , 40 , 295)
		setAnchPos(effect , 45 , 298)

		this.layer:addChild(effect_bg)
		this.layer:addChild(effect)
		
		--下一级效果
		effect_bg = display.newSprite(PATH .. "effect_bg.png")
		effect = display.newSprite(PATH .. "next_pro.png")

		setAnchPos(effect_bg , 40 , 225)
		setAnchPos(effect , 45 , 228)

		this.layer:addChild(effect_bg)
		this.layer:addChild(effect)
		

		this.layer:addChild(effect_label)
		this.layer:addChild(effect_next)
	end

	-- 按钮
	if pid ~= 0 then
		local useBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png" , "btn_bg_red_pre.png"} , 166 , 140 , {
			scale = true,
			front = COMMONPATH .. "use.png",
			callback = function()
				popScene()
				if params.propOpt then
					params.propOpt()
				end
			end
		}):getLayer()
		this.layer:addChild(useBtn)
	end
	
	--是否有附加详情说明
	if getConfig("prop", cid, "bagdesc2") then
		local effect_bg = display.newSprite(PATH .. "effect_bg.png")
		local effect = display.newSprite(PATH .. "prop_desc.png")

		setAnchPos(effect_bg , 35 , 295)
		setAnchPos(effect , 40 , 298)

		this.layer:addChild(effect_bg)
		this.layer:addChild(effect)
		
		local desc = display.strokeLabel(getConfig("prop", cid, "bagdesc2"), 25, 280, 16, ccc3(0x2c, 0, 0), nil, nil, {align = 0})
		setAnchPos(desc, 35, 290 - desc:getContentSize().height)
		this.layer:addChild(desc)
		
	end
	
	--如果商城中展示详情，则添加购买按钮
	if params.shopBuyFun then
		local optBtn = KNBtn:new(COMMONPATH , {"btn_bg_red.png", "btn_bg_red_pre.png"} , 166 , 140 , {
			front = COMMONPATH .. "buy.png",
			scale = true,
			callback = function() 
				params.shopBuyFun()
			end
		})

		this.layer:addChild(optBtn:getLayer())
	end


	return this
end

function PropDetail:getLayer()
	return self.layer
end

function PropDetail:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
	if self.params["parent"] then
		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end
return PropDetail
