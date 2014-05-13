local PATH = IMG_PATH.."image/scene/shop/"
local KNBtn = requires (IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNCheckBox = requires (IMG_PATH , "GameLuaScript/Common/KNCheckBox")
local ShopItem = {
	layer,
	id,
	optBtn,  --操作按钮
	checkBox,  --选择框
	params,  --传递父组件parent来计算点击的偏移量，iconCallback是点击图按钮的回调，checkBoxOpt,点击复选框的操作
	item_data,	-- 商品数据
	current   --点击操作按钮时，此标志为真
}

function ShopItem:new(type,id,params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.id = id
	this.params = params or {}
	this.item_data = DATA_Shop:get(params.index)

	local bg = display.newSprite(COMMONPATH .. "item_bg.png")
	local gold = display.newSprite(COMMONPATH .. "gold.png")
	local value = display.strokeLabel(this.item_data.real_price .. "" , 0 , 0 , 18 , ccc3(0x2c , 0x00 , 0x00 ) , 2 , ccc3(0x40 , 0x1d , 0x0c ) )
	
	setAnchPos(bg)
	setAnchPos(value , 132 , 24)
	setAnchPos(gold , 96 , 22)
		

	local function createItem()	
		local name = display.strokeLabel(this.item_data.name .. "" , 0 , 0 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , 2 , ccc3(0x40 , 0x1d , 0x0c ) )
		setAnchPos(name , 100 , 68)
		this.layer:addChild(name)
		
		name = display.strokeLabel(getConfig("prop", this.item_data.cid , "bagdesc"), 0 , 0 , 20 , DESCCOLOR, 2 , ccc3(0x40 , 0x1d , 0x0c ) )
		setAnchPos(name , 100 , 45)
		this.layer:addChild(name)
		
		this:initOptBtn(type)
	end
	
	this.layer:addChild(bg)
	this.layer:setContentSize(bg:getContentSize())
	
	--[[
	if DATA_Shop:get(id , "real_price") ~= DATA_Shop:get(id , "org_price") then  --是否优惠
		local discount = display.newSprite(PATH.."shop_discount.png")
		setAnchPos(discount,135,65)
		this.layer:addChild(discount)
		
		--未打折的价
		local value = DATA_Shop:get(id,"org_price")
		local preValue = CCLabelTTF:create(value,FONT,20)
		setAnchPos(preValue,130,55)
		this.layer:addChild(preValue)
		
		--根据字符串的长度生成删除线
		local lineText = ""
		for i = 1, string.len(value) do
			lineText = lineText.."__"
		end
		
		local line = CCLabelTTF:create(lineText,FONT,15)
		line:setColor(ccc3(255,0,0))
		setAnchPos(line,123,66)
		this.layer:addChild(line)
	end	
	]]

	this.layer:addChild(value)
	this.layer:addChild(gold)

	createItem()
	
	return this
end

function ShopItem:getLayer()
	return self.layer
end

function ShopItem:initOptBtn(type)
	local icon
	local btnStr
	
	--若有设置按钮图片,则优先使用
	icon = KNBtn:new(IMG_PATH .. "image/scene/common/" , {"skill_frame1.png"} , 17 , 25 , {
		parent = self.params["parent"],
		front = getImageByType(self.item_data.cid , "s"),
		scale = true,
		callback = self.params["iconCallback"]
	})

	self.layer:addChild(icon:getLayer())		



	if not self.params["check"] and not self.params["sell"] then
		self.optBtn = KNBtn:new(COMMONPATH , {"btn_bg.png","btn_bg_pre.png"} , 340 , 36 , {
			front = COMMONPATH .. "buy.png",
			parent = self,
			scale = true,
			callback = function()
				if not isBagFull() then
					self.current = true
					self.params["optCallback"]()
				end
			end
		})

		self.layer:addChild(self.optBtn:getLayer())
	end
end


function ShopItem:getX()
	if self.params["parent"] then
		return self.layer:getPositionX() + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
	end
	return self.layer:getPositionX()
end

function ShopItem:getY()
	if self.params["parent"] then
		return self.layer:getPositionY() + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return self.layer:getPositionY()
end

function ShopItem:getWidth()
	return self.layer:getContentSize().width
end

function ShopItem:getHeight()
	return self.layer:getContentSize().height
end

function ShopItem:isSelect()
	return self.checkBox:isSelect()
end

function ShopItem:check(bool)
	self.checkBox:check(bool)
end

function ShopItem:isCurrent()
	return self.current
end

function ShopItem:getId()
	return self.id
end

function ShopItem:setPos(x,y)
	self.layer:setPosition(ccp(x,y))
end


return ShopItem