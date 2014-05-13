--[[]]
local Slot = {
	layer,
}

function Slot:new(params,x,y)	
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()	
	local bgImg = display.newSprite(params["bg"])

	
	setAnchPos(this.layer,x,y)
	setAnchPos(bgImg)	
	
	this.layer:addChild(bgImg)
	this.layer:setContentSize(bgImg:getContentSize())
	
	local offsetX,offsetY = params["offsetX"] or 0, params["offsetY"] or 0
	if params["icon"] then
		local icon = display.newSprite(params["icon"]) 
		setAnchPos(icon,bgImg:getContentSize().width / 2 + offsetX, bgImg:getContentSize().height / 2 + offsetY,0.5,0.5)
		this.layer:addChild(icon)
	end
	
	if params["name"] then
		local name = CCLabelTTF:create(params["name"],FONT,20)
		setAnchPos(name,this.layer:getContentSize().width / 2,offsetY,0.5)
		this.layer:addChild(name)
	end
	
	return this
end

function Slot:getLayer()
	return self.layer
end
return Slot
