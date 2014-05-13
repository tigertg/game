--[[

		跳过游戏层

]]


local M = { targetLayer }
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local logicLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local bgLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/bgLayer")
local isShow = false
local isDisabled = false	--是否禁止拖动 ，主要用于slide效果,防止在滑动时跳过按钮移动
local PATH = IMG_PATH .. "image/scene/battle/"
local targetLayer
function M:create( param )
	if type( param ) ~= "table" then param = {} end
	
	local content = display.newLayer()
	targetLayer = nil
	
	if DATA_Battle:getMod() == "mission"  then	--关卡
		local curMission = DATA_Mission:getCurMissionData()
		local starNum = DATA_Mission:get( curMission.map_id , "missions" , curMission.mission_id , "star" )
		if starNum == 0 then return content end
	elseif DATA_Battle:getMod() == "insequip" then	--忠义堂
		local curData = DATA_Instance:getCurEquipData()
		local maxData = DATA_Instance:get( "equip" , "current")
		local isShow = true

		maxData.map_id = tonumber(maxData.map_id)
		maxData.ins_id = tonumber(maxData.ins_id)
		if curData.map_id == maxData.map_id then
			if  curData.ins_id > maxData.ins_id then return content end
		elseif curData.map_id > maxData.map_id then
			return content
		end
	else
		return content
	end

	--跳出游戏按钮添加
	local layer = display.newLayer()

	local oldOpoint = {x = 0 , y = 0 }		--存储 第一次触屏 坐标
	
	
	
	local skipX = -( display.width )
	

	local function skipHandler()
		--还原 跳过按钮坐标
		setAnchPos( targetLayer , skipX , display.cy - 23 )
		logicLayer:resume("skip")
		--暂停战斗
		logicLayer:pause( "end" )
		
		--设置跳出值  防止 slide 效果报错
		bgLayer:setIsSkip( true )
	end
	--跳过按钮
	local norBtn = KNBtn:new( IMG_PATH.."image/scene/battle/" , { "skip1.png" , "skip2.png" } , skipX , display.cy - 23  ,{ front =IMG_PATH.."image/scene/battle/skip_text.png" , callback =  skipHandler })
	--拖动操作
	local step --记录拖动长度
	local function onTouch(eventType , x , y)
		if isDisabled then return false end
		
	    if eventType == CCTOUCHBEGAN then
	    	step = 0
			oldOpoint.x = x
			oldOpoint.y = y
			if not isShow then
				setAnchPos( targetLayer , skipX , display.cy - 23 )
			end
	    	return true
	    end
	    if eventType == CCTOUCHMOVED then
	    	step = x - oldOpoint.x
	    	if not isShow then
	    		setAnchPos( targetLayer , skipX + step , display.cy- 23 )
	    	end
	    	return true 
	    end

	    if eventType == CCTOUCHENDED then
	    	oldOpoint = {x = 0 , y = 0 }
			if step > display.cx then
				isShow = true
				logicLayer:pause("skip")
				transition.moveTo(targetLayer , { time = 0.4 , easing = "BOUNCEOUT" , x = display.cx - 65 ,  y = display.cy - 23} )
			else
				isShow = false
				logicLayer:resume("skip")
				transition.moveTo(targetLayer , { time = 0.4 , x = skipX , y = display.cy -23  } ) 
			end
	        return true
	    end
	    return false
	end
	layer:setTouchEnabled( true )
	layer:registerScriptTouchHandler( onTouch )

	content:addChild(layer)
	
	
	targetLayer = norBtn:getLayer()
	local skipBtnBg = display.newSprite( IMG_PATH.."image/scene/battle/skip_bg.png" , 50 , 23 , 0.5 , 0.5 )
	skipBtnBg:setVisible( false )
	targetLayer:addChild( skipBtnBg , -1 )
	content:addChild(targetLayer)
	
	
	local skipFlag = KNBtn:new( PATH , { "skip_flag.png" } , display.width-15 , -20 , {
		priority = -130 ,
		scale = true ,
		callback = function()
			if not isShow then
				isShow = true
				logicLayer:pause("skip")
				transition.moveTo(targetLayer , { time = 0.4 , easing = "BOUNCEOUT" , x = display.cx - 65 ,  y = display.cy - 23 } )
				skipBtnBg:setVisible( true )
			else
				isShow = false
				logicLayer:resume("skip")
				transition.moveTo(targetLayer , { time = 0.4 , x = skipX , y = display.cy - 23 } ) 
				skipBtnBg:setVisible( false )
			end
		end
	}):getLayer()
	targetLayer:addChild( skipFlag )
	
	--还原按钮

    return content
end


function M:init()
	if targetLayer then
		logicLayer:resume("skip")
		transition.moveTo(targetLayer , { time = 0.4 , x =  -( display.width ) , y = display.cy - 23 } ) 
	end
end

--设置是否上禁用拖动
function M:setIsDisabled( _b )
	isDisabled = _b
	--如果设置禁止操作时，将按钮移出屏幕
	if isDisabled then
		M:init()
	end
end

function M:getIsDisabled()
	return isDisabled
end

return M
