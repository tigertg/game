local stoneInfoLayer = {layer,bg}

function stoneInfoLayer:new(index,point_x,point_y,params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	setAnchPos(this.layer,point_x,point_y)

	this.bg = display.newSprite(IMG_PATH.."image/scene/mosaic/7.png")
	setAnchPos(this.bg,point_x,point_y)
	this.layer:addChild(this.bg)

	this.layer:setContentSize(this.bg:getContentSize())

	local stone_img = display.newSprite(IMG_PATH.."image/scene/mosaic/16.png")
	setAnchPos(stone_img,point_x+(this.bg:getContentSize().width - stone_img:getContentSize().width)/2,point_y+(this.bg:getContentSize().height - stone_img:getContentSize().height)/2)
	this.layer:addChild(stone_img)

	local circle = display.newSprite(IMG_PATH.."image/scene/mosaic/19.png")
	setAnchPos(circle,point_x+(this.bg:getContentSize().width - circle:getContentSize().width),point_y+(this.bg:getContentSize().height - circle:getContentSize().height))
	this.layer:addChild(circle)

	local label_num = CCLabelTTF:create(10,FONT,16)
	setAnchPos(label_num ,point_x+(this.bg:getContentSize().width - circle:getContentSize().width)+(circle:getContentSize().width - label_num:getContentSize().width)/2,point_y+(this.bg:getContentSize().height - circle:getContentSize().height)+(circle:getContentSize().height - label_num:getContentSize().height)/2)
	this.layer:addChild(label_num )


	this.layer:setTouchEnabled(true)
	function this.layer:onTouch(type, x, y)
		if type == CCTOUCHBEGAN then

		elseif type == CCTOUCHMOVED then

		elseif type == CCTOUCHENDED then
					--放开后执行回调
			if x >point_x +this.layer:getPositionX() and x <point_x + this.layer:getPositionX() +this.layer:getContentSize().width and y > point_y + this.layer:getPositionY() and y < point_y + this.layer:getPositionY() +this.layer:getContentSize().height then
				if params["callback"] then
					params["callback"](this)
				end
			end

		end
		return true
	end
	this.layer:registerScriptTouchHandler(function(type,x,y) return this.layer:onTouch(type,x,y) end,false,-30,false)
return this
end

function stoneInfoLayer:get_width()
	return self.bg:getContentSize().width
end

function stoneInfoLayer:get_height()
	return self.bg:getContentSize().height
end

function stoneInfoLayer:getLayer()
	return self.layer
end

return stoneInfoLayer
