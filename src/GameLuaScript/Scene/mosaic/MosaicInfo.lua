local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config_General = requires(IMG_PATH , "GameLuaScript/Config/Hero")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local MosaicInfo = {layer,point_x,point_y,gid,is_clike,bg = nil,bg1 = nil,select_yes = nil,is_select}
function MosaicInfo:new(data,x,y,parm,params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.params = params or {}
	this.point_x = x
	this.point_y = y
	this.is_clike = false
	this.is_select = false
	this.gid = data["id"]
	this.layer = display.newLayer()
	local cid = tostring(data["cid"])
	setAnchPos(this.layer,this.point_x,this.point_y)
	this.bg = display.newSprite(IMG_PATH.."image/common/item_bg_high.png")
	setAnchPos(this.bg,0,0)
	this.layer:addChild(this.bg)
	this.layer:setContentSize(this.bg:getContentSize())
	
	local title_box = display.newSprite(IMG_PATH.."image/scene/Culture/box.png")
	setAnchPos(title_box,5,0)
	this.layer:addChild(title_box)
	
	local head_img = display.newSprite(IMG_PATH.."image/prop/s_"..cid..".png")
	setAnchPos(head_img,2+(title_box:getContentSize().width - head_img:getContentSize().width)/2,(title_box:getContentSize().height - head_img:getContentSize().height)/2+2)
	this.layer:addChild(head_img)
	
	local name = display.strokeLabel( data["name"] , title_box:getContentSize().width + 10, title_box:getContentSize().height - 20 , 16 , ccc3( 0xac , 0x25 , 0x10 )  )
	this.layer:addChild( name)
	
	local pro = display.strokeLabel( Config_Property[data["effect"]]..": "..data["figure"] , title_box:getContentSize().width + 10, title_box:getContentSize().height - 45 , 16 , ccc3( 0xac , 0x25 , 0x10 )  )
	this.layer:addChild( pro )
	
	local num = display.strokeLabel("数量：".. data["num"] , title_box:getContentSize().width + 10, title_box:getContentSize().height - 67 , 16 , ccc3( 0xac , 0x25 , 0x10 )  )
	this.layer:addChild( num )
	
	--镶嵌
	local btn = KNBtn:new(COMMONPATH , {"btn_bg.png"} , 320, 18 , {
		front = IMG_PATH.."image/common/Mosaic.png",
		scale = true,
		noHide = true,
		callback = function()
			
			if parm.index == 1 then
				HTTP:call("pulse" , "initial", 
						{ id = parm.gid,index = parm.index,stone_id = this.gid} ,
						{success_callback= 
						function()
							switchScene("pulse",parm.gid)
						end}
					)
			else
				HTTP:call("pulse" , "initial", 
						{ id = parm.gid,index = parm.index,stone_id = this.gid} ,
						{success_callback= 
						function()
							switchScene("pulse",parm.gid)
						end}
					)
			end
		end
	})
	this.layer:addChild(btn:getLayer())
	--this.layer:addChild( display.strokeLabel( "lv"..data["lv"] , title_box:getContentSize().width + 20 + name:getLabel():getContentSize().width , title_box:getContentSize().height - 30 , 18 , ccc3( 0xac , 0x25 , 0x10 )  ) )
	
	--[[for i = 1,Config_General[cid]["star"] do
		local srat = display.newSprite(IMG_PATH.."image/common/star.png")
		setAnchPos(srat ,title_box:getContentSize().width + 10+(i-1)*30,title_box:getContentSize().height - 60)
		this.layer:addChild(srat )
	end
	]]
	--[[local select_box = display.newSprite(IMG_PATH.."image/common/checkbox_bg.png")
	setAnchPos(select_box,360,17)
	this.layer:addChild(select_box)
	
	this.select_yes = display.newSprite(IMG_PATH.."image/common/checkbox_choose.png")
	setAnchPos(this.select_yes,360 ,17 )
	this.select_yes:setVisible(false)
	this.layer:addChild(this.select_yes)
	]]
	
	this.layer:setTouchEnabled(true)
	function this.layer:onTouch(type, x, y)
		if type == CCTOUCHBEGAN then
			if this:getRange():containsPoint(ccp(x,y)) then
				if this:get_select() == false then
					this:set_select(true)
				end
			end
		elseif type == CCTOUCHMOVED then

		elseif type == CCTOUCHENDED then
					--放开后执行回调
			if params["callback"] then
				params["callback"](this)
			end
		end
		return true
	end
	this.layer:registerScriptTouchHandler(function(type,x,y) return this.layer:onTouch(type,x,y) end,false,-132,false)
	return this
end

--获取所有父组件，取得按钮的绝对位置
function MosaicInfo:getRange()
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

function MosaicInfo:set_select(is_true)
	self.is_select = is_true
end

function MosaicInfo:get_select()
	return  self.is_select
end

function MosaicInfo:set_Click(is_true)
	self.is_clike = is_true
	if self.is_clike == true then
		self.bg1:setVisible(is_true)
		self.select_yes:setVisible(is_true)
		self.bg:setVisible(false)
	else
		self.bg1:setVisible(is_true)
		self.select_yes:setVisible(is_true)
		self.bg:setVisible(true)
	end 
end

function MosaicInfo:get_Click()
	return self.is_clike
end

function MosaicInfo:getLayer()
	return self.layer
end

function MosaicInfo:get_gid()
	return self.gid
end

function MosaicInfo:getWidth()
	return self.layer:getContentSize().width
end

function MosaicInfo:getHeight()
	return self.layer:getContentSize().height
end

function MosaicInfo:setPosition(x,y)
	self.layer:setPosition(ccp(x,y))
end

function MosaicInfo:getX()
	return self.layer:getPositionX()
end

function MosaicInfo:getY()
	return self.layer:getPositionY()
end

return MosaicInfo
