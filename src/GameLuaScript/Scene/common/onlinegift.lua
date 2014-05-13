-- 在线礼包
local PATH = IMG_PATH .. "image/scene/activity/"
local COMMONPATH = IMG_PATH .. "image/common/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local M = {

}


function M:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	this.content = display.newLayer()
	this.schedule = {}
	this.lin = {}
	this.isf = false
	-- 背景
	local bg = display.newSprite(COMMONPATH .."bg.png")
	setAnchPos(bg , 13 , 200)
	this.content:addChild(bg)
	-- 背景框
	local bg = display.newSprite(PATH .."bg_frame.png")
	setAnchPos(bg , 36 , 280)
	this.content:addChild(bg)

	local list_title_bg = display.newSprite(COMMONPATH .. "list_title.png")
	setAnchPos(list_title_bg , 25 , 633)
	this.content:addChild(list_title_bg)

	local title = display.newSprite(PATH .. "online_title.png")
	setAnchPos(title , 170 , 633)
	this.content:addChild(title)
	

	local closeBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"} ,  display.cx - 74 , 230 , {
		scale = true,
		priority = -130,
		front = COMMONPATH .. "colse_text.png" , 
		callback = function()
			this.layer:removeFromParentAndCleanup(true)
			for key , v in pairs(this.schedule) do 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
				v = nil
			end
		end
	}):getLayer()
	this.content:addChild(closeBtn)
	

	
	local titleInfo = {
						[1] = {"time_text.png" , 70 } ,
						[2] = {"reward_text.png" , 176 } ,
						[3] = {"state_text.png" , 320 } ,
						}
	for i = 1 , #titleInfo do
		local tempText = display.newSprite(PATH .. titleInfo[i][1])
		setAnchPos(tempText ,  titleInfo[i][2] , 285 + 270 )
		this.content:addChild(tempText)
	end
	--生成界面中数据内容
	this:createContent()
	

	--竖线1
	local completeTitle = display.newSprite(PATH .. "line.png")
	setAnchPos(completeTitle , 153 , 285 )
	this.content:addChild(completeTitle)
	--竖线2
	local completeTitle = display.newSprite(PATH .. "line.png")
	setAnchPos(completeTitle , 153 + 105 , 285 )
	this.content:addChild(completeTitle)
	
	

	-- 遮罩
	local mask = KNMask:new({item = this.content})
	this.layer:addChild( mask:getLayer() )

	
    return this
end

function M:getLayer()
	return self.layer
end

function M:createContent()
	local data = DATA_Olgift:get("olgift")
	for i = 1 , 6 do
		if self.lin[i]  then
			self.lin[i]:removeFromParentAndCleanup( true )
		end
		if not self.isf then
			self.lin[i] = self:createCell( i , data )
			setAnchPos(self.lin[i] , 44 , 512 - ( i - 1 ) * 44) 
			self.content:addChild( self.lin[i] )
		end
	end
end

function M:createCell( index ,  _data)
	
	local rewardType = { gold ="黄金" , silver = "银两" ,power = "体力" }
	local data = {}
	 data.time   = _data.conf[index .. ""].minute
	 data.reward = rewardType[ _data.conf[index .. ""].type ] .. _data.conf[index .. ""].num
	 
	 if index == _data.finish + 1 then
	 	if _data.sec < 0 then
	 		data.state = 0		--可领取
	 	else
	 		data.state = _data.sec	--倒计时未完成
	 	end  
	 else
	 	if  index < _data.finish + 1 then
		 	data.state = -1	--默认已经领取
	 	else
		 	data.state = "Timeisnot"	--时间未到
	 	end
	 end
		 
	local layer = display.newLayer()
	
	
	if index%2 == 0 then
		local bgBar = display.newSprite(PATH .. "bg_bar.png")
		setAnchPos(bgBar , 0 , 0 )
		bgBar:setScaleX( 0.98 )
		layer:addChild(bgBar) 
	end
	
	--时间
	local text = display.strokeLabel( data.time .. "分钟", 2, 0 , 16, ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 105 , dimensions_height = 30 , align = 1 } )
	layer:addChild( text )
	--奖励
	local text = display.strokeLabel( data.reward, 111 , 0 , 16, ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 105 , dimensions_height = 30 , align = 1 } )
	layer:addChild( text )
	
	--倒计时
	if  data.state.."" ~= "Timeisnot" then
		if data.state > 0  then
			--时间转换  
			local function timeConvert( value )
				local hour,min,sec
				hour = math.floor(value / 3600)
				if hour >= 1 then
					min = math.floor((value - hour * 3600) / 60)
				else
					min = math.floor(value / 60)
				end
				sec = math.floor(value % 60 )
				
				hour = hour<10 and "0"..hour or hour 
				min = min<10 and "0"..min or min 
				sec = sec<10 and "0"..sec or sec 
				return hour .. ":" .. min .. ":" .. sec
			end
			
			local countText
			local function completeHandler()
				countText:removeFromParentAndCleanup(true)
				self:createContent()
			end
			local function count()
				if data.state > 0 then
					countText:setString( timeConvert( data.state ) )
					
					self.schedule[index .. ""]= CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() 
						data.state = data.state - 1
						if data.state > 0 then
							countText:setString( timeConvert( data.state ) )
						else
							if self.schedule[index .. ""] then
								HTTP:call("olgift", "get", { index = index },{success_callback = 
								function()
									completeHandler()
								end})
								CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule[index .. ""])
								self.scehdule = nil
							end
							
						end
					end,1,false)
				else
					completeHandler()
				end
			end
			
			countText = display.strokeLabel( data.state, 303 , 0 , 16, ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 86 , dimensions_height = 30 , align = 1 } )
			layer:addChild( countText )
			count( data.state )
		end
	end
	
	--领取按钮
	local textPath = data.state == 0 and  "get.png" or ( data.state == -1 and "get_over.png" or "get_grey.png")
	local getGift = KNBtn:new( COMMONPATH , { data.state == 0 and "btn_bg.png" or "btn_bg_dis.png" }  , 220 , 0 ,
	 {
		priority = -130,
		scale = true,
		id = index,
		front = COMMONPATH .. textPath , 
		callback = function()
			HTTP:call("olgift", "receive", { index = index },{success_callback = 
				function()
					GLOBAL_INFOLAYER:refreshInfo()
					self:createContent()
				end})
		end
	})
	layer:addChild(getGift:getLayer())
	
	return layer
end
return M