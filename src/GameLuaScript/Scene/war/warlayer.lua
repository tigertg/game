local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local PATH = IMG_PATH.."image/scene/war/"
local Mgr = requires(IMG_PATH, "GameLuaScript/Scene/war/mapmgr")

local WarLayer = {
	baseLayer,
	layer,
	mgr,
	init
}

function WarLayer:new(data)
	local this = {}
	self.__index = self
	setmetatable(this, self)
	
	this.baseLayer = display.newLayer()
	this.init = data
	
	
	
	local bg = display.newSprite(PATH.."bg.jpg")
	setAnchPos(bg)
	this.baseLayer:addChild(bg)
	
	local back = KNBtn:new(COMMONPATH, {"back_img.png", "back_img_press.png"}, 50, 750, {
		callback = function()
			switchScene("home")
		end
	})
	this.baseLayer:addChild(back:getLayer())
	
	this:warMap()
	
	return this
end

function WarLayer:warMap()
	if self.layer then
		self.baseLayer:removeChild(self.layer, true)
	end
	self.layer = display.newLayer()
	
	self.mgr = Mgr:new(self.init)
	self.layer:addChild(self.mgr:getLayer())
	
	self.baseLayer:addChild(self.layer)
end

function WarLayer:refresh(data)
	self.mgr:mapLogic(data)
end

function WarLayer:getLayer()
	return self.baseLayer
end


return WarLayer