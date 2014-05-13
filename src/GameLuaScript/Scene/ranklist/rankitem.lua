local PATH = IMG_PATH.."image/scene/ranklist/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local RankItem = { layer } 

function RankItem:new(kind,x, y, pos, parent)
	local this = {} 
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	
	local bg = display.newSprite(COMMONPATH.."item_bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	this.layer:setContentSize(bg:getContentSize())
	setAnchPos(this.layer, x, y)
	
	local text,y,x
	if pos < 4 then
		text = display.newSprite(PATH..pos..".png")
		x = 410
		y = 22
	else
		text = display.strokeLabel(pos.."", 0, 0, 48, ccc3(0xed, 0x17, 0x16))
		x = 410
		y = 30
	end
	setAnchPos(text, x, y, 1)
	this.layer:addChild(text)
	
--	local icon = display.newSprite(SCENECOMMON.."/logo.png")
--		setAnchPos(icon,17,24)
--	this.layer:addChild(icon)
--	
--	icon = display.newSprite(SCENECOMMON.."navigation/logo_bg.png")
--	setAnchPos(icon,15,20)
--	this.layer:addChild(icon)
	
	local icon = KNBtn:new(COMMONPATH , { "sex" .. DATA_Rank:get(kind, "list",pos, "sex") .. ".jpg"} , 17 , 24 , {
				front = COMMONPATH.."role_frame.png",
				scale = true , 
				parent = parent,
				callback = function()
					local uid = DATA_Rank:get(kind, "list",pos, "uid")
					if not uid  then
						switchScene("userinfo")
					else
						HTTP:call("profile","get",{ touid = uid },{success_callback = 
							function()
								local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
								display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
							end})
					end
				end
			}):getLayer()
	this.layer:addChild(icon)
	
	
	local name = display.strokeLabel(DATA_Rank:get(kind, "list",pos, "name"), 100, 10, 20,nil, nil, nil, {
		dimensions_width = 130,
		dimensions_height = 30
	})
	setAnchPos(name, 150, 40, 0.5)

	this.layer:addChild(name)
	
	local str
	if kind == "level" then
		str = "等级:"
	elseif kind == "athletics" then
		str = "连胜:"
	else
		str = "战力:"
	end
	name = display.strokeLabel(str..DATA_Rank:get(kind, "list", pos, "num"), 220, 45, 24,ccc3(0x2c,0x00,0x00))
	this.layer:addChild(name)
	
	return this

end

function RankItem:getLayer()
	return self.layer
end

function RankItem:getHeight()
	return self.layer:getContentSize().height
end

return RankItem