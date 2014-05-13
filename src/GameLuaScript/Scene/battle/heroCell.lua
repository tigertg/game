--[[

卡牌类

]]

local M = {}
local heros = {}

local hpBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

--[[获取对象]]
function M:get( group , index )
	if heros[group] == nil or heros[group][index] == nil then return nil end
	
	return heros[group][index]
end


--[[数据初始化 清空所有数据]]
function M:init( first )
	if first then heros = {} end

	local temp_heros = {}
	for i = 1 , 2 do			-- 两方
		temp_heros[i] = {}
		for j = 0 , 3 do		-- 上阵4人
			if heros[i] ~= nil and heros[i][j] ~= nil then
				heros[i][j]:removeFromParentAndCleanup(true)
				heros[i][j] = nil
			end

			temp_heros[i][j] = nil
		end
	end

	heros = temp_heros
end


--[[清空单个数据]]
function M:clear( group , index )
	if heros[group][index] then
		heros[group][index]:removeFromParentAndCleanup(true)
		heros[group][index] = nil
	end
	
	local isExsit = false	--当前组是否全部死亡
	
	for i = 0 , 4 do
		if heros[group][i] then
			isExsit = true
			break
		end
	end
	if not isExsit then
		local scene = display.getRunningScene()
		local selectMask = scene:getChildByTag("899")
		
		if selectMask then
			scene:removeChild(selectMask , true)
		end
		logic:resume("select")
	end
	
	return true
end


--[[生成对象]]
function M.new( data , param )
	if type(param) ~= "table" then param = {} end
	local clickCallback = param.click or nil
	local selectFun = nil	--只用于宠物选择
	-- 容器
	local hero = display.newLayer()
	-- local hero = CCLayerColor:create( ccc4(255 , 255 , 255 , 100) )


	-- 英雄的数据
	local _data = data
	local hero_group = _data["_group"]
	local hero_index = _data["_index"]
	local curCid = data.cid or ( getConfig( getCidType( data.npc_id ) ,data.npc_id ,"gid" ) ) 
	local curType = getCidType( curCid )

	-- 英雄背景图片
	local bgColorFrame = display.newSprite(IMG_PATH.."image/scene/battle/role/role_bg.png")
	display.align(bgColorFrame , display.LEFT_BOTTOM , 0 , 0)
	hero:addChild(bgColorFrame)

	-- 获取大小
	local frameSize = bgColorFrame:getContentSize()
	hero:setContentSize( CCSize(frameSize.width , frameSize.height ) )
	
	--特殊英雄	
	if getConfig( curType , curCid , "special" ) == 1 then		
		hero:addChild( display.newSprite( IMG_PATH.."image/scene/battle/role/special_frame.png" , -6 , 0 , 0 , 0 ) )
	end
	
	-- 英雄图片
	local heroImage = display.newSprite( getImageByType(data.cid or data.npc_id , "m") )
	local bgSize = bgColorFrame:getContentSize()
	display.align(heroImage , display.CENTER , bgSize.width / 2 + 2, bgSize.height / 2 )
	-- heroImage:setPosition( 0 , 10 )
	hero:addChild(heroImage)
	
	local tempValue = math.random( 1 , 5 )
	local maskSp = display.newSprite(IMG_PATH.."image/scene/battle/role/mask"..data.star..".png")
	display.align(maskSp , display.LEFT_BOTTOM , 6 , 6 )
	hero:addChild(maskSp)
	
	-- 血条
	local hp_bar = hpBar:new("hp" , 0 , 0 , { barOffset = -10 , isOnlyCur = true , curValue = data.hp , maxValue = data.org_hp , textSize = 14 , icon = "icon"} )
	-- hp_bar:setPosition( -47 , -44 )
	display.align(hp_bar , display.LEFT_BOTTOM , 5 , 31 )
	hp_bar:setIsShowText( true )
	hero:addChild(hp_bar)

	--血条Icon上文字
	local lvText
	if isset( data , "lv" ) then
		lvText = CCLabelTTF:create( data.lv , FONT ,15)
	else
		lvText = CCLabelTTF:create( "20" , FONT , 15)
	end

	hero:addChild(lvText)
	lvText:setColor(ccc3( 253 , 252 , 172 ))
	lvText:setPosition( hp_bar.x + 14 , hp_bar.y )
	
	--英雄星级
	local heroStarNum = getConfig( curType , curCid , "star" )
	for i = 1 , heroStarNum do
		local starSp = display.newSprite(IMG_PATH.."image/scene/battle/hero_star.png")
		setAnchPos( starSp , 51 - heroStarNum * 7 + i * 14 , 18 , 0.5 , 0.5 )
		hero:addChild( starSp )
	end
	
	if data.role ~= 0 then
		local jobSp = display.newSprite(IMG_PATH.."image/scene/battle/job".. data.role..".png")
		setAnchPos( jobSp , 6 , 121 )
		hero:addChild(jobSp)
	end
	
	--如果有附加状态则生成附加状态数据
	if data.status then
		for key , v in pairs( data.status ) do
		 	local  flagSp = display.newSprite(IMG_PATH.."image/scene/battle/pet/eff_flag/"..key.."_flag.png")
			--给目标英英雄添加 效果数据
			_data[key..""] = { keep = v.keep ,  flag = flagSp}
			local lockSpSize = flagSp:getContentSize()
			flagSp:setPosition(lockSpSize.width / 2 - 5 , lockSpSize.height / 2 )
			hero:addChild( flagSp )
		end
	end
	

	-- 点击区域记录
	local rect = CCRectMake(0 , 0 , frameSize.width , frameSize.height)

	--[[------------ 对外接口 ------------]]
	--[[重置 setPosition 接口]]
	local old_setPosition = hero.setPosition
	local newX = nil
	local newY = nil
	function hero:setPosition(x , y)
		newX = x
		newY = y
		
		rect = CCRectMake(x , y , frameSize.width , frameSize.height)
		old_setPosition(hero , x , y)
	end

	--[[获取卡牌的位置和尺寸]]
	function hero:getPositionAndSize()
		local hero_x , hero_y = hero:getPosition()
		-- local hero_size = hero:getContentSize()
		local hero_width = frameSize.width
		local hero_height = frameSize.height

		return {
			_x = hero_x,
			_y = hero_y,
			_cx = hero_x + hero_width / 2,
			_cy = hero_y + hero_height / 2,
			_width = hero_width,
			_height = hero_height,
		}
	end
	
	--[[设置英雄数据]]
	function hero:setData( key , value )
		_data[key] = value
	end

	--[[获取英雄数据]]
	function hero:getData( key )
		if key ~= nil then return _data[key] end

		return _data
	end

	--[[刷新英雄卡牌血量]]
	function hero:refreshViewHp()
		hp_bar:setCurValue( _data["hp"] , false )
	end

	function hero:setClickCallback(callback)
		clickCallback = callback
	end
	
	--设置宠物选择回调
	function hero:setSelectFun(callback)
		selectFun = callback
	end
	

	

	-- 存储数据
	if heros[hero_group] == nil then heros[hero_group] = {} end
	heros[hero_group][hero_index] = hero


	-- 点击事件
	local function onTouch(eventType , x , y)
	    if eventType == CCTOUCHBEGAN then
	    	-- 判断是否点中了这张卡牌
	    	if rect:containsPoint( ccp(x , y) ) then
	    		return true
	    	else
	    		return false
	    	end
	    end
	    if eventType == CCTOUCHMOVED then return true end

	    if eventType == CCTOUCHENDED then
	    	-- 点击回调函数
	    	if selectFun then
	    		selectFun( _data  )
	    		transition.blink(hero, { time = 1 , num = 4 })

	    		
				local function tipEff()
					local frames = display.newFramesWithImage( COMMONPATH .. "btn_tip.png" , 7 )
					local btnTip 
					btnTip = display.playFrames(
						0 , 0, 
						frames,
						0.15,
						{
							onComplete = function()
							
								hero:setVisible( true )
								btnTip:removeFromParentAndCleanup(true)	-- 清除自己
							end
						}
					)
					setAnchPos( btnTip , frameSize.width / 2 , frameSize.height / 2 , 0.5 , 0.5)
					-- 添加到 特效层
					hero:addChild( btnTip )
				end
				tipEff()
	    		selectFun = nil 
	    	else
		    	if clickCallback then clickCallback(_data) end
	    	end
	    	
	        return true
	    end

	    return false
	end

	heros[hero_group][hero_index]:setTouchEnabled( true )
	heros[hero_group][hero_index]:registerScriptTouchHandler(onTouch)

	return heros[hero_group][hero_index]
end


return M
