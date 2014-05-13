local PATH = IMG_PATH.."image/scene/pet/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local Config = requires(IMG_PATH,"GameLuaScript/Config/Pet")
local Config_Natural = requires(IMG_PATH , "GameLuaScript/Config/Petnatural")

--[[幻兽信息]]
local PetInfo = {
	layer,
	params
}

function PetInfo:new(layer_x , layer_y , width , height , params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	this.params = params or {}
	
	this.layer = display.newLayer()
	setAnchPos(this.layer , layer_x , layer_y )
	this.layer:setContentSize(CCSize:new(width,height))

	local petCard = KNBtn:new(IMG_PATH.."image/pet/", {"b_"..DATA_Bag:get("pet", params["id"],"cid")..".png"}, 0,-15, {
		parent = params.parent,
		upSelect = true,
		callback = function()	
			pushScene("detail" , {
				detail = "pet",
				id = params["id"],
			})
		end
	})

	local star = display.newSprite(COMMONPATH .. "star.png")
	setAnchPos(star , width - 50 , height - 100)


	this.layer:addChild(petCard:getLayer())
	this.layer:addChild(star)

	local pet_data = DATA_Bag:get("pet", params["id"])
	local cid = pet_data.cid
	local config_data = Config[cid]

	local function createPetPro(id)
		--英雄大于一
		local temp
		local y = height - 100 - star:getContentSize().height
		for i = 2, config_data["star"] do
			temp = display.newSprite(COMMONPATH .. "star.png")
			setAnchPos(temp, width - 50, y)
			this.layer:addChild(temp)
			y = y - star:getContentSize().height
		end
		
		local stage = pet_data.stage
		if stage > 0 then
			local img = display.newSprite(COMMONPATH .. "stage/" .. stage .. ".png")	
			setAnchPos(img, width - 50, y - 5)
			this.layer:addChild(img)
		end

		--姓名
		local name = CCLabelTTF:create( config_data.name , FONT , 24)
		name:setColor(DESCCOLOR)
		setAnchPos(name , 30 , 310)
		this.layer:addChild(name)

		-- 计算等级信息
		local lv , cur_exp , max_exp = DATA_Pet:calcExp(pet_data.exp)
		-- 等级
		local lvNode = display.strokeLabel( "Lv" .. lv , 150 , 310 , 22 ,DESCCOLOR )
		setAnchPos(lvNode , 230 , 310 , 1 , 0)
		this.layer:addChild( lvNode )

		-- 经验
		this.layer:addChild( KNBar:new("exp_general" , 35 , 555 , { maxValue = max_exp , curValue = cur_exp } ) )

		-- 攻击力
		local pet_lv_exp = getConfig("petlvexp" , tostring(lv))
		local atk_label = CCLabelTTF:create( "绝对伤害值：" .. pet_lv_exp["atk" .. config_data["star"]] , FONT , 18)
		atk_label:setColor(ccc3( 0x2c , 0x00 , 0x00 ))
		setAnchPos(atk_label , 35 , 270)
		this.layer:addChild(atk_label)

		-- 刷技能按钮
		local bg = {"btn_bg_grey.png"}
		local front = PATH.."refresh_skill.png"
		-- 进化按钮
		if config_data.star >= 4 then
			bg = {"btn_bg.png", "btn_bg_pre.png"}
			front = PATH.."refresh_skill.png"
		end
		local refresh_btn = KNBtn:new(COMMONPATH , bg , 240 , 0 , {
			front = front,
			callback = function()
				if config_data.star < 4 then
					KNMsg.getInstance():flashShow("四星及以上幻兽才可以刷新技能")
					return
				end

				switchScene("refreshpetskill" , {id = params["id"]})
				return false
			end
		})
		this.layer:addChild(refresh_btn:getLayer())
	end

	if params["id"] then
		createPetPro(params["id"])
	end

	return this
end

function PetInfo:getLayer()
	return self.layer
end

function PetInfo:getid()
	return self.params["id"]
end

function PetInfo:getRange()

	return CCRectMake(15 , 300 , 310 , 230)
end
return PetInfo
