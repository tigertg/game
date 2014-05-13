local PATH = IMG_PATH.."image/scene/war/"
local MOVE, HOLD, HIDE = 1, 2, 3
local Role = {
	layer,
	moving,
	stateIcon,
	state,
	data
}

function Role:new(x, y,state, params)
	local this = {}
	self.__index = self
	setmetatable(this, self)
	
	this.stateIcon = {}
	this.data = params or {}
	
	this.layer = display.newLayer()
	this.layer:ignoreAnchorPointForPosition(false)
	setAnchPos(this.layer, x, y, 0.5, 0.5)
	
	if this.data.group == 1 then 
		if tonumber(this.data.uid) == tonumber(DATA_User:get("uid")) then
			this.stateIcon[MOVE] = display.newSprite(PATH.."sign_self.png")		
		else
			this.stateIcon[MOVE] = display.newSprite(PATH.."sign_our.png")		
		end
		this.stateIcon[HOLD] = display.newSprite(PATH.."flag_our.png")		
	else
		if tonumber(this.data.uid) == tonumber(DATA_User:get("uid")) then
			this.stateIcon[MOVE] = display.newSprite(PATH.."sign_self.png")		
		else
			this.stateIcon[MOVE] = display.newSprite(PATH.."sign_enemy.png")		
		end
		this.stateIcon[HOLD] = display.newSprite(PATH.."flag_enemy.png")		
	end
	
	this.stateIcon[MOVE]:setVisible(false)
	this.stateIcon[HOLD]:setVisible(false)
	
	this.layer:setContentSize(this.stateIcon[MOVE]:getContentSize())
	
	setAnchPos(this.stateIcon[MOVE])
	setAnchPos(this.stateIcon[HOLD], this.stateIcon[HOLD]:getContentSize().width / 4, this.stateIcon[HOLD]:getContentSize().height / 4)
	
	this.layer:addChild(this.stateIcon[MOVE])
	this.layer:addChild(this.stateIcon[HOLD], 1)
	
	this.layer:addChild(createLabel({str = this.data.name.."/"..this.data.uid, x = 0, y = 0}))
	
	if state then
		this:setState(state)
	else
		this:setState(HIDE)
	end
	
	return this
end

function Role:setState(state)
	if self.stateIcon[self.state] then
		self.stateIcon[self.state]:setVisible(false)
	end
	
	self.state = state
	if state == HOLD or state == HIDE then
		self.moving = false
		self.layer:setRotation(0)
	end
	
	if self.stateIcon[state] then
		self.stateIcon[state]:setVisible(true)
	end
end

function Role:hold(x, y, hide)
	if hide then
		self:setState(HIDE)
	else
		self:setState(HOLD)
	end
	self.layer:stopAllActions()
	self.layer:setPosition(ccp(x, y ))
end

function Role:battle(x, y)
	self:setState(HIDE)
	self.layer:stopAllActions()
	self.layer:setPosition(ccp(x, y))
end

function Role:backHome(desX, desY)
	self:setState(HOLD)	
	self.layer:stopAllActions()
	self.layer:runAction(getSequenceAction(CCMoveTo:create(1, ccp(desX, desY)), CCCallFunc:create(function()
		self:setState(HIDE)
	end)))
	
end

function Role:move(x, y, map)
	if self.moving then
		return
	end
	
	local curX = self.layer:getPositionX()
	local curY = self.layer:getPositionY()
	
	local degree, time
	if x == curX then
		if y > curY then
			degree = 0
		else
			degree = 180
		end
	elseif y == curY then
		if x > curX then
			degree = 90
		else
			degree = -90
		end
	else
		degree = math.deg(math.atan((y - curY) / (x - curX)))
		if y < curY then
			degree = degree + 180
		end
	end
	self.moving = true
	self:setState(MOVE)
	time = 5 
	self.layer:runAction(getSequenceAction(CCRotateTo:create(0, degree),
		CCMoveTo:create(time, ccp(x, y)), 
		CCCallFunc:create(function()
--			self.moving = false
--			self:setState(HOLD)
		end)))
end

function Role:isMoving()
	return self.moving
end


function Role:getLayer()
	return self.layer
end

return Role
