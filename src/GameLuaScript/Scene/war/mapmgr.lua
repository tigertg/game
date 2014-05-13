local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local Role = requires(IMG_PATH, "GameLuaScript/Scene/war/role")
local PATH = IMG_PATH.."image/scene/war/"

local L, M, R = 50, 212, 375
local base, space = 10, 130 
local mapPos = {
		{	
			{M - 30, 20,{2}},                    --1
			{M, base + space,{3,4,5}},                  --2
			{L, base + space * 2,{4,6}},                --3
			{M, base + space * 2,{5,7}},               --4
			{R, base + space * 2,{8}},                  --5
			{L, base + space * 3,{9}},                  --6
			{M, base + space * 3,{10}},                 --7 
			{R, base + space * 3,{11}},                 --8
			{L, base + space * 4,{10,12}},               --9
			{M, base + space * 4,{11,12}},                --10
			{R, base + space * 4,{12}},                 --11
			{M, base + space * 5,{13}},                  --12
			{M - 30, base + space * 5 + 70,{}},         --13
		}
	}

local MapMgr = {
	baseLayer,
	mapLayer,
	items,
	mapId,
	offsetX, -- 在据点的偏移
	offsetY,
	baseX,   --在大本营的偏移
	baseY,
	fightAni
}

function MapMgr:new(params)
	local this = {}
	self.__index = self
	setmetatable(this, self)
	this.params = params or {}
	this.baseLayer = display.newLayer()
	this.items = {}
	this.mapId = 1
	
	this:createMap()
	return this
end

function MapMgr:createMap()
	if self.mapLayer then
		self.baseLayer:removeChild(self.mapLayer, true)
	end
	self.mapLayer = display.newLayer()

	local map = self["map"..self.mapId](self, self.params.stat)
	self.mapLayer:addChild(map)
	
	self.baseLayer:addChild(self.mapLayer)
end

function MapMgr:map1(init)
	local layer = display.newLayer()
	local my = DATA_User:get("uid")..""
	
	local pos = mapPos[1] 

	for i = 1, #pos do
		local point
		if i == 1 or i == #pos then
			local str
			if i == 1 then
				str = "self_supreme.png"
			else
				str = "enemy_supreme.png"
			end
			--我方大本营
			point = KNBtn:new(PATH, {str}, pos[i][1], pos[i][2], {
				callback = function()
					if (init[my].group == 1 and i == 1) or (init[my].group == 2 or i == #pos) then
						HTTP:call("gangbattle", "move", {point = i, battle_id = self.params.battle_id}, {
							no_loading = true,
							success_callback = function()
--								self.items[my]:move(pos[i][1] + point:getWidth() / 2, pos[i][2] + point:getHeight() / 2, layer)
							end
						})
					end
				end})
			self.baseX = point:getWidth() / 2
			self.baseY = point:getHeight() / 2
		else
			point = KNBtn:new(PATH, {"pt_empty.png", "pt_our.png"}, pos[i][1], pos[i][2], {
				callback = function()
					if self.items[my]:isMoving()  then
					else
						HTTP:call("gangbattle", "move", {point = i, battle_id = self.params.battle_id}, {
							no_loading = true,
							success_callback = function()
--								self.items[my]:move(pos[i][1] + point:getWidth() / 2, pos[i][2] + point:getHeight() / 2, layer)
							end
						})
					end
				end
			})
			self.offsetX = point:getWidth() / 2
			self.offsetY = point:getHeight() / 2
		end	
		layer:addChild(point:getLayer())
		
		local data = pos[i][3]
		for j = 1, #data do
			local line = display.newSprite(PATH.."map_line.png")
			setAnchPos(line, pos[i][1] + point:getWidth() / 2 + line:getContentSize().height / 2, pos[i][2] + point:getHeight() / 2.5)
			layer:addChild(line, -1)
			if pos[data[j]][1] - pos[i][1] == 0 or i == 1 or i == 12 then  --垂直旋转90度
				line:setRotation(-90)
				if i == 1 then
					setAnchPos(line,pos[i][1] + 5 + point:getWidth() / 2 + line:getContentSize().height / 2, pos[i][2] + point:getHeight() / 2.5)
				elseif i == 12 then
					setAnchPos(line,pos[i][1] + point:getWidth() / 2 + line:getContentSize().height / 2, pos[i][2] + point:getHeight() / 2.5 - 20)
				end
			elseif pos[data[j]][2] == pos[i][2] then  --横向连接
			else  --根据位置旋转一定的角度
				local rotate = math.deg(math.atan((pos[data[j]][2] - pos[i][2]) / (pos[data[j]][1] - pos[i][1]))) - 90
				if pos[data[j]][1] > pos[i][1] then
					rotate = rotate + 10
				else
					rotate = rotate - 10
				end
				line:setRotation(rotate)
				line:setScaleX(1.2)
			end
		end
	end
	
	dump(init)
	for k, v in pairs(init) do
		if v.stat == "hold" then
			if v.data == 1 or v.data == #pos then
				self.items[k] = Role:new(pos[2][1] + self.offsetX, pos[v.data][2] + self.baseY, 3, v)	
			else
				self.items[k] = Role:new(pos[v.data][1] + self.offsetX, pos[v.data][2] + self.offsetY, 2, v)	
			end
		elseif v.stat == "move" then
			self.items[k] = Role:new(pos[v.data[1]][1] + self.offsetX, pos[v.data[1]][2] + self.offsetY,1, v)
		end
		layer:addChild(self.items[k]:getLayer())
	end
	return layer
end

function MapMgr:mapLogic(data)
	print("------------------")
	dump(data)
	print("________________")
	local showBattle, x, y
	local pos = mapPos[self.mapId]
	--对于所有改变的状态循环处理
	for k, v in pairs(data.change_stat) do
		if v.stat == "move" then
			if v.data[2] == 1 or v.data[2] == #pos then
				self.items[k]:move(pos[2][1] + self.offsetX, pos[v.data[2]][2] + self.offsetY)
			else
				self.items[k]:move(pos[v.data[2]][1] + self.offsetX, pos[v.data[2]][2] + self.offsetY)
			end
		elseif v.stat == "hold" then
			if v.old_data.battle then   --发生过战斗
				if self.fightAni then
					self.mapLayer:removeChild(self.fightAni, true)
					self.fightAni = nil
					showBattle = false
				end
				if v.old_data.battle.win == 0 then  --战斗失败
					self.items[k]:backHome(pos[2][1] + self.offsetX, pos[v.data][2] + self.baseY)
				else
					if v.data == 1 or v.data == #pos then
						self.items[k]:hold(pos[v.data][1] + self.offsetX, pos[v.data][2] + self.baseY, true)
					else
						self.items[k]:hold(pos[v.data][1] + self.offsetX, pos[v.data][2] + self.offsetY)
					end
				end
			else
				if v.data == 1 or v.data == #pos then
					self.items[k]:hold(pos[2][1] + self.offsetX, pos[v.data][2] + self.baseY, true)
				else
					self.items[k]:hold(pos[v.data][1] + self.offsetX, pos[v.data][2] + self.offsetY)
				end
			end
			
		elseif v.stat == "battle" then
			showBattle = true
			--这里获取战斗发生的位置,
			if v.battle.on_way == 0 then  --在据点战斗 
				local desPos 
				if type(v.old_data.data) == "number" then
					desPos = v.old_data.data
				else
					desPos = v.old_data.data[2]
				end
				
				x = pos[desPos][1]	
				y = pos[desPos][2]
				
				if desPos == 1 then
					x = x + self.baseX
					y = y + self.baseY
				elseif desPos == #pos then
					x = x + self.baseX
					y = y - self.baseY
				else
					x = x + self.offsetX
					y = y + self.offsetY
				end
				
			else
				if pos[v.old_data.data[1]][1] == pos[v.old_data.data[2]][1] then   --纵向发生的战斗
					x = pos[v.old_data.data[1]][1] + self.offsetX
					y = pos[v.old_data.data[1]][2] + self.offsetY + (pos[v.old_data.data[2]][2] - pos[v.old_data.data[1]][2]) / 2
				elseif pos[v.old_data.data[1]][2] == pos[v.old_data.data[2]][2] then --横向发生的战斗
--					x = pos[v.old_data.data[1]][1] +　self.offsetX + (pos[v.old_data.data[2]][1] - pos[v.old_data.data[1]][1]) / 2 
					x = pos[v.old_data.data[1]][1] + self.offsetX + (pos[v.old_data.data[2]][1] - pos[v.old_data.data[1]][1]) / 2
					y = pos[v.old_data.data[1]][2] + self.offsetY
				else -- 斜线上发生的战斗
					x = pos[v.old_data.data[1]][1] + self.offsetX + (pos[v.old_data.data[2]][1] - pos[v.old_data.data[1]][1]) / 2 
					y = pos[v.old_data.data[1]][2] + self.offsetY + (pos[v.old_data.data[2]][2] - pos[v.old_data.data[1]][2]) / 2
				end
			end
			
			self.items[k]:battle(x, y)
		end
	end
	
	if showBattle then
		local frames = display.newFramesWithImage(PATH .. "fight_effect.png" , 6 )
		self.fightAni = display.playFrames(x, y, frames, 0.1, {
			forever = true
		})
		self.mapLayer:addChild(self.fightAni)
	end
	
end

function MapMgr:getLayer()
	return self.baseLayer
end


return MapMgr