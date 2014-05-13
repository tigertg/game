local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNComboBox = {
	layer,
	window,
	container,
	params,
	mainBtn,
	itemsShow, 
	moving
}

function KNComboBox:new(x, y, params)
	local this = {} 
	setmetatable(this,self)
	self.__index = self
	
	this.params = params or {}
	this.layer = display.newLayer()
	this.window = WindowLayer:createWindow()
	this.container = display.newLayer()
	
	function this.window:getX()	
		return x + this.window:getPositionX() 
	end
	
	function this.window:getY()	
		return  y + this.window:getPositionY()
	end

	function this.window:getWidth()	
		return this.window:getContentSize().width
	end
	
	function this.window:getHeight()	
		return this.window:getContentSize().height
	end
	
	--下拉列表层
	local bg = display.newSprite(this.params.bg)
	setAnchPos(bg)
	
	this.container:setContentSize(bg:getContentSize())
	this.container:addChild(bg)
	
	--视窗
	this.window:setContentSize(bg:getContentSize())
	this.window:addChild(this.container)
--	
	
	this.mainBtn = KNBtn:new(this.params.dir, this.params.res, 0, 0, {
		front = this.params.front,
		text = this.params.text,
		callback = function()
			this:autoShow()
		end
	})
	this.layer:addChild(this.mainBtn:getLayer())
--
	this.layer:setContentSize(CCSizeMake(this.mainBtn:getWidth(), this.mainBtn:getHeight()))
	setAnchPos(this.layer, x, y)
	
	this.layer:addChild(this.window)
	
	if this.params.up then --向上弹出列表
		setAnchPos(this.window, 0, this.mainBtn:getHeight())
		setAnchPos(this.container, 0, -bg:getContentSize().height)
	else --向下弹出列表
		setAnchPos(this.window, 0, -this.window:getContentSize().height)
		setAnchPos(this.container,0,bg:getContentSize().height)
	end	
	
	if this.params.items then
		for k, v in pairs(this.params.items) do
			v:setParent(this.window)
			if this.params.up then
				setAnchPos(v:getLayer(), ( this.params.addX or  0 ) , (this.params.offset or 0) + (k - 1) * ( v:getHeight() + ( this.params.additionHeight or 0 ) ) ) 
			end
			this.container:addChild(v:getLayer())						
		end
	end
	
	this.params.itemsGroup:chooseByIndex(this.params.default or 1)
	
	this.layer:setTouchEnabled(true)
	this.layer:registerScriptTouchHandler(function(type, x, y) 
		if type == CCTOUCHBEGAN then
			if not CCRectMake(this.window:getX(), this.window:getY(), this.window:getWidth(), this.window:getHeight()):containsPoint(ccp(x,y)) then
				if this.itemsShow then
					this:autoShow()
				end
			end
		end
		return true
	end, false, 1, false)
	return this
end

function KNComboBox:getLayer()
	return self.layer
end

function KNComboBox:refreshBtn( params )
	self.mainBtn:setFront(params.front)
end

function KNComboBox:autoShow()
	if not self.moving then
		self.moving = true
		local pos
		if self.itemsShow then
			if self.params.up then
				pos = ccp(0, -self.container:getContentSize().height)
			else
				pos = ccp(0, self.container:getContentSize().height)
			end
		else
				pos = ccp(0, 0)
		end				
		self.container:runAction(getSequenceAction(CCMoveTo:create(0.2, pos),CCCallFunc:create(function()
				self.moving = false
				self.itemsShow = not self.itemsShow
				
				if self.itemsShow then
					if self.params.popCallback then  --弹出后的回调 
						self.params.popCallback()
					end
				else
					if self.params.closeCallback then  --关闭的回调
						self.params.closeCallback()
					end
				end
		end) ))
	end
end

function KNComboBox:setText(text)
	self.mainBtn:setText(text)
end

function KNComboBox:getCurItem()
	return self.params.itemsGroup:getChooseBtn()
end


return  KNComboBox