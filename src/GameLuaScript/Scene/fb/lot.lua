local PATH = IMG_PATH.."image/scene/fb/"
local Lot = {
	layer
}

function Lot:new(lotFace, lock, x, y, rotate)
	local this = {}
	setmetatable(this, self)
	self.__index = self
	
	this.layer = display.newLayer()
	
	local bg = display.newSprite(PATH..(lock and "lot_lock.png" or "lot.png"))
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	local text = display.newSprite(PATH.."l"..lotFace..".png")
	setAnchPos(text, bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 15, 0.5)
	this.layer:addChild(text)
	
	if lock then
		text = display.newSprite(PATH.."lock.png")
		setAnchPos(text, bg:getContentSize().width / 2, bg:getContentSize().height - 20, 0.5, 1)
		this.layer:addChild(text)
	end
	
	this.layer:setContentSize(bg:getContentSize())
	setAnchPos(this.layer, x, y)
	this.layer:setRotation(rotate or 0)	
		
	
	
	return this
end

function Lot:getLayer()
	return self.layer
end

function Lot:runAction(act)
	self.layer:runAction(act)
end

function Lot:getX()
	return self.layer:getPositionX()
end

function Lot:getY()
	return self.layer:getPositionY()
end

function Lot:getPos()
	return ccp(self:getX(), self:getY())
end

function Lot:getRotate()
	return self.layer:getRotation()
end

return Lot