--[[

		人物信息展示

]]
local M = {}




local PATH = IMG_PATH .. "image/scene/battle/hero_info/"
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
function M:new( _data )
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	if not _data then
		return
	end
	
	logic:pause("info")
	
	this.layer = display.newLayer()
	local bg = display.newSprite( PATH .. "bg.png" )
	setAnchPos( bg , display.cx , display.cy , 0.5 , 0.5 )
	this.layer:addChild( bg )

	--人物图像
	local cid = _data.cid ~= nil and _data.cid  or _data.npc_id
	local roleImage = this:showBigImage( cid , 2 )
	roleImage:setPosition( 160 , 503 )
	
	if tonumber( _data.role ) ~= 0 then
		local jobFlag = display.newSprite(  COMMONPATH .. "job" .. _data.role .. ".png" )
		setAnchPos(jobFlag , -120 , 70 )
		roleImage:addChild( jobFlag )
		
		local restrain = { 
							["1"] = "战斗中人杰克英豪" , 
							["2"] = "战斗中鬼雄克人杰" , 
							["3"] = "战斗中英豪克鬼雄" , 
							}
		local tempText = display.strokeLabel( restrain[ _data.role .. "" ]  , 86 - 22 , 682  , 24 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 127 + 71 , dimensions_height = 30 , align = 0 } )
		this.layer:addChild( tempText )
	end
	
	this.layer:addChild( roleImage )
	
	--等阶
--	if  _data._group == 1 then
	if _data["stage"]  and _data["stage"] > 0 then
		local stage = display.newSprite(COMMONPATH.."stage/".. _data["stage"] .. ".png")
		setAnchPos( stage , 76 , 90 )
		roleImage:addChild(stage)
	end
--	end
	
	local title_top_l  = display.newSprite( PATH .. "line_long.png" )
	local title        = display.newSprite( PATH .. "title.png" )
	local title_down_l = display.newSprite( PATH .. "line_long.png" )
	
	setAnchPos( title_top_l  , display.cx , 777 , 0.5 , 0.5 )
	setAnchPos( title        , display.cx , 753 , 0.5 , 0.5 )
	setAnchPos( title_down_l , display.cx , 727 , 0.5 , 0.5 )
	
	this.layer:addChild( title_top_l )
	this.layer:addChild( title )
	this.layer:addChild( title_down_l )


	local tempHight = 0

	if getCidType( _data.cid or _data.npc_id  ) ~= "pet" then
		local baseInfo = {
								"Lv" .. _data["lv"] ,
								"攻:" .. _data["atk"] ,
								"防:" .. _data["def"] ,
								"命:" .. _data["org_hp"] ,
								"速:" .. _data["agi"] ,
							}
							
		for i = 0 , 5 do
			local tempLine  = display.newSprite( PATH .. "line_short.png" )
			setAnchPos( tempLine  , 384 , 672 - 38 * i , 0.5 , 0.5 )
			this.layer:addChild( tempLine )
			
			if baseInfo[i] then
				local tempText = display.strokeLabel( baseInfo[i]  , 335 , 672 - 38 * i  , 24 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 127 , dimensions_height = 30 , align = 0 } )
				this.layer:addChild( tempText )
			end
		end
	
		--当前血量
		local curHp  = display.newSprite( PATH .. "cur_hp.png" )
		setAnchPos( curHp , 390 , 448 , 0.5 , 0.5 )
		this.layer:addChild( curHp )
		local curHpData = { _data.hp }
		for i = 0 , 1 do
			local tempLine  = display.newSprite( PATH .. "line.png" )
			setAnchPos( tempLine  , 384 , 434 - 30 * i , 0.5 , 0.5 )
			this.layer:addChild( tempLine )
			
			if curHpData[i] then
				local tempText = display.strokeLabel( curHpData[i]  , 315 , 430 - 30 * i  , 24 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 145 , dimensions_height = 30 , align = 1 } )
				this.layer:addChild( tempText )
			end
		end
		
		
		
		
		--当前状态
		local existFlag = {	["mabi"]   = "麻痹" ,		
							["zhongdu"]  = "中毒" ,	
							["dongjie"] = "冻结" ,	
							["hunluan"]   = "混乱" ,		
							["huifu"]   = "恢复" ,		
							}
		local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( _data._group , _data._index )
		
		local gatherState = {}
		for key , v in pairs( existFlag ) do
			local targetHeroData = targetHero:getData()[key..""]
			if targetHeroData then
				gatherState[ #gatherState + 1 ] = v
			end
		end
		
		local curState  = display.newSprite( PATH .. "cur_state.png" )
		setAnchPos( curState , 390 , 378 , 0.5 , 0.5 )
		this.layer:addChild( curState )
		for i = 0 , 1 do
			local tempLine  = display.newSprite( PATH .. "line.png" )
			setAnchPos( tempLine  , 384 , 361 - 30 * i , 0.5 , 0.5 )
			this.layer:addChild( tempLine )
			
			if gatherState[i] then
				local tempText = display.strokeLabel( gatherState[i] ,  315 , 357 - 30 * i  , 24 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 145 , dimensions_height = 30 , align = 1 } )
				this.layer:addChild( tempText )
			end
		end
		if #gatherState == 0 then
			local tempText = display.strokeLabel( "正常",  315 , 357 - 30 , 24 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 145 , dimensions_height = 30 , align = 1 } )
			this.layer:addChild( tempText )
		end

		local isNPC = _data.npc_id and true or false --是否是NPC
		if not isNPC then
			--英雄技能处理
			local heroPath = IMG_PATH .. "image/scene/hero/"
			local selfSkillTitleBg = display.newSprite( heroPath .. "skill_type_bg.png")
			local selfSkillTitle   = display.newSprite( heroPath .. "tiansheng.png")
			local otherSkillTitleBg  = display.newSprite( heroPath .. "skill_type_bg.png")
			local otherSkillTitle    = display.newSprite( heroPath .. "xuexi.png")

			setAnchPos(selfSkillTitleBg , 50 , 280 , 0.5 , 0.5 )
			setAnchPos(selfSkillTitle   , 50 , 280 , 0.5 , 0.5 )
			setAnchPos(otherSkillTitleBg , 210 , 280 , 0.5 , 0.5 )
			setAnchPos(otherSkillTitle   , 210 , 280 , 0.5 , 0.5 )

			this.layer:addChild( selfSkillTitleBg )
			this.layer:addChild( selfSkillTitle )
			this.layer:addChild( otherSkillTitleBg )
			this.layer:addChild( otherSkillTitle )
		end	
		
		local tempSkillData = _data.skill
		for i = 1 , 3 do
			local tempData = isNPC and tempSkillData[i] or tempSkillData["s" .. i ]
			
			local tempSkillIcon	
			if 	tempData then
				local params = { 
								front = getImageByType( tempData["cid"] ) , 
								other = { IMG_PATH.."image/scene/incubation/egg_num_bg.png" , 53 , 54 } , 
								text = { tempData.lv , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 32} , nil , 20 }
								}
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame1.png" }, 0 , 0 , params ):getLayer()
			else
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame4.png" }, 0 , 0 ):getLayer()
			end	

			if isNPC then
				setAnchPos(tempSkillIcon , i * 106 - 71 , 240 , 0.5 , 0.5 )	
			else
				setAnchPos(tempSkillIcon , ( i>1 and 100 or  52 ) + i * 106 - 60 , 240 , 0.5 , 0.5 )
			end
			this.layer:addChild( tempSkillIcon )
	
		end
	else

		tempHight = 70
		setAnchPos( roleImage , display.cx , 523 , 0.5 , 0.5 )	

		local petSKillPath = IMG_PATH .. "image/scene/pet/"
		local tiansheng_bg = display.newSprite(  petSKillPath .. "skill_type_bg.png" )
		this.layer:addChild( tiansheng_bg )
		setAnchPos(tiansheng_bg , 78 , 255 )

		local tiansheng = display.newSprite(  petSKillPath .. "tiansheng.png" )
		this.layer:addChild( tiansheng )
		setAnchPos(tiansheng , 98 , 268 )

		local xuexi_bg = display.newSprite(  petSKillPath .. "skill_type_bg.png" )
		this.layer:addChild( xuexi_bg )
		setAnchPos(xuexi_bg , 78 , 160 )

		local xuexi = display.newSprite(  petSKillPath .. "xuexi.png" )
		this.layer:addChild( xuexi )
		setAnchPos(xuexi , 98 , 173 )

		for i = 1 , 3 do
			local zhuData = _data.skills[ "a" .. i]
			local beiData = _data.skills[ "p" .. i]	

			local tempSkillIcon
			--主动技	
			if zhuData then
				local params = { 
								front = getImageByType( zhuData["cid"] ) , 
								other = { IMG_PATH.."image/scene/incubation/egg_num_bg.png" , 53 , 54 } , 
								text = { zhuData.lv , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 32} , nil , 20 }
								}
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame1.png" }, 0 , 0 , params ):getLayer()
			else
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame4.png" }, 0 , 0 ):getLayer()
			end
			setAnchPos(tempSkillIcon , i * 106 + 49 , 258 , 0.5 , 0.5 )	
			this.layer:addChild( tempSkillIcon )

			--被动技
			if 	beiData then
				local params = { 
								front = getImageByType( beiData["cid"] ) , 
								other = { IMG_PATH.."image/scene/incubation/egg_num_bg.png" , 53 , 54 } , 
								text = { beiData.lv , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 32} , nil , 20 }
								}
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame1.png" }, 0 , 0 , params ):getLayer()
			else
				tempSkillIcon = KNBtn:new( SCENECOMMON , { "skill_frame4.png" }, 0 , 0 ):getLayer()
			end	
			setAnchPos(tempSkillIcon , i * 106 + 49 , 164 , 0.5 , 0.5 )
				
			this.layer:addChild( tempSkillIcon )
		end


	end

	--游戏已经暂停
	local stopTip = display.strokeLabel( "游戏已经暂停!" , 100 , 168 - tempHight , 40 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 280 , dimensions_height = 50 , align = 1 } )
	this.layer:addChild( stopTip ) 
	--点击返回，继续战斗
	local stopTip = display.strokeLabel( "点击返回，继续战斗" , 100 , 123 - tempHight, 22 , ccc3( 0xff , 0x80 , 0x2b ) , nil , nil , { dimensions_width = 280 , dimensions_height = 30 , align = 1 } )
	this.layer:addChild( stopTip ) 
	
	local scene = display.getRunningScene()
	local mask
	--返回事件处理
	local function backFun()
		this.layer:removeFromParentAndCleanup( true )
		mask:remove()
		logic:resume("info")
	end
	local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
	mask = KNMask:new({ item = this.layer })
	scene:addChild( mask:getLayer() )
	
	mask:click(backFun)
end

--游戏中 大图展示 
function M:showBigImage( cid , lightType )
	local group = display.newLayer()
	local baseX = 0
	local baseY = 0

	if lightType < 3 then
		-- 背景光影
		local lightEffPath
		if lightType == 1 then
			lightEffPath = IMG_PATH .. "image/scene/newguy/light.png"
		elseif lightType == 2 then
			lightEffPath = IMG_PATH .."image/scene/home/card_light.png"
		end
		
		local light = display.newSprite( lightEffPath )
		
		if lightType == 1 then
			setAnchPos(light , baseX , baseY - 6 , 0.5 , 0.5 )
		elseif lightType == 2 then
			setAnchPos(light , baseX , baseY - 3 , 0.5 , 0.5 )
		end
		
		group:addChild(light)
		
		-- 光影转动动作
		local light_action
		if lightType == 1 then
			light_action = function(angle)
				transition.rotateTo(light , {time = 10 , angle = angle , onComplete = function()
					if angle == 180 then angle = 360 else angle = 180 end
					light_action(angle)
				end})
			end
			light_action(180)
		elseif lightType == 2 then
				function createAction()
					local action
					local array = CCArray:create()
					array:addObject(CCScaleTo:create(1,1.2))
					array:addObject(CCScaleTo:create(1,1.3))
					array:addObject(CCCallFunc:create(
					function()
						light:runAction(createAction())
					end))
					action = CCSequence:create(array)
					return action
				end
	
				light:runAction(createAction())
		end
	end
	
	
	
	-- 卡牌数据
	local cid_type = getCidType(cid)
	local config = getConfig(cid_type , cid)
	
	local bg
	local big_icon
	if config~=nil then
		-- 卡牌背景
		bg = display.newSprite(IMG_PATH .. "image/scene/newguy/card_bg_".. ( config.star~=nil and config.star or 1 ) .. ".png")
		setAnchPos(bg , baseX , baseY , 0.5 , 0.5 )
		group:addChild(bg)
		
		-- 卡牌大图
		local isBig = false
		if cid_type == "npc" then
			if getConfig("npc" , cid , "logo_id") < 18000 then
				isBig = true
			end
		end
		
		if config["special"] == 1 then
			group:addChild( display.newSprite( IMG_PATH.."image/scene/battle/hero_info/special_frame.png" , 0 , 0 , 0.5 , 0.5 ) )
		end
		
		big_icon = display.newSprite(getImageByType(cid , "b"))
		big_icon:setScale( ( cid_type == "npc" and not isBig ) and 1.5 or 1 )
		setAnchPos(big_icon ,  baseX  , baseY - 6 , 0.5 , 0.5)
		group:addChild(big_icon)
		
		if config["name"] then
			local name_bg = display.newSprite(IMG_PATH .. "image/scene/newguy/name_bg_small.png")
			setAnchPos(name_bg , baseX , baseY - 170 , 0.5)
			group:addChild(name_bg)
	
			local show_name = config["name"]
			if cid_type == "general" and config["bieming"] and config["bieming"] ~= "" then
				show_name = "[" .. config["bieming"] .. "]" .. config["name"]
			end
			local name_ttf = CCLabelTTF:create(show_name , FONT , 26)
			setAnchPos(name_ttf , baseX , baseY - 160 , 0.5)
			group:addChild(name_ttf)
		end
		
		-- 卡牌星级
		if config["star"] then
			local star_num = config["star"]
			local star_init_x = -68 + (5 - star_num) * 14
			for i = 1 , star_num do
				local star = display.newSprite(COMMONPATH .. "star.png")
				setAnchPos(star , star_init_x + (i - 1) * 28 , 128)
				group:addChild(star)
			end
		end
	else
		-- 卡牌背景
		bg = display.newSprite(IMG_PATH .. "image/scene/newguy/card_bg_1.png")
		setAnchPos(bg , baseX , baseY , 0.5 , 0.5 )
		group:addChild(bg)
		-- 卡牌大图
		big_icon = display.newSprite(getImageByType(cid , "b"))
		setAnchPos(big_icon , baseX , baseY - 6 , 0.5 , 0.5)
		group:addChild(big_icon)
	end
	return group
end
return M