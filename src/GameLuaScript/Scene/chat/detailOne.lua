--[[一条详情]]

local detailOne = {
	layer,
}



function detailOne:new(data , index)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	this.layer = display.newLayer()

	local detail = { name = data["name"] or "" }
	if data["type"] == "url" then
		detail["name"] = data["url"]
	elseif data["cid"] then
		local cid_type = getCidType( data["cid"] )
		detail = getConfig(cid_type , data["cid"])
	end

	this.layer:setContentSize( CCSizeMake(480 , 50) )
	
	local line = display.newSprite(IMG_PATH .. "image/scene/battle/hero_info/line_long.png")
	setAnchPos(line , display.cx , 50 , 0.5)
	this.layer:addChild(line)
	
	local line = display.newSprite(IMG_PATH .. "image/scene/battle/hero_info/line_long.png")
	setAnchPos(line , display.cx , 0 , 0.5)
	this.layer:addChild(line)
	
	local font = display.strokeLabel(detail["name"] , 0 , 0 , 20 , ccc3( 0xff , 0xff , 0xff ) )
	setAnchPos(font , display.cx , 25 , 0.5)
	this.layer:addChild( font )


	-- 设置可点击
	local init_y = 0
	this.layer:registerScriptTouchHandler(function( type , x , y )
		if type == CCTOUCHBEGAN then
			if this:getRange():containsPoint( ccp(x , y) ) then
				init_y = y
				return true
			else
				return false
			end
		elseif type == CCTOUCHMOVED then
		elseif type == CCTOUCHENDED then
			if this:getRange():containsPoint( ccp(x , y) ) then
				if math.abs(y - init_y) < 30 then
					dump(data)
					dump(detail)

					-- 点击
					if data["type"] == "url" then
--						this.is_showUrl = true
						UpdataRes:getInstance():openUrl( data["url"] )
					elseif data["type"] == "user" then
						HTTP:call("profile" , "get" , {
							touid = data.uid
						} , {
							success_callback = function()
								local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
								display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
							end
						})
					elseif data["cid"] then
						this:showDetail( data )
					else
						print("============ unknown type ============")
					end
				end
			end
		end

		return true
	end , false , -141 , true)
	this.layer:setTouchEnabled(true)

	
	return this
end


function detailOne:showDetail(data)
dump(data)
	local cid_type = getCidType( data["cid"] )

	
	self.is_showDetail = true

	local config_data = getConfig( cid_type , data["cid"] )
	for k , v in pairs(config_data) do
		if k ~= "type" and not isset(data , k) then
			data[k] = v
		end
	end

	pushScene("detail" , {
		detail = cid_type,
		data = data,
	})
end



function detailOne:getLayer()
	return self.layer
end


--获取所有父组件，取得按钮的绝对位置
function detailOne:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()

	local parent = self.layer:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end

return detailOne