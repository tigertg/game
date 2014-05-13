local LOCK, CUR, COMPLETE, RELEASE = 1, 2, 3, 4
local PATH = IMG_PATH.."image/scene/mission/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local TextField = requires(IMG_PATH, "GameLuaScript/Common/KNTextField")
--[[
	任务关卡信息，即进入任务战斗的图标，包含关卡解锁状态，关卡评分，获取宝物等信息
]]
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local LevelIcon = {
	state,
	params,
	iconLayer
}

function LevelIcon:new(kind,map,cur,params)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	this.iconLayer = display.newLayer()
	this.params = params or {}
	
	if map > cur  then
		this.state = LOCK	
	elseif map == cur then
		this.state = CUR
		if this.params.level < DATA_Mission:get("max","map_id") then
			this.state = COMPLETE
		end
	else	
		this.state = COMPLETE
	end
	

	local border,borderPress
	if this.state == LOCK then
		border =  display.newSprite(PATH.."level_bg_lock.png")
	elseif this.state == COMPLETE then
		border =  display.newSprite(PATH.."level_bg.png")
		borderPress = display.newSprite(PATH.."level_bg_press.png")
		setAnchPos(borderPress)
	else
		border =  display.newSprite(PATH.."level_bg_cur.png")
		borderPress = display.newSprite(PATH.."level_bg_cur_press.png")
		setAnchPos(borderPress)
		
		local challenge = display.newSprite(PATH.."cur.png")
		setAnchPos(challenge, 360, 8)
		this.iconLayer:addChild(challenge, 1)
		
--		
			
	end
	setAnchPos(border)
	
	
	this.iconLayer:addChild(border)
	if borderPress then
		this.iconLayer:addChild(borderPress)
		borderPress:setVisible(false)
	end
	this.iconLayer:setContentSize(border:getContentSize())
	this.layer:setContentSize(border:getContentSize())
	this.layer:addChild(this.iconLayer)


	local stateIcon, str
	if this.state == LOCK then
		stateIcon = display.newSprite(PATH.."lock.png")
		setAnchPos(stateIcon,border:getContentSize().width, 5, 1.2 )
		this.iconLayer:addChild(stateIcon)
		
		str = "hp_dis.png"
	else
		if this.state == CUR then
				--当前的关卡		
		else
			str = "state_complete.png"
		end
		
		if str then
			stateIcon = display.newSprite(PATH..str)
			setAnchPos(stateIcon,border:getContentSize().width + 3, 13,1.15)
			this.iconLayer:addChild(stateIcon)
		end
		
		if this.state == CUR then
--			local aniMask = WindowLayer:createWindow()
--			aniMask:setContentSize(CCSizeMake(border:getContentSize().width, border:getContentSize().height ))
--			setAnchPos(aniMask)
--			this.iconLayer:addChild(aniMask, 50)
--			
--			local moveLight = display.newSprite(COMMONPATH.."move_light.png")
--			setAnchPos(moveLight, -moveLight:getContentSize().width)
--			aniMask:addChild(moveLight)
--			
--			local function moveFun()
--				local action
--				action = getSequenceAction(CCMoveTo:create(1, ccp(border:getContentSize().width, 0)), CCDelayTime:create(2),CCCallFunc:create(function()
--					setAnchPos(moveLight, -moveLight:getContentSize().width)
--					moveLight:runAction(moveFun())
--					print(moveLight:getPositionX(), moveLight:getPositionY())
--				end))	
--				return action	
--			end
--			moveLight:runAction(moveFun())
		end
		
		str = "hp.png"
	end
	
	local level, mapName, name 
	if kind == "map" then
		level = getImageNum(map, COMMONPATH..str)
		setAnchPos(level,30,25)
		this.iconLayer:addChild(level)
		
		mapName = DATA_Mission:get("map",map.."")
	    name = display.strokeLabel(mapName, 0, 0, 24, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
		setAnchPos(name,border:getContentSize().width / 2, 40, 0.5, 0.5)
	else
		if getConfig("mission", this.params.level, map, "is_boss") == 1 then
			local str = PATH.."boss.png"
			if this.state == LOCK then
				str = PATH.."boss_grey.png"
			end
			local boss = display.newSprite(str)
			setAnchPos(boss, 10, 25)
			
			this.iconLayer:addChild(boss)
			
--			level = display.strokeLabel(this.params["level"].."-"..map,20,10,20)
		else
--			level = display.strokeLabel(this.params["level"].."-"..map,20,28,20)
		end 
		level = display.strokeLabel(this.params["level"].."-"..map,20,10,20)
		this.iconLayer:addChild(level)
		
		mapName = DATA_Mission:get(this.params["level"],"missions",map,"name")
	    name = display.strokeLabel(mapName, 0, 0, 24, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
		setAnchPos(name,border:getContentSize().width / 3, 40, 0.5, 0.5)
		
		if map == 1 then
			local name = display.strokeLabel(DATA_Mission:get("map", this.params.level..""), 0, 0, 24)
			this.layer:addChild(name)
			
			local des = TextField:new(getConfig("mission", this.params["level"], "map_desc"),20, 380, 5)
			this.layer:addChild(des)
			
			this.layer:setContentSize(CCSizeMake(border:getContentSize().width,border:getContentSize().height + (35 + 5) * des:getLine() ))
			
			setAnchPos(this.iconLayer,0,(35 + 5) * des:getLine())
			setAnchPos(name,this.layer:getContentSize().width / 2, this.layer:getContentSize().height - border:getContentSize().height - 30,0.5 )
			setAnchPos(des, 20, this.layer:getContentSize().height - border:getContentSize().height - des:getHeight() - 30)
			
			
		end
		
		local sx, star = 250, nil
		for i = 1,3 do 
			if i <= DATA_Mission:get(this.params.level,"missions",map,"star")  then
				star = display.newSprite(COMMONPATH.."star.png")
			else
					star = display.newSprite(COMMONPATH.."star_empty.png")
			end
			setAnchPos(star,sx,35)
			this.iconLayer:addChild(star)
			sx = sx + star:getContentSize().width + 10 
		end	
		
		local count = display.strokeLabel("挑战次数:"..DATA_Mission:get(this.params.level,"missions",map,"count").."/"..
		DATA_Mission:get(this.params.level,"missions",map,"max"), 0, 0, 15, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
		setAnchPos(count, 250 , 15 )
		this.iconLayer:addChild(count)
	end
	
	this.iconLayer:addChild(name)
--	
--
--	
--	local achieve = display.newSprite(PATH.."achieve.png")
--	setAnchPos(achieve,230,350)
--	this.layer:addChild(achieve)

	this.iconLayer:setTouchEnabled(true)
	local lastY, legal = 0, true
	this.iconLayer:registerScriptTouchHandler(
	function(type,x,y)
			local range = this:getRange()
			if range:containsPoint(ccp(x,y)) and y < this.params.parent:getY() + this.params.parent:getHeight() and y > this.params.parent:getY()  then
				if type == CCTOUCHBEGAN then
					lastY = y
					if borderPress then
						borderPress:setVisible(true)
						border:setVisible(false)
					end
				elseif type == CCTOUCHMOVED then
					if math.abs(y - lastY) > 20 then
						legal = false
						if borderPress then
							borderPress:setVisible(false)
							border:setVisible(true)
						end
					else
						if legal and borderPress then
							borderPress:setVisible(true)
							border:setVisible(false)
						end
					end
				elseif type == CCTOUCHENDED then
					if legal and  this.state ~= LOCK and this.state ~= RELEASE then
						if this.params.callback then
							this.params.callback()
						end
					end
					legal = true
					if borderPress then
						borderPress:setVisible(false)
						border:setVisible(true)
					end
				end
			else
				if type == CCTOUCHMOVED then
					if borderPress then
						borderPress:setVisible(false)
						border:setVisible(true)
					end
				end
			end
		return true
	end,false,0,false)	
	
	return this
end

function LevelIcon:getLayer()
	return self.layer
end

function LevelIcon:release()
	self.state = RELEASE
end



--获取所有父组件，取得按钮的绝对位置
function LevelIcon:getRange()
	local x = self.iconLayer:getPositionX()
	local y = self.iconLayer:getPositionY()


	local parent = self.iconLayer:getParent()
	x = x + parent:getPositionX()
	y = y + parent:getPositionY()
	while parent:getParent() do
		parent = parent:getParent()
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
	end
	return CCRectMake(x,y,self.iconLayer:getContentSize().width,self.iconLayer:getContentSize().height)
end
return LevelIcon
