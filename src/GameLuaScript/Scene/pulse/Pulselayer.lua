local Pulselayer = {layer}

local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local PulseInfo = requires(IMG_PATH,"GameLuaScript/Scene/pulse/PulseInfoLayer")
local heroInfo = requires(IMG_PATH,"GameLuaScript/Scene/culture/heroInfo")
--[[筋脉]]
function Pulselayer:new(gid)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	this.layer = display.newLayer()

	local array = {}
	local childLayer = nil
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)
	--[[local bg = display.newSprite(IMG_PATH .. "image/scene/common/bg.png")
	setAnchPos(bg , 0 , 0)
	this.layer:addChild(bg)
	
	local context_bg = display.newSprite(IMG_PATH.."image/common/list_bg.png")
	setAnchPos(context_bg , 15 , 87)
	this.layer:addChild(context_bg)
	
	local title_bg = display.newSprite(IMG_PATH.."image/common/list_title.png")
	setAnchPos(title_bg , 33 , 735)
	this.layer:addChild(title_bg)
	
	local title_font = display.newSprite(IMG_PATH.."image/scene/Pulse/title.png")
	setAnchPos(title_font , 166 , 740)
	this.layer:addChild(title_font)
	]]
	local box = display.newSprite(IMG_PATH.."image/scene/common/cbox.png")
	setAnchPos(box , 29 , 635)
	this.layer:addChild(box)
	
	--[[local close = KNBtn:new(IMG_PATH .. "image/common" , {"close.png"} , 423 , 725 , {
		upSelect = true,
		noHide = true,
		callback = function()
			switchScene("hero" , {gid = gid})
		end
	})
	this.layer:addChild(close:getLayer())
]]
	

	local scroll = KNScrollView:new(32 , 637 , 415 , 101 , 10 , true)
	local count = DATA_Formation:get_ON("count")
	for i = 1 , count do
		local temp = heroInfo:new(100 , 200 , i , {
			callback = function(thiscard) 
				if thiscard:get_select() == true then
					thiscard:set_select(false)

					local my_index = thiscard:get_index()
					for k , one_hero in pairs(array) do
						if k == my_index then
							one_hero:set_visible(true)
						else
							one_hero:set_visible(false)
						end
					end

					local hero_id = DATA_Formation:get_index(my_index)["gid"]
					local hero_data = DATA_General:getTable(hero_id)
					
					HTTP:call("pulse" , "get", {id = hero_data["id"]} , {
						success_callback = function()
							if childLayer ~= nil then
								this.layer:removeChild(childLayer,true)
							end	

							childLayer = PulseInfo:new(i):getLayer()
							this.layer:addChild(childLayer)
						end
					})	
				end
			end
		})

		if DATA_Formation:get_index(i)["gid"] == gid then
			temp:set_visible(true)
		end

		table.insert(array,temp)
		scroll:addChild(temp:getLayer() , temp)

	end
	this.layer:addChild(scroll:getLayer())
	
	
	-- 初始界面
	for i = 1 , count do 
		if gid == DATA_Formation:get_index(i)["gid"] then
			scroll:setIndex(i)
			childLayer = PulseInfo:new(i):getLayer()
			this.layer:addChild(childLayer)
			break
		end
	end


	return this
end

function Pulselayer:getLayer()
	return self.layer
end

return Pulselayer

