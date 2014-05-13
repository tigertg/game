local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")
local Pet_Config = requires(IMG_PATH,"GameLuaScript/Config/Pet")
local Pet_Stage_Config = requires(IMG_PATH,"GameLuaScript/Config/petstageconfig")

--[[幻兽信息]]
local PetUpdataInfo = {
	layer,
	showLayer,
	source
}

function PetUpdataInfo:new(id,updata,width,height)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	this.id = id
	this.petupdata = updata
	this.layer = display.newLayer()
	local data = DATA_Pet:getTable() 
	local stage = DATA_Bag:get("pet",id)["stage"]
	local pet_cid = DATA_Bag:get("pet",id)["cid"]
	local star = getConfig("pet", pet_cid, "star")
	if stage == 0 then
	
	else 
		local icon_old = display.newSprite(IMG_PATH.."image/common/stage/"..stage..".png")
		setAnchPos(icon_old,45 + width - 37 ,410 + height - 35)
		this.layer:addChild(icon_old)
	end
	
	local icon_new = display.newSprite(IMG_PATH.."image/common/stage/"..(stage + 1)..".png")
	setAnchPos(icon_new,255 + width - 37 ,410 + height - 35)
	this.layer:addChild(icon_new)
	
	local old_stage_font = display.strokeLabel( stage.."阶" , 45 + (width - 123)/2 + 45,380 , 22 , ccc3( 0xff , 0xff , 0xff ) )
	this.layer:addChild( old_stage_font )
	
	local new_stage_font = display.strokeLabel( (stage + 1).."阶" , 255 + (width - 123)/2 + 45,380 , 22 , ccc3( 0xff , 0xff , 0xff ) )
	this.layer:addChild( new_stage_font )
	
	
	local stage_data = Pet_Stage_Config[star..""] or nil
	if stage_data ~= nil then
		local old_font1 = display.strokeLabel( stage_data["initial_lv"] + stage_data["lvadd"] * stage , 45 + 155 ,351 , 20 , ccc3( 0xac , 0x25 , 0x10 ) )
		this.layer:addChild( old_font1 )
		
		local new_font1 = display.strokeLabel( stage_data["initial_lv"] + stage_data["lvadd"] * (stage + 1) , 255 + 140 ,351 , 20 , ccc3( 0xac , 0x25 , 0x10 ) )
		this.layer:addChild( new_font1 )
	end

	
	local pet_data = DATA_Bag:get("pet")
	local config_data = Pet_Config[pet_cid]


	local select_btn
	function create_obj()
		if this.showLayer then
			this.layer:removeChild(this.showLayer , true)
		end
		this.showLayer = display.newLayer()
		this.layer:addChild(this.showLayer)
		

		if select_btn ~= nil then
			this.layer:removeChild(select_btn:getLayer() , true)
		end

		local front , text
		if this.source then
			front = getImageByType(DATA_Bag:get("prop", this.source, "cid"), "s")
			text = {DATA_Bag:get("prop", this.source, "name"), 18, ccc3(0x2c, 0, 0), ccp(100,10)}
			

			local starImg
			for i = 1, config_data.star do
				starImg = display.newSprite(COMMONPATH .. "star.png")
				setAnchPos(starImg, 220 + (i - 1) * starImg:getContentSize().width, 200)
				this.showLayer:addChild(starImg)
			end
		else
			text = {"点击选择消耗的进化符", 18, ccc3(0x2c, 0, 0), ccp(130,0)}
		end

		select_btn = KNBtn:new(IMG_PATH .. "image/scene/common" , {"skill_frame2.png"} , 150 , 200 , {
			front = front,
			text = text,
			scale = true,
			noHide = true,
			callback = function()
				if DATA_Bag:countItems("prop", false, {type = "petjinhuafu", star = star}) < 1 then
					KNMsg.getInstance():flashShow("没有相应进化符，您可以前往进化池中打造")
					return false
				end
				
				this.petupdata.updata_btn:setEnable(false)
				this.petupdata.stornieren:setEnable(false)
				this.petupdata.updata_btn:showBtn(false)
				this.petupdata.stornieren:showBtn(false)

				local list
				list = SelectList:new("prop" , nil , nil , {
					btn_opt = "ok.png", 
					filter = {star = config_data.star , type = "petjinhuafu"},
					target = true,
					closeCallback = function()
						this.petupdata.updata_btn:setEnable(true)
						this.petupdata.stornieren:setEnable(true)
						this.petupdata.updata_btn:showBtn(true)
						this.petupdata.stornieren:showBtn(true)
						list:destroy()
					end,
					optCallback = function()
						this.source = list:getCurItem():getId()
						this.petupdata:set_array(list:getCurItem():getId())
						this.petupdata.updata_btn:setEnable(true)
						this.petupdata.stornieren:setEnable(true)
						this.petupdata.updata_btn:showBtn(true)
						this.petupdata.stornieren:showBtn(true)
						list:destroy()
						
						create_obj()
					end
				})
				
				this.layer:addChild(list:getLayer())
				
			end
		})
		this.layer:addChild(select_btn:getLayer())
	end
	
	create_obj()
	
	return this
end

function PetUpdataInfo:getLayer()
	return self.layer
end


return PetUpdataInfo
