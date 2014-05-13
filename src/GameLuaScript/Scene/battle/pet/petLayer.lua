--[[

幻兽

]]




local M = {}
local petGroup = {} --分组宠物
local petCell = requires(IMG_PATH, "GameLuaScript/Scene/battle/pet/petCell" )
local selfPet = nil		--自己宠物
local enemyPet = nil	--敌方宠物
local logic = requires(IMG_PATH, "GameLuaScript/Scene/battle/logicLayer" )
function M:create( data )
	
	local layer = display.newLayer()
	if not data then data = {} end
	if data["p1_pet"] then	
		local petMask = display.newSprite(IMG_PATH .. "image/scene/battle/pet_mask.png")
		display.align( petMask , display.LEFT_BOTTOM , 8 ,  15 )
		layer:addChild( petMask )
		-- 创建我方幻兽
		-- 在这个layer，根据data来显示幻兽
		local selfBird = petCell:create( data["p1_pet"]  , true )
		selfBird:setDisabled( )	--禁用幻兽点击操作
		selfBird:isVisibleSp( true )--显示技能血条显示
		selfBird:setPosition( 97 , 104 )
		layer:addChild(selfBird)
		selfPet = selfBird
	end

	--敌方幻兽
	if data["p2_pet"] then
		local petMask = display.newSprite(IMG_PATH .. "image/scene/battle/pet_mask.png")
		display.align( petMask , display.LEFT_BOTTOM , 306 ,  680 )
		layer:addChild(petMask)
		
		local foeBird = petCell:create( data["p2_pet"] , false )
		foeBird:setPosition( 395 , 770 )
		foeBird:setDisabled()	--禁用幻兽点击操作
		foeBird:isVisibleSp( true )--禁止技能血条显示
		layer:addChild(foeBird)
		enemyPet = foeBird
	end	

    return layer
end
--自己一方增加努气值表现(效果不佳 弃用)
function M:addSpEff( _data , Num )
	--目标英雄
	local hero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( _data.be_atk[1].group , _data.be_atk[1].index )
	local addPoint = hero:getPositionAndSize()


	--粒子效果
	local effectTime = 1
	local path = IMG_PATH.."image/scene/battle/pet/temp.plist"
	if  io.exists(path) then
    else
        local array = string.split(path, "/")
        local str = ""
        for i = 5 ,table.getn(array) do
            if i == table.getn(array) then
               str = str ..array[i]
            else
       	       str = str ..array[i].."/"
             end
        end
         path = str
    end
    
    
    

	local startY = 60
	local startX = 55
    for i = 0 , Num do
    	local skillX , skillY = startX - 30 + i * 99 , startY - 105
		
		local releaseGrain = CCParticleSystemQuad:create(path)
		releaseGrain:setPosition( addPoint._cx , addPoint._cy )
		logic:getLayer("pet"):addChild( releaseGrain )
		
		transition.moveTo(releaseGrain, {
			time = effectTime , 
			x = skillX , 
			y = skillY ,
			easing = "SINEOUT" ,
			onComplete = function()
				releaseGrain:removeFromParentAndCleanup( true )
			end
		} )
    end

end
--刷新自已宠物怒气值
function M:selfRefreshPetSp( _data , group )

	local spValue
	if type(_data) == "table" then
		spValue = group == 1 and  _data.p1_sp or _data.p2_sp
	else
		--释放技能时 _data只会传来 0 
		spValue = _data
	end
	
	if selfPet == nil then return end
	if not spValue then
		return
	end
	
	local bars = nil
	if group == 1 then
		bars = selfPet:getSkillBtns()
		--宠物怒气刷新表现(只有自己一方才有)  此效果暂时无用
--		if spValue ~= 0 and _data.be_atk[1].group == 1 then
--			M:addSpEff( _data , #bars )
--		end
	elseif group == 2 then
		--敌方宠物不做改动
		if enemyPet then
			bars = enemyPet:getSkillBtns()
		end
	end
	
	if bars then
		for i = 1 , #bars do
			bars[i]:setCurValue( spValue )
		end
	end


--	local btns = selfPet:getSkillBtns()
	--设置技能按钮是否可操作
--	for i = 1 , #btns do
--		if bars[i]:getPercent() >= 100  then
--			btns[i]:setDisabled( false )
--		else
--			btns[i]:setDisabled( true )
--		end
--	end
end
--获取对应组宠物数据
function M:getPetData( _group )
	local tempData = nil
	
	if tonumber( _group ) == 1 then
		if selfPet then
			tempData = selfPet:getData()
		else
			return nil
		end
	else
		if enemyPet then
			tempData = enemyPet:getData()
		else
			return nil
		end
	end
	
	return tempData 
end
--展示加成效果
function M:showMarkup( _params )
	local params = _params or {}
	
	audio.playSound(IMG_PATH .. "sound/atk_skill.mp3")
	
	local selfData = DATA_Battle:get("report")["prepare"]["p1_pet"]
	local enemyData = DATA_Battle:get("report")["prepare"]["p2_pet"]
	--执行动画效果
	local function showAction( _data , group )
		local effSprite
		local effFrames = display.newFramesWithImage( IMG_PATH.."image/scene/battle/pet/markup_eff.png" , 4 )
		effSprite =display.playFrames( 0  , 0  , 
										effFrames ,
										 0.2 ,
										  { 
										  	delay = 0.01,
										  	onComplete =
											 function() 
												effSprite:removeFromParentAndCleanup( true ) 
												
												if group == 2 then
													if params.overHandler then params.overHandler() end
													return
												end
												if enemyData and enemyData.attach then
													audio.playSound(IMG_PATH .. "sound/atk_skill.mp3")
													showAction( enemyData.attach , 2 )
												else
													if params.overHandler then params.overHandler() end
												end
											 end
											 } )
											 
											 
		setAnchPos( effSprite , display.cx  , group == 1 and 255 or 580 , 0.5 , 0.5 )
		logic:getLayer("effect"):addChild( effSprite )
		
		local function createAddSp( key , value )
		
			local attrib = display.newSprite( IMG_PATH.."image/scene/battle/pet/".. key .. ".png")
			local addNum = getImageNum( value ,  COMMONPATH .. "hp.png" )
			
			--加成数字
			local addX = attrib:getContentSize().width + 2 
			setAnchPos( addNum , addX , 12 , 0 , 0 )
			attrib:addChild( addNum )
			
			local totleWidth = addX + addNum:getContentSize().width + 2
			return attrib , totleWidth 
		end
		
		local merge = display.newLayer()
		local curHeight = 0
		for key , v in pairs( _data ) do
			local curImage , curWidth =  createAddSp( key , v )
			curHeight = curHeight + curImage:getContentSize().height + 8
			setAnchPos( curImage , - curWidth/2 , curHeight , 0 , 0.5 )
			merge:addChild( curImage )
		end
		setAnchPos( merge , display.cx , group == 1 and 200 or 525 , 0 , 0 )
		logic:getLayer("effect"):addChild( merge )
		
		--[[特效开始]]
		merge:setScale(0.1)
		transition.scaleTo(merge, {
			time = 0.2,
			scale = 2.5,
		})
		transition.scaleTo(merge, {
			delay = 0.2,
			time = 0.2,
			scale = 1,
		})
		
		transition.moveTo(merge, { 
			delay = 0.6 , 
			time = 0.4, 
			x = display.cx ,
			y = group == 1 and 200 or 525 ,
			onComplete = function()
				merge:removeFromParentAndCleanup(true)	-- 清除自己
			end})
			
	end

	if selfData and selfData.attach then
		showAction( selfData.attach , 1 )
	else
		if params.overHandler then params.overHandler() end
	end
	
end
return M
