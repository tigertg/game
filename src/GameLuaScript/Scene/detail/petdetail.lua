local PATH = IMG_PATH .. "image/scene/detail/"
local PET_PATH = IMG_PATH .. "image/pet/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config = requires(IMG_PATH , "GameLuaScript/Config/Pet")
local Config_Natural = requires(IMG_PATH , "GameLuaScript/Config/Petnatural")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local Config_PetStage = requires(IMG_PATH , "GameLuaScript/Config/petstageconfig")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local SCENECOMMON = IMG_PATH .. "image/scene/common/"

--[[宠物详情]]
local PetDetail = {
	layer,
	viewLayer,
	params
}

function PetDetail:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index = self

	this.layer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.params = params or {}

	local pid = 0
	local _data = {}
	if params.id ~= nil then
		pid = params.id
		_data = DATA_Bag:get("pet" , pid)
	elseif params.data ~= nil then
		_data = params.data
		pid = _data["id"]
	end

	pid = tonumber(pid)

	local cid = tostring(_data["cid"])
	local config_data = Config[cid]

	local bg_big = display.newSprite(COMMONPATH .. "bg_big.png")
	setAnchPos(bg_big , 18 , 108)	
	this.viewLayer:addChild(bg_big)
	
	local bg = display.newSprite(PATH .. "bg.png")
	setAnchPos(bg , 33 , 338)
	this.viewLayer:addChild(bg)
	
	local big_icon = display.newSprite(getImageByType(cid , "b"))
	setAnchPos(big_icon , 45 , 360)
	this.viewLayer:addChild(big_icon)
	

	local name_label = display.strokeLabel( config_data["name"] , 65 , 680 , 24 ,DESCCOLOR )
	this.viewLayer:addChild(name_label)


	-- 计算等级信息
	local lv , cur_exp , max_exp = DATA_Pet:calcExp(_data.exp or 0)

	_data["lv"] = lv
	local lv_label = display.strokeLabel( "Lv" .. _data["lv"] , 230 , 680 , 18 , DESCCOLOR )
	this.viewLayer:addChild(lv_label)


	local exp_bar = KNBar:new("exp_general" , 62 , 185 , {
		maxValue = max_exp,
		curValue = cur_exp,
	})
	exp_bar:setIsShowText(false)
	this.viewLayer:addChild(exp_bar)

	
	local title = display.newSprite(PATH .. "pet_info.png")
	setAnchPos(title , 345 , 687)
	this.viewLayer:addChild(title)
	
	local tipBg = display.newSprite(PATH.."pet_tip_bg.png")
	setAnchPos(tipBg, 240, 210, 0.5)
	this.viewLayer:addChild(tipBg)
	
	tipBg = display.newSprite(PATH.."pet_tip_text.png")
	setAnchPos(tipBg, 50, 280)
	this.viewLayer:addChild(tipBg)
	
	local maxLevel = display.newSprite(PATH.."max_level_text.png")
	setAnchPos(maxLevel, 50, 220)
	this.viewLayer:addChild(maxLevel)
	
	maxLevel = display.strokeLabel( (DATA_Bag:get("pet", params["id"], "stage") or 0) .."阶", 180, 253, 18, ccc3(0x2c, 0, 0))
	this.viewLayer:addChild(maxLevel)

	-- 攻击力
	local pet_lv_exp = getConfig("petlvexp" , tostring(_data["lv"]))
	local atk_label = display.strokeLabel( pet_lv_exp["atk" .. config_data["star"]] , 180, 223, 18, ccc3(0x2c, 0, 0))
	this.viewLayer:addChild(atk_label)
	
	local skillNum = display.newSprite(PATH.."a_p_skill_num.png")
	setAnchPos(skillNum, 250, 220)
	this.viewLayer:addChild(skillNum)
	
	local a_skill_num = 0
	if(isset(_data.skill , "a1")) then a_skill_num = a_skill_num + 1 end
	if(isset(_data.skill , "a2")) then a_skill_num = a_skill_num + 1 end
	if(isset(_data.skill , "a3")) then a_skill_num = a_skill_num + 1 end
	maxLevel = display.strokeLabel(a_skill_num .. "/3", 380, 254, 18, ccc3( 0x2c, 0, 0))
	this.viewLayer:addChild(maxLevel)
	
	local p_skill_num = 0
	if(isset(_data.skill , "p1")) then p_skill_num = p_skill_num + 1 end
	if(isset(_data.skill , "p2")) then p_skill_num = p_skill_num + 1 end
	if(isset(_data.skill , "p3")) then p_skill_num = p_skill_num + 1 end
	maxLevel = display.strokeLabel(p_skill_num .. "/3", 380, 223, 18, ccc3( 0x2c, 0, 0))
	this.viewLayer:addChild(maxLevel)


	local descText = display.strokeLabel( config_data["desc"] , 350 , 374 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x00 , 0x00 , 0x00 ) , {
		dimensions_width = 110,
		dimensions_height = 306,
		align = 0,
	})
	this.viewLayer:addChild(descText)

	-- 幻兽星星
	local temp
	local y = 600
	for i = 1, config_data["star"] do
		temp = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(temp , 303 , y)
		this.viewLayer:addChild(temp)
		y = y - 32
	end

	local stage = DATA_Bag:get("pet", params["id"], "stage") or 0
	if stage > 0 then
		local img = display.newSprite(COMMONPATH.."stage/"..stage..".png")	
		setAnchPos(img, 300 , y - 8)
		this.viewLayer:addChild(img)
	end

	-- 计算下次升阶所需等级
	local next_stage_lv = Config_PetStage[config_data["star"]] 
	if config_data["star"] >= 3 and next_stage_lv then
		local next_stage_lv_label = display.strokeLabel( "下次升阶所需等级：" .. next_stage_lv , 90 , 350 , 18, ccc3(0x2c, 0, 0))
		this.viewLayer:addChild(next_stage_lv_label)
	end

	local stage_config = Config_PetStage[config_data.star .. ""]
	local max_lv = math.min( 100 , stage_config.initial_lv + (stage_config.lvadd * stage_config.max_stage) )
	local max_lv_text = display.strokeLabel( "当前星级幻兽最高可升级至：" .. max_lv , 125 , 175 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) )
	this.viewLayer:addChild(max_lv_text)

	-- 按钮
	if pid ~= 0 then
		local btn_img = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		local btn_front = COMMONPATH .. "uppet.png" 
		local stage = DATA_Bag:get("pet", pid, "stage")
		local btn = KNBtn:new(COMMONPATH , btn_img , 170 , 120 , {
			front = btn_front,
			callback = function() 
				if config_data["star"] < 3 then
					KNMsg.getInstance():flashShow("只有三星以上幻兽能进化")
					return false
				elseif not isset(Config_PetStage , tostring(stage + 1)) then
					KNMsg.getInstance():flashShow("幻兽已进化到最高阶")
					return false
				end
				switchScene("petupdata" , pid)
			end
		})	
		this.viewLayer:addChild(btn:getLayer())
	end


	this.layer:addChild( this.viewLayer )

	return this
end

function PetDetail:getLayer()
	return self.layer
end

function PetDetail:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
	if self.params["parent"] then
		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end


return PetDetail

