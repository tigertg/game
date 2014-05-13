--按钮滑动条


local M = {}
function M:new(path , params )
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	if type(params) ~= "table" then params = {} end
	
	this.priority = params.priority or -128
	this.path=path
	this.x= params.x or 0
	this.y= params.y or 0
    this.minimum = params.minimum or 0;
    this.maximum = params.maximum or 1;
    this.value = params.initial or 0;
    this.onNewValue = params.callback or function () end 
    
    local container = CCLayer:create()--创建对像容器
    container:ignoreAnchorPointForPosition(false)
    
    
    local imagePath = IMG_PATH .. "image/start_bar/"..this.path.."/"
    this.bg = display.newSprite(imagePath.."bg.png")
    container:addChild(this.bg, -2)
    
    this.progress  = display.newSprite(imagePath.."fore.png")
    container:addChild(this.progress, -1)
    
    this.thumb = display.newSprite(imagePath.."icon.png")
    container:addChild(this.thumb, 0)
    
    container:setContentSize(this.bg:getContentSize())--获取大小
    local s = container:getContentSize()
    
    this.bg:setAnchorPoint(ccp(0.5, 0.5));
    this.bg:setPosition(ccp(s.width/2, s.height/2))
    
    this.progress:setAnchorPoint(ccp(0.0, 0.5));
    this.progress:setPosition(ccp(0, s.height/2))
    
    this.thumb:setPosition(ccp(s.width/2, s.height/2))
    
    container:setAnchorPoint(ccp(0, 1));
    container:setPosition(ccp(display.width-(display.width-this.x),display.height-this.y))--设置坐标
    
    
    function container:onTouch(eventType, x, y)
	    if this.minimum == -0.1 then
		    return false
	    end
        local where = CCPointMake(x,y)
        local nodeBB = container:boundingBox()
        local thumbBB = this.thumb:boundingBox()
        thumbBB.origin = ccpAdd(nodeBB.origin, thumbBB.origin)
        local isIn = thumbBB:containsPoint(where)
        if eventType == CCTOUCHBEGAN then return isIn
        elseif eventType == CCTOUCHMOVED then 
            container:setValue((this.maximum - this.minimum) * (x-nodeBB.origin.x)/nodeBB.size.width + this.minimum)
            return true
        elseif eventType == CCTOUCHENDED then return true
        end
	end
    
    

    container:setTouchEnabled( true );
    container:registerScriptTouchHandler(function (eventType, x, y) return container:onTouch(eventType, x, y) end , false , this.priority , false)
    
    function container:layout()
	    if this.minimum > this.maximum then this.minimum = this.maximum - 0.1 end -- sanity check
	    if this.value < this.minimum then this.value = this.minimum end
	    if this.value > this.maximum then this.value = this.maximum end
	    local percent
	    if this.maximum == this.minimum then
		    percent = 1
	    else 
		    percent = (this.value - this.minimum)/(this.maximum - this.minimum)
	    end
	    local pos = this.thumb:getPositionLua()
	    pos.x = percent * this.bg:getContentSize().width
	    this.thumb:setPosition(pos)
	    local textureRect = this.progress:getTextureRect();
	    textureRect =  CCRectMake(textureRect.origin.x, textureRect.origin.y, pos.x, textureRect.size.height)
	    this.progress:setTextureRect(textureRect, this.progress:isTextureRectRotated(), textureRect.size)
	    
	end
	
	function container:setMinimumValue(v) this.minimum = v end
	function container:setMaximumValue(v) print("最小值是"..v) this.maximum = v end
	
	function container:reset()
		this.value = 1
		container:layout()
	end
	
	function container:setValue(v)
	    this.value = v
	    container:layout()
	    this.onNewValue(math.floor(this.value))
	end
	function container:setMax(v)
	    this.maximum = v
	    container:layout()
	    this.onNewValue(math.floor(this.value))
	end
	function container:getMax()
		return this.maximum
	end
   function container:getValue() return this.value end
   
    --初始进度
    container:setValue( this.value )
	return container 
end
return M
