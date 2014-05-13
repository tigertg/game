local PATH = IMG_PATH.."image/scene/home/"
local ICONPATH = IMG_PATH.."image/hero/"
--卡片在不同位置上的锚点，坐标等信息
local posInfo = {
	--不同位置的锚点，x坐标，旋转角度，z轴，缩放比例
	[0] = {ccp(0,0.5), -200, -70, 0,0.8},
    {ccp(0,0.5),   10, -70, 1, 0.8},
	{ccp(0,0.5),  80, -70, 2, 0.8},
	{ccp(0,0.5), 140,   0, 3,  1 },
	{ccp(1,0.5), 390,  70, 2, 0.8},
	{ccp(1,0.5), 450,  70, 1, 0.8},
	{ccp(1,0.5), 600,  70, 0, 0.8},
	{ccp(1,0.5), 600,  70, -1, 0.8},
	{ccp(1,0.5), 600,  70, -2, 0.8},
	{ccp(1,0.5), 600,  70, -3, 0.8},
}
local HeroCard = {
	layer,
	id,
	pos,
	rotate,
	light
	
}

function HeroCard:new(y,pos, cid)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.pos = pos 
	
	local str = PATH.."card_bg.png"

	local bg = display.newSprite(str)
	setAnchPos(bg)


	this.layer:setContentSize(bg:getContentSize())
	this.layer:ignoreAnchorPointForPosition(false)	
	setAnchPos(this.layer,posInfo[this.pos][2],y,0.5,0.5)
	this.layer:addChild(bg)
	
	
	local bottom
			local general_data = getConfig("general", cid)
			
			if getConfig("general" , cid , "special" ) == 1 then
				local tempSp = display.newSprite( IMG_PATH.."image/scene/home/special_frame.png" )
				setAnchPos( tempSp , -30 , 3 , 0 , 0 )
				this.layer:addChild( tempSp )
			end
			
			
			local star = getConfig("general" , cid ,"star")

			local icon = display.newSprite( getImageByType( cid , "b" ) )
			setAnchPos(icon , 95 , 135 , 0.5 , 0.5)
			this.layer:addChild(icon)
		

			bottom = display.newSprite(PATH .. "card_bottom_" .. star .. ".png")
			setAnchPos(bottom , -2 , -2)
			this.layer:addChild(bottom)
			
			bottom = display.strokeLabel(getConfig("general",cid,"name"),135,5,25)
			setAnchPos(bottom,this.layer:getContentSize().width / 2 , 5 , 0.5)
			this.layer:addChild(bottom)
			
			
			for i = 1, star do
				icon = display.newSprite(PATH .. "star.png")
				setAnchPos(icon,(i - 1) * icon:getContentSize().width +  this.layer:getContentSize().width / 2 - (icon:getContentSize().width * star) / 2  ,36)
				this.layer:addChild(icon)
			end
		
		function this.layer:getRotate()
			return this.rotate
		end
	return this
end

function HeroCard:getLayer()
	return self.layer
end

function HeroCard:stop()
	self.layer:stopAllActions()
end

function HeroCard:addTo(i,parent)
	self.rotate = posInfo[i][3] 
	self.layer:setScale(posInfo[i][5])
	self.layer:setAnchorPoint(posInfo[i][1])
	
	--使用摄像机进行卡牌的翻转效果实现
	self.layer:runAction(CCOrbitCamera:create(0,1,0,self.rotate,0,0,0))
	
	if i ~= 3 then
		transition.playSprites(self.layer,"tintTo",{time = 0, r = 100,g=100,b=100})
	else
		self:showLight(true)
	end
	parent:addChild(self.layer,posInfo[i][4])
end

--直接设置卡牌的位置状态
function HeroCard:setState(step,parent)
	self.pos = self.pos + step
	if self.pos > 8 then
		self.pos = self.pos - 8
	end 
	self.rotate = posInfo[self.pos][3] 
	self.layer:setScale(posInfo[self.pos][5])
	self.layer:setAnchorPoint(posInfo[self.pos][1])
	self.layer:setPositionX(posInfo[self.pos][2])
	--使用摄像机进行卡牌的翻转效果实现
	self.layer:runAction(CCOrbitCamera:create(0,1,0,self.rotate,0,0,0))
	if self.pos ~= 3 then
		transition.playSprites(self.layer,"tintTo",{time = 0, r = 100,g=100,b=100})
	else
		transition.playSprites(self.layer,"tintTo",{time = 0, r = 255,g=255,b=255})
	end
	parent.mainLayer:reorderChild(self.layer,posInfo[self.pos][4])
	if self.pos == 3 then
		self:showLight(true)
	else
		self:showLight(false)
	end
end

function HeroCard:move(left,parent,time)
	local time, startA, desA, posX, anchCha, anchX,scale,zOrder = time, 0, 0, 0, 0, ccp(0,0.5),0.8,0

	local array = CCArray:create()
	local sequence = CCArray:create()
	
	local next
	if left then
		---------------卡片循环移动的设置---------
		if self.pos == 0 then
			self.pos = 8 
			self.rotate = posInfo[self.pos][3] 
			self.layer:setScale(posInfo[self.pos][5])
			self.layer:setAnchorPoint(posInfo[self.pos][1])
			self.layer:setPositionX(posInfo[self.pos][2])
		end
		-----------------------
		next = self.pos - 1	
		if next < 0 then
			next = 0
		end
	else
		--下面是要做循环移动的设置
		if self.pos == 8 then
			self.pos = 0
			self.rotate = posInfo[self.pos][3] 
			self.layer:setScale(posInfo[self.pos][5])
			self.layer:setAnchorPoint(posInfo[self.pos][1])
			self.layer:setPositionX(posInfo[self.pos][2])
		end
		----------------以上是做循环设置---------------------------------------
		next =self.pos + 1
		if next > 8 then
			next = 9
		elseif next < 0 then
			next = 0
		end
	end
	
	posX = posInfo[next][2]
	anchX = posInfo[next][1]
	anchCha = self.layer:getAnchorPoint().x - anchX.x
	desA = posInfo[next][3]- self.rotate
	zOrder = posInfo[next][4]
	scale = posInfo[next][5]
	
	if next == 3 then
		transition.playSprites(self.layer,"tintTo",{time = time, r = 255,g=255,b=255})
		if self.id then
			self:showLight(true)
		end
	else
		self:showLight(false)
		if not left and next == 4 then  --当向右滑动时，第三张卡片滑到第四张卡片需要进行亮度，坐标及锚点位置的处理，其余卡牌不用
			anchX.x = 1
			anchCha = 0
			self.layer:setAnchorPoint(anchX)
			self.layer:setPositionX(self.layer:getPositionX() + self.layer:getContentSize().width)
		end
		transition.playSprites(self.layer,"tintTo",{time = time, r = 100,g=100,b=100})
	end
	------------------以上的处理方式是根据滑动方向与卡牌位置进行处理------------------------------------------------
	
	parent.mainLayer:reorderChild(self.layer,zOrder)
	
	array:addObject(CCOrbitCamera:create(time,1,0,self.rotate,desA,0,0))
	array:addObject(CCMoveTo:create(time,ccp(posX + self.layer:getContentSize().width * anchCha,self.layer:getPositionY())))
	array:addObject(CCScaleTo:create(time,scale))
	sequence:addObject(CCSpawn:create(array))	
	sequence:addObject(CCCallFunc:create(function()
		self.layer:setAnchorPoint(anchX)
		self.layer:setPositionX(self.layer:getPositionX() - self.layer:getContentSize().width * anchCha)
		self.rotate = desA + self.rotate
		if left then
			self.pos = self.pos - 1
		else
			self.pos = self.pos + 1
		end
		parent.allow = true  --动作完成后，允许下次的移动
		if self.pos == 3 then
		end
		self:move(left, parent, time)
	end))
	
	self.layer:runAction(CCSequence:create(sequence))
end

function HeroCard:showLight(bool)
	if bool then
		if self.light then
			self.light:setVisible(true)
		else			
			self.light = display.newSprite(PATH.."card_light.png")
			setAnchPos(self.light,self.layer:getContentSize().width / 2,self.layer:getContentSize().height / 2,0.5,0.5)
			self.layer:addChild(self.light,-1)
			
			local function createAction()
				local action
				local array = CCArray:create()
				array:addObject(CCScaleTo:create(1,0.9))
				array:addObject(CCScaleTo:create(1,0.98))
				array:addObject(CCCallFunc:create(
				function()
					self.light:runAction(createAction())
				end))
				action = CCSequence:create(array)
				return action
			end
			self.light:runAction(createAction())
		end
	else
		if self.light then
			self.light:setVisible(false)
		end
	end
end

return HeroCard