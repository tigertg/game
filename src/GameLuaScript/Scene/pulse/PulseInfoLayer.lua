local PulseInfolayer = {
	layer
}

local Config_General = requires(IMG_PATH , "GameLuaScript/Config/Hero")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config_Propertys = requires(IMG_PATH , "GameLuaScript/Config/Prop")


function PulseInfolayer:new(index)
	local this = {}
	setmetatable(this,self)
	self.__index  = self	
	this.layer = display.newLayer()
	local hero_bg = display.newSprite(IMG_PATH.."image/scene/Pulse/hero_bg.png")
	setAnchPos(hero_bg, (this.layer:getContentSize().width - hero_bg:getContentSize().width)/2,120)
	this.layer:addChild(hero_bg)
	
	local hero_pdata = DATA_Pulse:get_data()
	local hero_pulse = hero_pdata["pulse"]
	
	local hero_data = DATA_Formation:get_index(index)
	local cid = tostring(DATA_General:get(hero_data["gid"] , "cid"))
	local name = display.strokeLabel( DATA_General:get(hero_data["gid"] , "name") , 140 , 568 , 24 , ccc3( 0xac , 0x25 , 0x10 )  )
	
	
	this.layer:addChild( name )
	
	local name_n = display.strokeLabel( Config_General[cid]["bieming"] or "" , 155 + name:getLabel():getContentSize().width , 568 , 20 , ccc3( 0xee , 0x79 , 0x1b )  )
	
	this.layer:addChild( name_n )
	
	this.layer:addChild( display.strokeLabel( "Lv " .. DATA_General:get(hero_data["gid"] , "lv") , 170 + name:getLabel():getContentSize().width +  name_n:getLabel():getContentSize().width , 570 , 20 , ccc3( 0xac , 0x25 , 0x10 )  ) )
	
	local y = 520
	for i = 1 , Config_General[cid]["star"] do
		local star_sprite = display.newSprite(IMG_PATH .. "image/common/star.png")
		setAnchPos(star_sprite , 390 ,y)
		this.layer:addChild(star_sprite)
		
		y = y - 30
	end
	
		--等阶
	local stageNum = DATA_Bag:get("general", hero_data["gid"], "stage")
	if stageNum > 0 then
		local stage = display.newSprite(COMMONPATH.."stage/"..stageNum..".png")
		setAnchPos(stage, 390, y - 5)
		this.layer:addChild(stage)
	end
	
	local array_point = {
					{107,350},
					{49,263},
					{152,226},
					{37,153},
					{159,105}
	}
	local font = {"天庭","任脉","督脉","带脉","冲脉"}
	local font_point = {
					{109,298},
					{81,232},
					{143,186},
					{72,112},
					{156,124}
	}
	local lv_point = {
					{0,23},
					{90,23},
					{180,23},
					{0,0},
					{91,0}
	}

	
	for k,v in pairs(array_point) do
		if tonumber(k) <= hero_pdata["cur_max"] then
			if next(hero_pulse) == nil then
				local gro = display.newSprite(IMG_PATH.."image/scene/Pulse/Groove.png")
				setAnchPos(gro, 15 + hero_bg:getContentSize().width/4 + v[1],120 + v[2])
				this.layer:addChild(gro)
			else
				local is_stone = false
				local v1 = {}
				for k1,vx in pairs(hero_pulse)do
					if tonumber(k) == tonumber(vx["index"]) then
						is_stone = true
						v1 = vx
					end
				end
				
				if is_stone == true then
					local lv_img = display.newSprite(IMG_PATH.."image/scene/Pulse/Groove.png")
					setAnchPos(lv_img, 15 + hero_bg:getContentSize().width/4 + array_point[v1["index"]][1],120 + array_point[v1["index"]][2])
					this.layer:addChild(lv_img)
					
					local gem = display.newSprite(IMG_PATH.."image/scene/Pulse/"..v1["cid"]..".png")
					setAnchPos(gem, 15 + hero_bg:getContentSize().width/4 + array_point[v1["index"]][1],120 + array_point[v1["index"]][2])
					this.layer:addChild(gem)
					
					local lv = getstoneConfig(v1["exp"])
					local lv_img = display.newSprite(IMG_PATH.."image/scene/Pulse/lv"..lv..".png")
					setAnchPos(lv_img,15 + hero_bg:getContentSize().width/4 + array_point[v1["index"]][1] + (gem:getContentSize().width - lv_img:getContentSize().width)/2 + 6,130 + array_point[v1["index"]][2]  -(gem:getContentSize().height - lv_img:getContentSize().height)/2 )
					this.layer:addChild(lv_img)
					
					
					
					
					local font_desc = display.strokeLabel( Config_Property[Config_Propertys[v1["cid"]..""]["effect"]].." +"..getConfig("data_stonefigure",v1["cid"])[lv..""] , 40  + lv_point[v1["index"]][1],120 + lv_point[v1["index"]][2] , 18 , ccc3( 0x00 , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
					this.layer:addChild( font_desc )
				else
					local gro = display.newSprite(IMG_PATH.."image/scene/Pulse/Groove.png")
					setAnchPos(gro, 15 + hero_bg:getContentSize().width/4 + v[1],120 + v[2])
					this.layer:addChild(gro)
				end
				
			end
			
		else
			local gro = display.newSprite(IMG_PATH.."image/scene/Pulse/grua.png")
			setAnchPos(gro, 15 + hero_bg:getContentSize().width/4 + v[1],120 + v[2])
			this.layer:addChild(gro)
		end
		local font_img = display.newSprite(IMG_PATH.."image/scene/Pulse/font"..k..".png")
		setAnchPos(font_img, 18 + hero_bg:getContentSize().width/4 + v[1],90 + v[2] )
		this.layer:addChild(font_img)
	end
	
	
	local box = display.newSprite(IMG_PATH.."image/scene/Pulse/pro.png")
	setAnchPos(box, hero_bg:getContentSize().width/4,120 )
	this.layer:addChild(box)
		
	local pro_add = display.newSprite(IMG_PATH.."image/scene/Pulse/pro_add.png")
	setAnchPos(pro_add, 33,110 + box:getContentSize().height)
	this.layer:addChild(pro_add)
	--[[for k,v in pairs(font_point) do
		local font_gro = display.strokeLabel( font[k] , 15 + hero_bg:getContentSize().width/4 + v[1],140 + v[2], 20 , ccc3( 0x2c , 0x00 , 0x00 ), 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
		this.layer:addChild( font_gro )
	end
	]]
	this.layer:setTouchEnabled(true)
	function this.layer:onTouch(type, x, y)
		if type == CCTOUCHBEGAN then
			for k,v in pairs(array_point) do
				if x > 15 + hero_bg:getContentSize().width/4 + v[1] and x < 15 + hero_bg:getContentSize().width/4 + v[1] + 44 and y > 120 + v[2] and y < 120 + v[2] + 44 then
					if tonumber(k) <= hero_pdata["hole_max"] then
						if tonumber(k) <= hero_pdata["cur_max"] then
							local is_stone = false
							for k1,v1 in pairs(hero_pulse)do
								if tonumber(k) == tonumber(v1["index"]) then
									is_stone = true
								end
							end
							
							if is_stone == true then
								switchScene("mosaic",{gid = hero_data["gid"],index = k,mode = 2})
							else
								switchScene("mosaiclist",{gid = hero_data["gid"],index = k})
							end
						else
							if k <= hero_pdata["hole_max"] then
								KNMsg:getInstance():flashShow("当前穴位需要英雄达到"..(k-1)*hero_pdata["next_stage"].."阶开放")
							else
								for i = 1 ,5 do
									local data_up = DATA_Uplevel:get(i.."")
									if tonumber(data_up["pulse_max"]) >= tonumber(k) then
										KNMsg:getInstance():flashShow(i.."星英雄可开启")
										break
									end
								end
							end
							
						end
					else
						for i = 1 ,5 do
							local data_up = DATA_Uplevel:get(i.."")
							if tonumber(data_up["pulse_max"]) >= tonumber(k) then
								KNMsg:getInstance():flashShow(i.."星英雄可开启")
								break
							end
						end
					end
				end
			end
		elseif type == CCTOUCHMOVED then

		elseif type == CCTOUCHENDED then
		
		end
		return true
	end
	this.layer:registerScriptTouchHandler(function(type,x,y) return this.layer:onTouch(type,x,y) end,false,-132,false)
	return this
end

function getstoneConfig(exp_data)
	local data = getConfig("data_stoneexp")
	dump( exp_data )
	local lv = 0
	for k,v in pairs(data)do
		if tonumber(k) == 10 then
			lv = tonumber(k)
			break
		else
			if exp_data >= v and exp_data < data[(tonumber(k)+ 1)..""] then
				lv = k
				break
			end
		end
	end
	return lv
end

function PulseInfolayer:getLayer()
	return self.layer
end

return PulseInfolayer
