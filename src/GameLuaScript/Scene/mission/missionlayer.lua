--[[
	任务模块大关卡场景，在首页点击任务按钮,或在世界地图点击关卡时进入
]]
local WIPEOPT, WIPING, WIPEEND = 1, 2, 3
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local PATH = IMG_PATH.."image/scene/mission/"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")--require "GameLuaScript/Common/KNBtn"
local LevelInfo = requires(IMG_PATH,"GameLuaScript/Scene/mission/levelinfo")
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local Config = requires(IMG_PATH, "GameLuaScript/Config/User")
local KNSlider = requires(IMG_PATH, "GameLuaScript/Common/KNSlider")
local MissionLayer = {
	layer,
	fightLayer,
	mapScroll,
	state,
	mask,
	content
}

function MissionLayer:new(data)
	local this={}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	local data = data or {}
	
	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	
	
	--生成关卡选择
	if not DATA_Mission:get("cleanup", "clock") then
		this:createLevel(data)
	else
		if DATA_Mission:get("cleanup", "clock") > 0 then
			this:createWipe(nil, nil, WIPING)
		else
			this:createWipe(nil, nil, WIPEEND)
		end
	end

	this.layer:addChild(InfoLayer:new("mission", 0, {title_text = IMG_PATH.."image/scene/mission/title.png", 
		tail_hide = true,
		closeCallback = 
		function()
			if this.state == "map"  then
				switchScene("home")				
			elseif this.state == "mission" then
				this:createLevelScroll("map")
			else
				switchScene("home")
			end
		end}):getLayer())
	return this 
end


function MissionLayer:createLevelScroll(kind,level)
	if self.mapScroll then
		self.mapScroll:removeAll()
		self.content:removeChild(self.mapScroll:getLayer(),true)
		self.mapScroll = nil
	end
	
	self.mapScroll = KNScrollView:new(0,105,480,570)
	self.state = kind
	
	local max,cur  --最大显示的关卡和当前关卡
	if kind == "map" then
		--取地图的最大值
		if DATA_Mission:get("max","map_id") + 1 > table.nums(DATA_Mission:get("map")) then
			max = table.nums(DATA_Mission:get("map"))
			cur = max
		else
			max = DATA_Mission:get("max","map_id") + 1
			cur = max - 1
		end
	else
		--取小关卡的最大值
		if level < DATA_Mission:get("max","map_id") then
			max = DATA_Mission:get(level,"mission_count")
			cur = max 
		else
			max = DATA_Mission:get("max","mission_id") + 1
			cur = max - 1
			if max > DATA_Mission:get(level,"mission_count") then
				max = DATA_Mission:get(level,"mission_count")
				cur = max 
			end
		end
	end
	
	for i = max, 1, -1 do
		local index = level or i         --若level存在说明是小关卡，不存在则是大地图
		local levelState
		local icon =  LevelInfo:new(kind,i,cur,{
			level = index,
			max = max,
			parent = self.mapScroll,
			callback = function()
				if kind == "map" then
					DATA_Mission:setByKey("current","map_id",index)
					if DATA_Mission:haveData(index) then
						self:createLevelScroll("mission", i)
					else
						HTTP:call("mission","get",{map_id = index},{success_callback=
							function()
								self:createLevelScroll("mission", i)
							end})
					end
				else
					self:createFighting(level,i)
				end
			end})
		self.mapScroll:addChild(icon:getLayer(),icon)
	end

	if kind == "map" then
		-- 新手引导
		local guide_step = KNGuide:getStep()
		if guide_step == 102 or guide_step == 210 or guide_step == 305 then
			local item_offset = 0
			if guide_step == 305 then
				item_offset = 1
			end
			local items = self.mapScroll:getItems()
			local btn = items[#items - item_offset]
			local btn_range = btn:getRange()

			KNGuide:show( btn:getLayer() , {
				x = btn_range:getMinX() + 25,
				y = btn_range:getMinY(),
			})
		end
	else
		-- 新手引导
		local guide_step = KNGuide:getStep()
		if guide_step == 103 or guide_step == 105 or guide_step == 107 or guide_step == 211 or guide_step == 213 or guide_step == 215 or guide_step == 306 then
			local item_offset = 0
			if guide_step == 105 then
				item_offset = 1
			elseif guide_step == 107 then
				item_offset = 2
			elseif guide_step == 211 then
				item_offset = 3
			elseif guide_step == 213 then
				item_offset = 4
			elseif guide_step == 215 then
				item_offset = 0
			elseif guide_step == 306 then
				item_offset = 1
			end

			local items = self.mapScroll:getItems()
			local btn = items[#items - item_offset]
			local btn_range = btn:getRange()

			KNGuide:show( btn:getLayer() , {
				x = btn_range:getMinX() + 25,
				y = btn_range:getMinY(),
				height = 75,
			})
		end
	end
	
	self.mapScroll:alignCenter()
	self.mapScroll:effectIn()
	self.content:addChild(self.mapScroll:getLayer())
end

function MissionLayer:getLayer()
	return self.layer
end

function MissionLayer:createFighting(map,level)
	if self.mask then
		self.layer:removeChild(self.mask, true)
	end
	
	self.fightLayer = display.newLayer()
	local bg = display.newSprite(PATH.."bg.png")
	setAnchPos(bg,240,425,0.5,0.5)
	self.fightLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."des_text_bg.png")
	setAnchPos(bg,240,470,0.5,0)
	self.fightLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."title_bg.png")
	setAnchPos(bg, 280, 600, 0.5)
	self.fightLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."fight_title.png")
	setAnchPos(bg, 270, 600, 0.5)
	self.fightLayer:addChild(bg)
	
	local achieve = display.newSprite(PATH.."achieve.png")
	setAnchPos(achieve,50,440)
	self.fightLayer:addChild(achieve)
	
    achieve = display.newSprite(PATH.."gift.png")
	setAnchPos(achieve,50,370)
	self.fightLayer:addChild(achieve)
	
	achieve = display.newSprite(PATH.."use_power.png")
	setAnchPos(achieve,240,575,0.5)
	self.fightLayer:addChild(achieve)
	
    achieve = display.newSprite(COMMONPATH.."separator.png")
	setAnchPos(achieve,240,400,0.5)
	self.fightLayer:addChild(achieve)
	
	local power = display.strokeLabel(getConfig("mission",map,level,"power"), 0, 0, 16, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(power,300,580)
	self.fightLayer:addChild(power)
	
	local exp = display.strokeLabel("经验:"..getConfig("mission",map,level,"exp"), 0, 0, 16, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(exp,180,450)
	self.fightLayer:addChild(exp)
	
	local silver = display.strokeLabel("银两:"..getConfig("mission",map,level,"silver"), 0, 0, 16, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(silver,300,450)
	self.fightLayer:addChild(silver)
	

--	local fame = display.strokeLabel("功勋:"..getConfig("mission",map,level,"fame"), 0, 0, 16, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
--	setAnchPos(fame,180,420)
--	self.fightLayer:addChild(fame)
	
	local wei = display.strokeLabel("威望:"..Config[DATA_User:get("lv")]["exp_a"], 0, 0, 16, ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(wei,180,420)
	self.fightLayer:addChild(wei)
	

	local desc = display.strokeLabel(
		getConfig("mission",map,level,"mission_desc"), 0, 0, 16, 
		ccc3( 0xff , 0xfb , 0xd4 ) , 2 , 
		ccc3( 0x40 , 0x1d , 0x0c ),{dimensions_width = bg:getContentSize().width - 20, dimensions_height = bg:getContentSize().height - 10, align = 0})
	setAnchPos(desc,245,470,0.5)
	self.fightLayer:addChild(desc)
	

	local gift = getConfig("mission",map,level,"award_show")
	local count = 0
	for k, v in pairs(gift) do
		count = count + 1
		local show = KNBtn:new(SCENECOMMON,{"skill_frame1.png"},80 + count * 110,330,{
			front = getImageByType(v),
			text = {getConfig(getCidType(v),v,"name"),14,ccc3(0x2c, 0, 0),ccp(0,-50)}			
		})
		self.fightLayer:addChild(show:getLayer())
	end
	
	local fightBtn = KNBtn:new(COMMONPATH,{"btn_bg_red.png","btn_bg_red_pre.png"},80,240,{
		front = PATH.."fight.png",
		scale = true,
		priority = -131,
		callback = function()
			local tempData = { map_id = map, mission_id = level}
			DATA_Mission:setCurMissionData( tempData ) --临时记录当前关卡
--			print(map)
--			print(level)
--			print(DATA_Formation:get_lenght())
--			print(DATA_Formation:getMax())
--			print(DATA_Bag:countItems("general", true))
			
			local max  = 0
			for k, v in pairs(DATA_Formation:getMax()) do
				if DATA_User:get("lv") >= v then
					if max < tonumber(k) then
						max = tonumber(k)
					end
				end 
			end	
			if DATA_Formation:get_lenght() < max and table.nums(DATA_Bag:getTable("general", nil,nil,true)) > 0 then
				local checkLevel = true
				if map < 3 then
					if map == 1 or (map == 2 and level < 3) then
						checkLevel = false
					end
				end
				if checkLevel then
					KNMsg.getInstance():boxShow("当前有英雄可上阵，是否前往上阵英雄？ 点击确定进入英雄首页，点击取消进入战斗", {
						confirmFun = function()
							if DATA_General:haveGet() then
								DATA_Formation:set_index(1)
								switchScene("hero",{gid = DATA_Formation:getCur()})
							else
								HTTP:call("general" , "get",{},{success_callback =
									function()
										DATA_General:haveGet(true)
										DATA_Formation:set_index(1)
										switchScene("hero",{gid = DATA_Formation:getCur() })
									end
								})
							end
						end,
						cancelFun = function()
							if not isBagFull() then
								self.layer:removeChild(self.mask,true)
								SOCKET:getInstance("battle"):call("mission" , "execute" , "execute" , tempData)
							end
						end
					})
					return false
				end
			end
			if not isBagFull() then
				self.layer:removeChild(self.mask,true)
				SOCKET:getInstance("battle"):call("mission" , "execute" , "execute" , tempData )
			end
		end
	})
	self.fightLayer:addChild(fightBtn:getLayer())

	-- 新手引导
	local guide_step = KNGuide:getStep()
	if guide_step == 104 or guide_step == 106 or guide_step == 108 or guide_step == 212 or guide_step == 214 or guide_step == 216 or guide_step == 307 then
		KNGuide:show( fightBtn:getLayer() , {remove = true})
	end
	
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
		scale = true,
		priority = -131,	
		callback = function()
			self.layer:removeChild(self.mask,true)
		end
	})
	self.fightLayer:addChild(cancelBtn:getLayer())
	
	local wipeBtn = KNBtn:new(COMMONPATH,{"btn_bg_red.png","btn_bg_red_pre.png"},250,240,{
		front = PATH.."wipe.png",
		scale = true,
		priority = -131,	
		callback = function()
			if DATA_Power:get("num") == 0 then
				KNMsg.getInstance():flashShow("体力不足，无法进行扫荡~！")
			else
				if DATA_Mission:get(map, "missions", level, "star") == 0 then
					KNMsg.getInstance():flashShow("该关卡未通关，不可扫荡~！")
					return false
				end
				
				if isBagFull() then
					return false
				end
				
				if DATA_Mission:get(map, "missions", level, "max") > DATA_Mission:get(map, "missions", level, "count") then
					self:createWipe(map, level, WIPEOPT)				
					
				else
					KNMsg.getInstance():flashShow("关卡已达到最大执行次数，不可扫荡~！")
				end
			end
		end
	})
	self.fightLayer:addChild(wipeBtn:getLayer())
	
	
	
	self.mask = KNMask:new({item = self.fightLayer}):getLayer()
	self.layer:addChild(self.mask)
end

function MissionLayer:createWipe(map, level, state)
	if self.mask then
		self.layer:removeChild(self.mask, true)
	end
	self.fightLayer = display.newLayer()
	
	local bg = display.newSprite(PATH.."wipe_bg.png")
	setAnchPos(bg,240,455,0.5,0.5)
	self.fightLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."title_bg.png")
	setAnchPos(bg, 280, 600, 0.5)
	self.fightLayer:addChild(bg)
	
	bg = display.strokeLabel("1：扫荡可以快速完成已通关关卡\n2：扫荡只有VIP2以上可以使用 \n3：扫荡无法获得切BOSS奖励", 0, 0, 20, DESCCOLOR, nil, nil, {align = 0})
	setAnchPos(bg, 240, 370, 0.5)
	self.fightLayer:addChild(bg)
	
	if state == WIPEOPT then  --扫荡前设置
		bg = display.newSprite(PATH.."wipe_title.png")
		local legalTimes = math.min(DATA_Power:get("num"), (DATA_Mission:get(map, "missions", level, "max") - DATA_Mission:get(map, "missions", level, "count")), 10)
		local num = 1
		
		local numText = display.strokeLabel(num, 340, 523, 20, ccc3(0x2c, 0, 0))
		self.fightLayer:addChild(numText)	
		
--		local totalTime = 300
--		local totalText = display.strokeLabel(totalTime, 250, 380, 20, ccc3(0x2c, 0, 0))
--		self.fightLayer:addChild(totalText)	 
		
		local slider = KNSlider:new( "buy" ,  {
			x = 140 , 
			y = 380 , 
			minimum = 1 , 
			maximum = legalTimes,
			value = 1 , 
			callback  = 
				function( _curIndex )
					num = _curIndex
--					totalTime = num * DATA_Mission:get("cleanusetime")
					numText:setString(num)
--					totalText:setString(timeConvert(totalTime))
				end ,
			priority = -140
		} )
		self.fightLayer:addChild( slider )
		
		--增减按钮
		local addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , 370 ,440 , {
			scale = true,
			priority = -130,
			callback = function()
				if num < 99 then
					num = num + 1
					slider:setValue( num )
				end
			end
		})
		
		local minusBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , 80 , 440 ,{
			scale = true,
			priority = -130,
			callback = function()
				if num > 1 then
					num = num - 1
					slider:setValue( num )
				end
			end
		})
		minusBtn:setFlip(true)
		
		addBtn:getLayer():setScale( 0.9 )
		minusBtn:getLayer():setScale( 0.9 )
		self.fightLayer:addChild(addBtn:getLayer())
		self.fightLayer:addChild(minusBtn:getLayer())
	
		local text = display.newSprite(PATH.."max_times.png")
		setAnchPos(text, 80, 520)
		self.fightLayer:addChild(text)
		
		text = display.strokeLabel(legalTimes, 200, 520, 20, ccc3(0x2c, 0, 0))
		self.fightLayer:addChild(text)
		
		text = display.newSprite(PATH.."times.png")
		setAnchPos(text, 280, 520)
		self.fightLayer:addChild(text)
		
		
		
--		text = display.newSprite(PATH.."rest_times.png")
--		setAnchPos(text, 130, 380)
--		self.fightLayer:addChild(text)
		
		local wipeBtn = KNBtn:new(COMMONPATH,{"btn_bg_red.png","btn_bg_red_pre.png"},150, 300,{
		front = PATH.."wipe.png",
		scale = true,
		priority = -131,	
		callback = function()
--			HTTP:call("mission", "cleanup_start", {map_id = map, mission_id = level, times = num}, {
--				success_callback = function()
--					switchScene("mission",nil,function()
--						KNMsg.getInstance():flashShow("扫荡过程中可以体验其他游戏内容，过段时间来拿去奖励吧!~")
--					end)
--				end
--			})

		HTTP:call("mission", "cleanup", {map_id = map, mission_id = level, times = num}, {success_callback = 
			function(map)
--					local json = requires(IMG_PATH , "GameLuaScript/Network/dkjson")
--					local response = io.readfile("c:\\battle7.txt")
--					response = json.decode( response )
--					DATA_Result:set( response.result )
				
				local function callBackFun()
					HTTP:call("mission" , "get",{map_id = map},{success_callback = function()
						switchScene("mission")
					end })
				end
				local tableData = { type = "mopUp" , backFun =callBackFun }
				
				local resultLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/resultLayer")
				local scene = display.getRunningScene()
				scene:addChild( resultLayer:create( tableData ) )
			end})
		end
		})
		self.fightLayer:addChild(wipeBtn:getLayer())
		
		self.mask = KNMask:new({item = self.fightLayer}):getLayer()
	elseif state == WIPING then --扫荡中
		self.state = WIPING
		bg = display.newSprite(PATH.."wiping_title.png")
		
		local back = display.newSprite(COMMONPATH.."dark_bg.png")
		setAnchPos(back, 0, 85)	
		self.layer:addChild(back)
		
		local text = display.newSprite(PATH.."rest_times.png")
		setAnchPos(text, 130, 550)
		self.fightLayer:addChild(text)
		
		local rest = DATA_Mission:get("cleanup", "clock")
		text = display.strokeLabel(timeConvert(rest),240, 552, 20, ccc3(0x2c, 0, 0))
		self.fightLayer:addChild(text)
		
		Clock:addTimeFun("wipe_clock", function()
					if rest > 0 then
						rest = rest - 1
						text:setString(timeConvert(rest))
					else
						Clock:removeTimeFun("wipe_clock")	
						
						HTTP:call("mission" , "get",{},{success_callback = function()
							switchScene("mission")
						end })
					end
				end)
				
		local propBg = display.newSprite(PATH.."prop_bg.png")
		setAnchPos(propBg, 240, 340, 0.5)
		self.fightLayer:addChild(propBg)
		
		local propInfo = {
			 {16016, 0},
			 {16017, 0}
		}
		local cur = DATA_Bag:getTable("prop", "wipetoken") or {}
		for k, v in pairs(cur) do
			for i = 1, #propInfo do
				if tonumber(v["cid"]) == propInfo[i][1] then
					propInfo[i][2] = v["num"]
					propInfo[i][3] = k
					break
				end
			end
		end	
		for i = 1, 2 do
			local prop = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, 100, 440 - (i - 1) * 90, {
				front = getImageByType(propInfo[i][1], "s"),
				other = {COMMONPATH.."egg_num_bg.png", 45, 45, 17},
				text = {{getConfig("prop", propInfo[i][1], "name"), 20, ccc3(0x2c, 0, 0), ccp(100, 0), 17},{propInfo[i][2], 14, ccc3(255,255,255), ccp(25,24), nil, 20}}
			})
			self.fightLayer:addChild(prop:getLayer())
			
			local use = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 300, 450 - (i - 1) * 80, {
				front = COMMONPATH.."use.png",
				callback = function()
					if tonumber(propInfo[i][2]) > 0 then
						HTTP:call("mission", "cleanup_subtime", {id = propInfo[i][3]}, {
							success_callback = function()
								switchScene("mission",nil, function()
									KNMsg.getInstance():flashShow("扫荡令使用成功")
								end)
							end
						} )
					else
						KNMsg.getInstance():flashShow("对不起，扫荡令不足")
					end
				end
			})
			self.fightLayer:addChild(use:getLayer())
		end
		
		local stop = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 290, {
			front = PATH.."stop.png",
			callback = function()
				KNMsg.getInstance():boxShow("取消扫荡，将返回80%的体力消耗，并且无法获得奖励！",{
					confirmFun = function()
						HTTP:call("mission", "cleanup_cancel", {}, {
							success_callback = function()
								switchScene("mission")
							end
						})
					end,
					cancelFun = function()
					end
				})
			end
		})
		self.fightLayer:addChild(stop:getLayer())
		
		
		self.mask = display.newLayer()
		self.mask:addChild(self.fightLayer)
	else  --扫荡结束
		self.state = WIPEEND
		bg = display.newSprite(PATH.."wipeend_title.png")
		
		local back = display.newSprite(COMMONPATH.."dark_bg.png")
		setAnchPos(back, 0, 85)	
		self.layer:addChild(back)
		
		local text = display.newSprite(PATH.."rest_times.png")
		setAnchPos(text, 130, 450)
		self.fightLayer:addChild(text)
		
		text = display.strokeLabel(timeConvert(0),240, 452, 20, ccc3(0x2c, 0, 0))
		self.fightLayer:addChild(text)
		
		local achieve = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 320, {
			front = PATH.."get_gift.png",
			callback = function()
				HTTP:call("mission", "cleanup_finish", {}, {success_callback = 
				function(map)
--					local json = requires(IMG_PATH , "GameLuaScript/Network/dkjson")
--					local response = io.readfile("c:\\battle7.txt")
--					response = json.decode( response )
--					DATA_Result:set( response.result )
					
					local function callBackFun()
						HTTP:call("mission" , "get",{map_id = map},{success_callback = function()
							switchScene("mission")
						end })
					end
					local tableData = { type = "mopUp" , backFun =callBackFun }
					
					local resultLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/resultLayer")
					local scene = display.getRunningScene()
					scene:addChild( resultLayer:create( tableData ) )
				end})
			end
		})
		self.fightLayer:addChild(achieve:getLayer())
		
		self.mask = display.newLayer()
		self.mask:addChild(self.fightLayer)
	end
	
	setAnchPos(bg, 270, 600, 0.5)
	self.fightLayer:addChild(bg)
	
	if state == WIPEOPT then
		local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
			scale = true,
			priority = -131,	
			callback = function()
				self:createFighting(map, level)
			end
		})
		self.fightLayer:addChild(cancelBtn:getLayer())
	end
	
	self.layer:addChild(self.mask)
end

function MissionLayer:createLevel(data, wiping)
	if self.content then
		self.layer:removeChild(self.content, true)
	end
	
	self.content = display.newLayer()
		
	if not wiping then  --正常情况
		local scrollBg = display.newSprite(COMMONPATH.."mid_bg.png")
		setAnchPos(scrollBg, 0 ,425, 0,0.5)
		self.content:addChild(scrollBg)
		
		local powerBg = display.newSprite(PATH.."power_bg.png")
		setAnchPos(powerBg,240,680,0.5)
		self.content:addChild(powerBg)
		
		local count = display.strokeLabel("体力:"..DATA_Power:get("num").."/"..DATA_Power:get("max"), 0, 0, 20,ccc3( 0x7e , 0xe8 , 0 ))
		setAnchPos(count,240,688,0.5)
		self.content:addChild(count)
		
		local addPowerBtn = KNBtn:new(COMMONPATH, {"add.png", "add_press.png"}, 350,678, {
			callback = function()
				local list
				list = SelectList:new("prop",self.viewLayer,display.newSprite(COMMONPATH.."title/prop_text.png"),{ 
					btn_opt = "use.png",
					y = 85,
					showTitle = true , 
					filter = {type = "powerdrug"},
					optCallback = function()
						list:destroy()
						HTTP:call("status", "eat", {id = list:getCurItem():getId()},{success_callback=
							function()
								KNMsg.getInstance():flashShow("使用成功，体力增加")
							end})
					end
				})
				self.content:addChild(list:getLayer() , 11)
			end
		})
		self.content:addChild(addPowerBtn:getLayer())	
		
		self:createLevelScroll(data["kind"] or "map",data["level"])
	else --进行扫荡中
		self:createWipe(nil, nil, WIPING)
	end
	
	self.layer:addChild(self.content)
end

return MissionLayer
