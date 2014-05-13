local Mosaiclayer = {layer}
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
--[[镶嵌]]
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/mosaiclist/mosaiclistInfo")--镶嵌
function Mosaiclayer:new(x,y,parm)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	local gid = parm.gid
	
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)
	--[[local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,y)
	this.layer:addChild(bg)
	
	local context_bg = display.newSprite(IMG_PATH.."image/common/list_bg.png")
	setAnchPos(context_bg,15,87)
	this.layer:addChild(context_bg)
	
	local title = display.newSprite(IMG_PATH.."image/common/list_title.png")
	setAnchPos(title,15+(context_bg:getContentSize().width - title:getContentSize().width)/2,80+context_bg:getContentSize().height)
	this.layer:addChild(title)
	
	
	
	local close = KNBtn:new(IMG_PATH .. "image/common" , {"close.png"} , 15+(context_bg:getContentSize().width )-50,70+context_bg:getContentSize().height , {
		upSelect = true,
		noHide = true,
		callback = function()
			switchScene("pulse",gid)
		end
	})
	this.layer:addChild(close:getLayer())
	
	local title_font = display.newSprite(IMG_PATH.."image/common/title/stone_text.png")
	setAnchPos(title_font,15+(context_bg:getContentSize().width - title_font:getContentSize().width)/2,85+context_bg:getContentSize().height)
	this.layer:addChild(title_font)
	]]
	
	local mosai_data = DATA_Bag:getTable("prop")--DATA_Bag:get("prop",index , key)--BagLayer:getDataFile("prop")
	local y_select = 104
	local sv = KNScrollView:new(16,98,450,660,10,false)	
	for k,v in pairs(mosai_data) do
		if v["type"] == "stone" then
			local info = infoLayer:new(v,0,70,{gid = parm.gid,index = parm.index},{ callback = function(thiscard)  end})
			sv:addChild(info:getLayer(),info)
		end
	end
	this.layer:addChild(sv:getLayer())
	--[[if parm.mode == 1 then
		--镶嵌
		
	elseif parm.mode == 2 then]]
		--升级
		--[[local title_font = display.newSprite(IMG_PATH.."image/common/title/Sehnen.png")
		setAnchPos(title_font,15+(context_bg:getContentSize().width - title_font:getContentSize().width)/2,85+context_bg:getContentSize().height)
		this.layer:addChild(title_font)
		local info = chipLayer:new(0,70,{gid = parm.gid,index = parm.index,mode = parm.mode})
		this.layer:addChild(info:getLayer())]]
	--end
	
return this
end

function Mosaiclayer:getLayer()
	return self.layer
end

return Mosaiclayer
