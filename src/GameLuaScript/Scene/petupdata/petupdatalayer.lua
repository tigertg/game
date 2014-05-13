local PetInfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/petupdata/petupdatainfo")--require "GameLuaScript/Scene/pet/petlayer"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local PetUpdataLayer = {
	layer,
	array_id,
	updata_btn,
	stornieren
}

function PetUpdataLayer:new(id)
	print(gid)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.array_id = {}
	this.layer = display.newLayer()

	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)
	
	local box = display.newSprite(IMG_PATH.."image/common/bg_small.png")
	setAnchPos(box,(this.layer:getContentSize().width - box:getContentSize().width)/2,110)
	this.layer:addChild(box)
	
	local box = display.newSprite(IMG_PATH.."image/common/bg_img.png")
	setAnchPos(box,(this.layer:getContentSize().width - box:getContentSize().width)/2,300)
	this.layer:addChild(box)
	
	local box_font = display.newSprite(IMG_PATH.."image/scene/pet/title_font.png")
	setAnchPos(box_font,(this.layer:getContentSize().width - box_font:getContentSize().width)/2,698)
	this.layer:addChild(box_font)
	
	local small_box = display.newSprite(IMG_PATH.."image/scene/pet/small_box.png")
	setAnchPos(small_box,(this.layer:getContentSize().width - small_box:getContentSize().width)/2,170)
	this.layer:addChild(small_box)
	
	local small_box_font = display.newSprite(IMG_PATH.."image/scene/pet/consume.png")
	setAnchPos(small_box_font,50,270)
	this.layer:addChild(small_box_font)
	
	local old_box = display.newSprite(IMG_PATH.."image/scene/byexp/text_bg.png")
	setAnchPos(old_box,45,410)
	this.layer:addChild(old_box)
	
	local old_font = display.newSprite(IMG_PATH.."image/scene/pet/old_font.png")
	setAnchPos(old_font,45 + (old_box:getContentSize().width - old_font:getContentSize().width)/2,665)
	this.layer:addChild(old_font)
	
	local new_box = display.newSprite(IMG_PATH.."image/scene/byexp/text_bg.png")
	setAnchPos(new_box,255,410)
	this.layer:addChild(new_box)
	
	local new_font = display.newSprite(IMG_PATH.."image/scene/pet/new_font.png")
	setAnchPos(new_font,255 + (new_box:getContentSize().width - new_font:getContentSize().width)/2,665)
	this.layer:addChild(new_font)
	
	local arrow = display.newSprite(IMG_PATH.."image/scene/byexp/arrows.png")
	arrow:setRotation(180)
	setAnchPos(arrow,(this.layer:getContentSize().width - arrow:getContentSize().width)/2 + 40,570)
	this.layer:addChild(arrow)
	
	local info_box = display.newSprite(IMG_PATH.."image/scene/pet/infobox.png")
	setAnchPos(info_box,45 + (old_box:getContentSize().width - info_box:getContentSize().width)/2 ,380)
	this.layer:addChild(info_box)
	
	local info_box = display.newSprite(IMG_PATH.."image/scene/pet/infobox.png")
	setAnchPos(info_box,255 + (old_box:getContentSize().width - info_box:getContentSize().width)/2 ,380)
	this.layer:addChild(info_box)
	
	-- local info = display.newSprite(IMG_PATH.."image/scene/pet/info.png")
	-- setAnchPos(info,45 + (old_box:getContentSize().width - info:getContentSize().width)/2 ,310)
	-- this.layer:addChild(info)

	local info = display.newSprite(IMG_PATH.."image/scene/pet/lv_max.png")
	setAnchPos(info,45 + (old_box:getContentSize().width - info:getContentSize().width)/2 , 352)
	this.layer:addChild(info)

	local info = display.newSprite(IMG_PATH.."image/scene/pet/lv_max.png")
	setAnchPos(info,255 - 13 + (old_box:getContentSize().width - info:getContentSize().width)/2 , 352)
	this.layer:addChild(info)
	
	local info = display.newSprite(IMG_PATH.."image/scene/pet/info.png")
	setAnchPos(info,255 + (old_box:getContentSize().width - info:getContentSize().width)/2 ,308)
	this.layer:addChild(info)
	
	local old_pet1 = display.newSprite(IMG_PATH.."image/pet/b_"..DATA_Bag:get("pet",id)["cid"]..".png")
	old_pet1:setScale(0.8)
	setAnchPos(old_pet1,45 + (old_box:getContentSize().width - old_pet1:getContentSize().width*0.8)/2,410 + (old_box:getContentSize().height - old_pet1:getContentSize().height*0.8)/2)
	this.layer:addChild(old_pet1)
	
	local old_pet2 = display.newSprite(IMG_PATH.."image/pet/b_"..DATA_Bag:get("pet",id)["cid"]..".png")
	old_pet2:setScale(0.8)
	setAnchPos(old_pet2,255 + (old_box:getContentSize().width - old_pet2:getContentSize().width*0.8)/2,410 + (old_box:getContentSize().height - old_pet2:getContentSize().height*0.8)/2)
	this.layer:addChild(old_pet2)
	
	local info_layer = PetInfoLayer:new(id,this,old_box:getContentSize().width,old_box:getContentSize().height)
	this.layer:addChild(info_layer:getLayer())
	
	
	this.updata_btn = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 275,120 , {
		front = IMG_PATH.."image/scene/pet/updata.png",
		scale = true,
		noHide = true,
		callback = function()
			if next(this.array_id) ~= nil then
				HTTP:call("pet" , "upgrade" , {
					target = id,
					destroy = this.array_id[#this.array_id]
				} , {
					success_callback = function()
						KNMsg.getInstance():flashShow("幻兽进化成功")

						this.array_id = {}

						if info_layer ~= nil then
							this.layer:removeChild(info_layer:getLayer(),true)
						end
						
						info_layer = PetInfoLayer:new(id,this,old_box:getContentSize().width,old_box:getContentSize().height)
						this.layer:addChild(info_layer:getLayer())
					end
				})
			else
				KNMsg.getInstance():flashShow("点击选取进阶符")
			end
		end
	})
	this.layer:addChild(this.updata_btn:getLayer())
	
	
	this.stornieren = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 60,120 , {
		front = IMG_PATH.."image/common/cancel.png",
		scale = true,
		noHide = true,
		callback = function()
			if next(this.array_id) == nil then KNMsg.getInstance():flashShow("当前没有选中的幻兽!") end
			this.array_id = {}
			if info_layer ~= nil then
				this.layer:removeChild(info_layer:getLayer(),true)
				info_layer = PetInfoLayer:new(id,this,old_box:getContentSize().width,old_box:getContentSize().height)
				this.layer:addChild(info_layer:getLayer())
			else
				
				info_layer = PetInfoLayer:new(id,this,old_box:getContentSize().width,old_box:getContentSize().height)
				this.layer:addChild(info_layer:getLayer())
			end
		end
	})
	this.layer:addChild(this.stornieren:getLayer())
		
	return this.layer 
end

function PetUpdataLayer:getLayer()
	return self.layer
end
function PetUpdataLayer:set_array(id)
	self.array_id[#self.array_id + 1] = id
	dump(self.array_id)
end

function PetUpdataLayer:remove_array(id)
	for k,v in pairs(self.array_id) do
		if tonumber(v) == tonumber(id) then
			table.remove(self.array_id,k)
		end
	end
end

return PetUpdataLayer