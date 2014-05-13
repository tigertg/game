local heroInfoLayer = {layer,point_x,point_y,select,cu_bg,is_select,index,id}
function heroInfoLayer:new(x,y,index,params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.params = params or {}
	this.point_x = x
	this.point_y = y
	this.is_select = false
	this.index = index
	
	this.layer = display.newLayer()
	setAnchPos(this.layer,this.point_x,this.point_y)
	
	this.cu_bg = display.newSprite(IMG_PATH.."image/scene/Culture/box.png")
	setAnchPos(this.cu_bg,0,0)
	this.layer:addChild(this.cu_bg)
	
	this.layer:setContentSize(this.cu_bg:getContentSize())
	
	local hero = display.newSprite(getImageByType( DATA_Formation:get_index(index)["cid"] , "s" ) )
	setAnchPos(hero,0 + 3,0 + 9)
	this.layer:addChild(hero)
	
	this.select = display.newSprite(IMG_PATH.."image/scene/Culture/select.png")
	setAnchPos(this.select,0 + (this.cu_bg:getContentSize().width - this.select:getContentSize().width)/2 - 3,0 + (this.cu_bg:getContentSize().height - this.select:getContentSize().height)/2 + 3)
	this.select:setVisible(false)
	this.layer:addChild(this.select)
	
	this.layer:setTouchEnabled(true)
	local cur_x = 0
	local is_cur = false
	local is_cur_true = false
	function this.layer:onTouch(type, x, y)
		if type == CCTOUCHBEGAN then
			--print(x)
			--print(y)
			if this:getRange():containsPoint(ccp(x,y)) then
				if this:get_select() == false then
					this:set_select(true)
					--this:set_index(this.index)
				end
			end
		elseif type == CCTOUCHMOVED then
			if is_cur == false then
				is_cur = true
				cur_x = x
			end
		elseif type == CCTOUCHENDED then
			if is_cur == true then
				if x - cur_x > 20 or x - cur_x < -20 then
					is_cur_true = true
					is_cur = false
					this:set_select(false)
				else
					--cur_x = 0
					is_cur = false
					
				end
			end
			if is_cur_true == false  then
				if params["callback"] then
					params["callback"](this)
				end
			else
				is_cur_true = false
			end
		end
		return true
	end
	this.layer:registerScriptTouchHandler(function(type,x,y) return this.layer:onTouch(type,x,y) end,false,-110,false)
	return this
end

function heroInfoLayer:getLayer()
	return self.layer
end

function heroInfoLayer:set_visible(visi)
	self.select:setVisible(visi)
end

function heroInfoLayer:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
--	if self.params["parent"] then
--		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
--		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
--	end
	local parent = self.layer:getParent()
	x = x + parent:getPositionX()
	y = y + parent:getPositionY()
	while parent:getParent() do
		parent = parent:getParent()
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end

function heroInfoLayer:set_select(is_true)
	self.is_select = is_true
	--self.select:setVisible(is_true)
end

function heroInfoLayer:get_select()
	return  self.is_select
end

function heroInfoLayer:getWidth()
	return self.layer:getContentSize().width
end

function heroInfoLayer:getHeight()
	return self.layer:getContentSize().height
end

function heroInfoLayer:setPosition(x,y)
	self.layer:setPosition(ccp(x,y))
end

function heroInfoLayer:getX()
	return self.layer:getPositionX()
end

function heroInfoLayer:getY()
	return self.layer:getPositionY()
end

function heroInfoLayer:set_index(index)
	self.index = index
end

function heroInfoLayer:get_index()
	return self.index
end

function heroInfoLayer:get_id()
	return id
end
return heroInfoLayer