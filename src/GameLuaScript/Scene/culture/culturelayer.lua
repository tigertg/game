local Culturelayer = {layer}
local heroInfo = requires(IMG_PATH,"GameLuaScript/Scene/culture/heroInfo")


--[[培养]]
function Culturelayer:new(x,y,gid)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	local array = {}
	local my_index = 0
	local is_click = false
	local handle = CCDirector:sharedDirector():getScheduler()
	local CultureInfo = requires(IMG_PATH,"GameLuaScript/Scene/culture/CultureInfo")--require "GameLuaScript/Scene/culture/CultureInfo"
	local childLayer = nil
	local index = gid
	this.layer = display.newLayer()
	
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)

	--[[local cu_font = display.newSprite(IMG_PATH.."image/common/title_bg.png")
	setAnchPos(cu_font,(this.layer:getContentSize().width - cu_font:getContentSize().width)/2,690)
	this.layer:addChild(cu_font)]]
	
	local bg_box = display.newSprite(IMG_PATH.."image/common/bg_big.png")
	setAnchPos(bg_box,(this.layer:getContentSize().width - bg_box:getContentSize().width)/2,100	)
	this.layer:addChild(bg_box)
	
	local culture_font = display.newSprite(IMG_PATH.."image/scene/Culture/culture.png")
	setAnchPos(culture_font,(this.layer:getContentSize().width - culture_font:getContentSize().width)/2,760)
	this.layer:addChild(culture_font)
	
	local hero_bg = display.newSprite(IMG_PATH.."image/scene/common/cbox.png")
	setAnchPos(hero_bg,(this.layer:getContentSize().width - hero_bg:getContentSize().width)/2,632)
	this.layer:addChild(hero_bg)
	
	local content_bg = display.newSprite(IMG_PATH.."image/scene/Culture/content_bg.png")
	setAnchPos(content_bg,(this.layer:getContentSize().width - content_bg:getContentSize().width)/2,320)
	this.layer:addChild(content_bg)
	
	local arrow = display.newSprite(IMG_PATH.."image/scene/Culture/arrow.png")
	setAnchPos(arrow,(this.layer:getContentSize().width - arrow:getContentSize().width)/2,380)
	this.layer:addChild(arrow)
	
	local bottom = display.newSprite(IMG_PATH.."image/scene/Culture/small_box.png")
	setAnchPos(bottom,(this.layer:getContentSize().width - bottom:getContentSize().width)/2,172)
	this.layer:addChild(bottom)
	
	for i = 0,2 do
		local line_1 = display.newSprite(IMG_PATH.."image/common/line.png")
		setAnchPos(line_1,(this.layer:getContentSize().width - line_1:getContentSize().width)/2,272 + (-55)*i)
		this.layer:addChild(line_1)
	end
	
	
	
	
	
	--[[local bottom = display.newSprite(IMG_PATH.."image/scene/common/PropertyBar.png")
	setAnchPos(bottom,(this.layer:getContentSize().width - bottom:getContentSize().width)/2,166)
	this.layer:addChild(bottom)
	]]
	
	local count = DATA_Formation:get_ON("count")
	
	-------英雄选择
	--[[local RadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
	local btn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")

	local group = RadioGroup:new()
	]]
	local temp
	local sv = KNScrollView:new(32,634,415,101,10,true)
	for i = 1 , count do
		temp = heroInfo:new(100,200,i,{ callback = function(thiscard) 
														if thiscard:get_select() == true then
															thiscard:set_select(false)
															is_click = true
															my_index = thiscard:get_index()
															local hero_id = DATA_Formation:get_index(my_index)["gid"]
															
															local hero_data = DATA_General:getTable(hero_id)
															
															--HTTP:call("wash" , "get" , {id = hero_data["id"]} , {
															--		success_callback = function()
																	if childLayer ~= nil then
																		this.layer:removeChild(childLayer,true)
																		childLayer = CultureInfo:new(0,0,DATA_Formation:get_index(my_index)["gid"]):getLayer()
																		this.layer:addChild(childLayer)
																	else
																	end	
															--end})	
														end
													end})
		if DATA_Formation:get_index(i)["gid"] == index then
			temp:set_visible(true)
		end
		table.insert(array,temp)
		sv:addChild(temp:getLayer(),temp)
		y =  y + 100
	end
	
	this.layer:addChild(sv:getLayer())
	
	
	--for i = 1 , count do
	for i = 1 , count do 
		if index == DATA_Formation:get_index(i)["gid"] then
			sv:setIndex(i)
			childLayer = CultureInfo:new(0,0,index):getLayer()
			this.layer:addChild(childLayer)
			break
		end
	end

	
	function tick()
		if is_click == true then
			is_click = false
			for k,v in pairs(array) do
				if k == my_index then
					local hero_data = v
					hero_data:set_visible(true)
				else
					local hero_data = v
					hero_data:set_visible(false)
				end
			end
		end
	end
	entry = handle:scheduleScriptFunc(tick , 0.01 , false)
	
	return this
end

function Culturelayer:getLayer()
	return self.layer
end

return Culturelayer
