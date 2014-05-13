--[[

战斗结果

]]


local M = {}
local HeroLayer = requires(IMG_PATH,"GameLuaScript/Scene/hero/herolayer")
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Upgrade = requires(IMG_PATH,"GameLuaScript/Scene/common/upgrade")
local KNShowbylist = requires(IMG_PATH , "GameLuaScript/Common/KNShowbylist")
local KNNumberroll = requires(IMG_PATH,"GameLuaScript/Common/KNNumberroll")
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local KNBar = requires(IMG_PATH , "GameLuaScript/Common/KNBar")
local award_handle = nil		-- 弹出奖励动画的定时器
local card_mask
local result_sprite
local confirmBtn		-- 确定按钮
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

local PATH = IMG_PATH.."image/scene/battle/fruit/"
local WIN_PATH = IMG_PATH.."image/scene/battle/fruit/win/"
local LOST_PATH = IMG_PATH.."image/scene/battle/fruit/lost/"
local TITLE_PATH = WIN_PATH .. "title_win.png"		
local girl		--女孩
local bgFrame	--公用
local addType 	--坐标类型
local resultData

function M:create( params )
	confirmBtn = nil
	addType = 0
	params = params or {}
	
	--强制清除宠物目标选择层
	local scene = display.getRunningScene()
	if scene:getChildByTag("899") then
		local selectMask = scene:getChildByTag("899")
		if selectMask then
			scene:removeChild(selectMask , true)
		end
	end
	
	if DATA_Battle:getMod() == "guide" then
		return M:guide_result()
	end
	
	local fbMode = {
					 inshero  = "十字坡" ,		
					 insequip = "藏宝楼" ,
					 inspet   = "景阳岗" , 	
					 insskill = "如意阁" , 	
					 rob 	  = "夺宝" , 	
					}
	
	--战斗结果数据
	resultData = DATA_Result:get()
	
	--扫荡数据
	if params.type == "mopUp" then
		return M:mission_result( params )
	end
	
	
	-- 数据兼容
	resultData.awards = resultData.awards or {}
	
	if DATA_Battle:get("win") ~= 1 then
		M:warLost()
	else
		if resultData.type == "rob" or  resultData.type == "mining" then
			if resultData.success == 0 then
				M:warLost()
			else
				audio.playMusic( IMG_PATH .. "sound/win.mp3" , false )
			end
		else
			audio.playMusic( IMG_PATH .. "sound/win.mp3" , false )
		end
	end
	
	if fbMode[ resultData.type ] then	--磨练
		return M:instance_result()
	elseif resultData.type == "athletics" then	--竞技
		return M:athletics_result()
	elseif resultData.type == "friends" then	--好友切磋
		return M:friends_result()
	elseif resultData.type == "mining" then		--抢夺矿山
		return M:mining_result()
	else
		TITLE_PATH = WIN_PATH .. "mission_win.png"
		return M:mission_result()		--任务
	end

end

--战斗失败
function M:warLost()
	--数据兼容
	resultData = resultData or {}
	
	audio.playMusic( IMG_PATH .. "sound/lose.mp3" , false )
	
	result_sprite = display.newSprite( LOST_PATH .. "lost_bg.jpg")
	local size = result_sprite:getContentSize()
	
	local baseHeight = 16
	local lostTipPath
	if resultData.type == "athletics" then	lostTipPath = "lost_tip_athletics.png"		--竞技
	elseif resultData.type == "insskill" then lostTipPath = "lost_tip_skill.png"		--如意阁
	elseif resultData.type == "mining" and resultData.success == 0  then lostTipPath = "tip_mine_text.png"		--矿山战斗胜利但已经被别人占领
	else lostTipPath = "lost_tip_text.png"	
	end
	local existMiss = {
				insequip = "insequip" , 
				mission = "mission" , 
				mining = "mining",
	}
	
	
	
	local lostTitle = display.newSprite( LOST_PATH .. ( resultData.type == "rob" and "rob_lost.png" or "lost_title.png" ) )
	bgFrame = display.newSprite( LOST_PATH .. "lost_bg_frame.png")
	girl = display.newSprite( PATH .. "girl.png")
	local girlFace = display.newSprite( LOST_PATH .. "lost_face.jpg")
	local tipText = display.newSprite( LOST_PATH .. lostTipPath )
	local tipTitle = display.newSprite( LOST_PATH .. "tip_title.png")
	
	
	setAnchPos( result_sprite , display.cx - size.width / 2 , display.cy - size.height / 2 )
	setAnchPos( lostTitle , display.cx + 17 , 900 , 0.5 )
	setAnchPos( bgFrame , 20 , display.cy - baseHeight , 0 , 0.5 )
	setAnchPos( girl , 188 , display.cy - 27  , 0 , 0.5 )
	setAnchPos( girlFace , 188 + 131  , display.cy - 27 + 72 , 0 , 0.5 )
	setAnchPos( tipText , 45 , display.cy - baseHeight + 60 , 0 , 0.5 )
	setAnchPos( tipTitle , 45 , display.cy - baseHeight + 6  , 0 , 0.5 )

	result_sprite:addChild( lostTitle )
	result_sprite:addChild( bgFrame )
	result_sprite:addChild( girl )
	result_sprite:addChild( girlFace )
	if existMiss[ resultData.type .. "" ] then
		result_sprite:addChild( tipText )
	end
	result_sprite:addChild( tipTitle )
	
	--去强化
	local goStrengthen = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"} , ( existMiss[ resultData.type .. "" ] and 64 or ( display.cx - 73 ) ), 56 ,
		{
			priority = -150,
			front = LOST_PATH .. ( DATA_User:get("lv") <= 8 and "go_strengthen2.png" or "go_strengthen.png" ) ,
			callback = 
			function()
				if DATA_User:get("lv") <= 8 then
					if DATA_General:haveGet() then
						DATA_Formation:set_index(1)
						pushScene("hero",{gid = DATA_Formation:getCur() , closeFun = function() popScene() end })
					else
						HTTP:call("general" , "get",{},{success_callback =
							function()
								DATA_General:haveGet(true)
								DATA_Formation:set_index(1)
								pushScene("hero",{ gid = DATA_Formation:getCur() , closeFun = function() popScene() end })
							end
						})
					end
				else
					local homeLayer = requires(IMG_PATH,"GameLuaScript/Scene/home/homelayer")
					switchScene( "home" , nil , function() homeLayer:createAide() end ) 
				end
			end
		}):getLayer()
	result_sprite:addChild( goStrengthen )
	--去打造
	if existMiss[ resultData.type .. "" ]  then
		local goForge = KNBtn:new( COMMONPATH , 
			{ "btn_bg_red.png" ,"btn_bg_red_pre.png"} , 275 , 56 ,
			{
				priority = -150,
				front = LOST_PATH ..  ( DATA_User:get("lv") <= 8 and "go_forge2.png" or "go_forge.png" )  ,
				callback = 
				function()
					if DATA_User:get("lv") <= 8 then
						-- 判断等级开放
						local check_result = checkOpened("forge")
						if check_result ~= true then
							KNMsg:getInstance():flashShow(check_result)
							return
						end
						pushScene( "forge" , { closeFun = function() popScene() end })
					else
						KNMsg.getInstance():boxShow( "1：如果游戏前期就遇到了困难，提升玩家等级是提升实力最快的方式\n2：关卡里面的BOSS关卡可以提供大量经验值哦" , { 
																					confirmText = IMG_PATH .. "image/scene/aide/go_mission.png" , 
																					confirmFun = function()
																						if not DATA_Mission:get() then
																							HTTP:call("mission" , "get",{},{success_callback = function()
																								switchScene("mission")
																							end })
																						else
																							switchScene("mission")
																						end
																					end , 
																					cancelFun = function() end 
																					} )	
					end
				end
			}):getLayer()
		result_sprite:addChild( goForge )
	end
	
	
	transition.moveTo( lostTitle , { time = 0.3 , y = 655 , easing  = "BACKOUT" })
	
	if resultData.type == "athletics" then
		local tempText = display.strokeLabel( "+" .. resultData.awards.fame , 45 + 113 , display.cy - baseHeight   , 18 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 200 , dimensions_height = 70 , align = 0 } )
		result_sprite:addChild( tempText )
	end
		local tipStr = ( DATA_User:get("lv") ) and ( getConfig("data_lost")[ math.random( 1 , DATA_User:get("lv") ) .. "" ] or {} ) or {}
	if tipStr.describe then
		tipStr = tipStr.describe
	else
		tipStr = "召唤高星级战将，\n可提升战队的整体实力！"
	end
	if resultData.type == "rob" then
		tipStr = "糟糕，被对手发现，带着物品跑路啦！好可惜，差点就抢夺成功了TAT~"
	end
	local tempText = display.strokeLabel( tipStr , 45 , display.cy - baseHeight - 100  , 18 , resultData.type == "rob" and ccc3( 0x0c , 0xfc , 0xff ) or ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , { dimensions_width = 200 , dimensions_height = 90 , align = 0 } )
	result_sprite:addChild( tempText )
end
--胜利基础
function M:baseWin( params )	
	params = params or {}
	
	local showGirl = params.showGirl
	local showBgFrame = params.showBgFrame
	
	result_sprite = display.newLayer()
	
	local downSp = display.newSprite( WIN_PATH .. "down_bg.jpg")
	local lightBg = display.newSprite(WIN_PATH.."eff.png")
	local topSp = display.newSprite( WIN_PATH .. "top_bg.jpg")
	local centerSp = display.newSprite( WIN_PATH .. "center_bg.jpg")
	
	
	setAnchPos( downSp , display.cx ,  0 , 0.5 , 0 )
	setAnchPos( lightBg , display.cx ,  132 + 524 , 0.5 , 0.5 )
	setAnchPos( centerSp , display.cx ,  132 - 7 , 0.5 , 0 )
	setAnchPos( topSp , display.cx ,  132 + 529  , 0.5 , 0 )
	
	result_sprite:addChild(downSp)
	result_sprite:addChild( topSp )
	result_sprite:addChild(lightBg)
	result_sprite:addChild( centerSp )
	
	lightBg:runAction(CCRepeatForever:create(CCRotateBy:create(1,20)))
	
	local size = result_sprite:getContentSize()
	

	local baseHeight = 16
	local winTitleBg = display.newSprite( WIN_PATH .. "win_title_bg.png" )
	local winTitle = display.newSprite( ( resultData.type == "rob" and WIN_PATH .. "rob_win.png" or  TITLE_PATH ) ) 	--胜利标题
	bgFrame = display.newSprite( WIN_PATH .. "win_bg_frame.png")
	girl = display.newSprite( PATH .. "girl.png")

	
	setAnchPos( result_sprite , 0  , 0 , 0 , 0 )
	setAnchPos( winTitleBg , display.cx , 900 , 0.5 )
	setAnchPos( winTitle , display.cx , 900 , 0.5 , 0 )
	setAnchPos( bgFrame , 20 , display.cy - baseHeight , 0 , 0.5 )
	setAnchPos( girl , 188 , display.cy - 27  , 0 , 0.5 )
	
	
	result_sprite:addChild( winTitleBg )
	result_sprite:addChild( winTitle )
	result_sprite:addChild( bgFrame )
	result_sprite:addChild( girl )
	
	
	girl:setVisible( showGirl )
	bgFrame:setVisible( showBgFrame )
	
	
	local function actionBackFun()
		if resultData.missions then
			local startNum = ( params.type and params.type == "mopUp" ) and resultData.missions[1].star or resultData.missions[resultData.current.mission_id].star
			local i = 0
			local function showStar()
				i = i + 1
				if i > startNum then
					if params.actionFun then  params.actionFun() end 
				else
					local adornStar = display.newSprite( COMMONPATH .. "star.png" )
					setAnchPos( adornStar , ( display.cx - startNum * 18 + i * 37 ) - 18  , 676 , 0.5 , 0.5  )
					result_sprite:addChild( adornStar )
					
					adornStar:setScale(5)
					transition.scaleTo( adornStar , { time = 0.3 , scale = 1 , onComplete = showStar ,  easing  = "BACKOUT"})
				end
			end
			showStar()
		else
			if params.actionFun then  params.actionFun() end 
		end
	end
	
	transition.moveTo( winTitleBg , {time = 0.5 , y = 663 , easing  = "BACKOUT" })
	transition.moveTo( winTitle , {time = 0.5 , y = 684 , easing  = "BACKOUT" , onComplete = actionBackFun })
end


function M:mission_result( params )
--	local json = requires(IMG_PATH , "GameLuaScript/Network/dkjson")
--	local response = io.readfile("c:\\battle8.txt")
--	response = json.decode( response )
--	resultData = response.result
--	
--	resultData.through = {award = "100000体力" , firsttime = 1 ,  brilliant = 1 }		--award 通关奖励	--firsttime 第一次通关	--brilliant 全三星通关
--	resultData._T_lvup = { lv = 2 ,maxlv = 4 }	--主公升级
--	resultData._T_hero_lvup = { ["121"] = "121" ,["94"] = "94" ,["217"] = "217" , ["158"] = "158" , ["156"] = "156" ,["146"] = "146" }	--各个英雄生机
--	
--	resultData._D_bag = resultData._D_bag or {}
--	resultData._D_bag.general = resultData._D_bag.general or {}
--	resultData._D_bag.general[ "121" ] = { cid = "1106" , lv = "2" , exp = 500 ,  cur_exp = 50 , id = 121 }
--	resultData._D_bag.general[ "94" ] = { cid = "1109" , lv = "2" , exp = 500 ,  cur_exp = 50  , id = 94 }
--	resultData._D_bag.general[ "217" ] = { cid = "1117" , lv = "2" , exp = 500 ,  cur_exp = 50 , id = 217 }
--	resultData._D_bag.general[ "158" ] = { cid = "1115" , lv = "2" , exp = 500 ,  cur_exp = 50 , id = 158 }
--	resultData._D_bag.general[ "156" ] = { cid = "1120" , lv = "2" , exp = 500 ,  cur_exp = 50 , id = 156 }
--	resultData._D_bag.general[ "146" ] = { cid = "1110" , lv = "2" , exp = 500 ,  cur_exp = 50 , id = 146 }
--	
--	resultData.awards = resultData.awards or {}						 	
-- 	resultData.awards.exp = resultData.awards.exp or 300
-- 	
-- 	
--	resultData.T_hero_expadd = {
--								["121"] = 20 , 
--								["94"] =  20 , 
--								["217"] = 20 , 
--								["158"] = 20 , 
--								["156"] = 60 , 
--								["146"] = 60 , 
--							 	}
	
	params = params or {}
	local layer = display.newLayer()
	local mask
	
	--战斗输赢
	local win = DATA_Battle:get("win")
	
	--显示确定按钮
	local function showConfirmBtn()
		confirmBtn:getLayer():setVisible(true)
		confirmBtn:setEnable(true)
	end
	--返回事件处理
	local function backFun()
		if award_handle ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(award_handle)
			award_handle = nil
		end
		
		--通关展示
		local function passShow( params )
			params = params or {}
			local showLayer = display.newLayer()
			
			local roleImage = display.newSprite( COMMONPATH .. "guide_logo.png" )
			setAnchPos(roleImage , 24 , display.cy + 30 )
			showLayer:addChild( roleImage )
			
			local bg = display.newSprite(  PATH .. "pass_bg.png" )
			setAnchPos( bg , display.cx , display.cy  , 0.5 , 0.5 )
			showLayer:addChild( bg )
			
			local missionConfig = requires(IMG_PATH, "GameLuaScript/Config/Mission")
			local curMapName = missionConfig[ resultData["current"]["map_id"] .. "" ].map_name
			
			local tipConfig = {
								["10"] = "少侠好身手！通过“" .. curMapName .. "”的考验！感觉您还没到极限，挑战自己的极限吧！会有你意想不到的收获哦！" , 
								["01"] = "少侠你战斗力简直爆表！通过“" .. curMapName .. "”的所有评级都为三星！称雄世界已然不远！" , 
								["11"] = "少侠你已经超神了！首次通过“" .. curMapName .. "”就以全三星的姿态过关！少侠一出谁与争锋啊！" , 
							}
			local tipStr = tipConfig[ resultData.through.firsttime .. resultData.through.brilliant .. "" ]
			local tipText = display.strokeLabel(tipStr , 144, 190 + 150 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , nil , {
							dimensions_width = 280,
							dimensions_height = 120,
							align = 0,})
			showLayer:addChild( tipText )
			
			--奖励图标
			local awardIcon = KNBtn:new( IMG_PATH .. "image/scene/fb/"  , {"item_bg.png"} , 50  , display.cy - 45 , { front =getImageByType( "16005" , "s")  }):getLayer()
			showLayer:addChild( awardIcon )
			
			--奖励名称
			local awardName = display.strokeLabel( resultData.through.award , 43, display.cy - 75 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , nil , {
			dimensions_width = 100,
			dimensions_height = 30,
			align = 1,})
			showLayer:addChild( awardName )
			
			--是否第一次通过
			local tempDelay = 0.4
			if resultData.through.firsttime == 1 then
				local firstFlag = display.newSprite(  PATH .. "pass_flag.png" )
				setAnchPos( firstFlag , 368 , display.cy - 80 , 0.5 , 0.5 )
				showLayer:addChild( firstFlag )
				
				firstFlag:setOpacity(0.3)
				firstFlag:setScale(3)
				transition.fadeIn(firstFlag , { delay = tempDelay ,time = 0})
				transition.scaleTo(firstFlag , { delay = tempDelay , scale = 1, time = 0.4 , easing = "ELASTICOUT" })
				
				tempDelay = 0.8
			end		
			--是否全三星通过		
			if resultData.through.brilliant == 1 then
				local starFlag = display.newSprite(  PATH .. "star_flag.png" )
				setAnchPos( starFlag , 240 , display.cy - 80 , 0.5 , 0.5 )
				showLayer:addChild( starFlag )
				
				
				starFlag:setOpacity(0.3)
				starFlag:setScale(3)
				transition.fadeIn(starFlag , { delay = tempDelay ,time = 0})
				transition.scaleTo(starFlag , { delay = tempDelay , scale = 1, time = 0.4 , easing = "ELASTICOUT" })
			end	
			
			local passMask
			local function clear()
				if showLayer then
					showLayer:removeFromParentAndCleanup(true)
				end
				
				passMask:remove()
				
				if params.passBackFun then params.passBackFun() end
				
			end
			
			passMask = KNMask:new({ item = showLayer , opacity = 200 , click = clear })		
			local scene = display.getRunningScene()
			scene:addChild( passMask:getLayer() )		
		end
		
		local function jumpOutFun()
			if params.backFun then
				params.backFun()	--磨练的藏宝楼同任务结算相同，但返不同
			else
				switchScene(resultData.type.."",{kind = "mission", level = resultData["jump"]["map_id"]})
			end
		end
    
		
		local function passBackFun()
			if getGuideInfo() then
				Upgrade:mainHero( resultData , {backFun = jumpOutFun } )
			else
				jumpOutFun()
			end 
		end
		
				
		if confirmBtn then
			confirmBtn:getLayer():removeFromParentAndCleanup(true)
			confirmBtn = nil
		end

		mask:remove()

		
		if resultData.through and resultData.through.firsttime then--存在通关奖励时
			passShow( { passBackFun = passBackFun })
		else
			passBackFun()
		end
		
	end
	local baseY = 256
	local baseX = 42
	
	
	local isRowBoss
	if params.type == "mopUp" then
		isRowBoss = false
		win = 1
	else
		isRowBoss = tonumber( resultData.cut_num )>0 
	end
	 
	-- 添加战斗背景图片
	if win == 1 then
		local awards = resultData.awards or {}
		
		local function careatTitle( name )
			local titleBg = display.newSprite( WIN_PATH .. "title_bg.png")
			local nameSp = display.newSprite( WIN_PATH .. name .. ".png" )
			titleBg:addChild( nameSp )
			setAnchPos( nameSp , 6 , 0 , 0 , 0 )
			return titleBg
		end
		local actionTime = 0.2
		local function showOther()
			local function showAarad()
				--获得奖励信息
				local function showAwards()
					if awards.drop then
						local cids = {}
						for key , cid in pairs(resultData.awards.drop) do
							cids[#cids + 1] = cid
						end
						if #cids ~= 0 then
							-- 播放获得卡牌的动画
							if params.type == "mopUp" then
								local scroll = KNScrollView:new( 40 , 130 , 400, 170 , 50 , true , nil , { turnBtn = IMG_PATH .. "image/scene/gang/next.png" , turnBtnPriority = -140  } )
								local function mopUpAward( cid )
									local curName = getConfig( getCidType( cid ) ,  cid , "name" ) 
									local star = getConfig( getCidType( cid ) ,  cid , "star" )
									local otherData = {}
									for j = 1 , star do
										otherData[ #otherData + 1 ] = { IMG_PATH .. "image/scene/home/star.png" ,  7 - star * 12 + j * 24  , -27 }
									end
									local isPetskill =( getCidType(cid) == "petskill" )
									local textData = {}
									if isPetskill then
										otherData[ #otherData + 1 ] = {IMG_PATH.."image/scene/bag/kind_bg.png", 0 , 2 }
										textData = { {"兽",16, ccc3(255,255,255), ccp(-20, 23),nil, 17} , { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 } }
									else
										textData = { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 }
									end
									local awardBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , 0 , 0 ,
											{
												front = getImageByType( cid ) ,
												other = otherData , 
												text = textData ,
												callback = function()end,
											}):getLayer()
											
									return awardBtn
								end
					 			
				 				for k = 1 , #cids do
									local item = mopUpAward( cids[k] )
					 				scroll:addChild( item )
				 				end
								scroll:alignCenter()
								result_sprite:addChild(scroll:getLayer() )
								
								showConfirmBtn()
							else
								M:playGetCards(cids , showConfirmBtn )
							end
						else
							showConfirmBtn()
						end
					else
						showConfirmBtn()
					end
				end
			
				--获得奖励标题
				local getPropSp = careatTitle( "get_prop" )
				setAnchPos( getPropSp , 22 , 252 , 0 , 0 )
				result_sprite:addChild( getPropSp )
				transition.moveTo( getPropSp , { time = actionTime , x = 22 } )
				
				-- 触发定时器
				award_handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(award_handle)
					award_handle = nil
					showAwards()
				end , 0.2 , false)
			end
			
			--展示英雄信息
			local function showHero()
				local upStr = nil
				--英雄信息
				if resultData._D_bag and resultData._D_bag.general then
					local onHero = DATA_Formation:get_ON( "on" )
					local backHero = DATA_Formation:get_ON( "back" )
					local allHero = {}	--所有上阵武将id
					for i = 1 , table.nums(onHero) do
						allHero[ #allHero + 1 ] = onHero[i].gid
					end
					for i = 1 , table.nums(backHero) do
						 allHero[ #allHero + 1 ] = backHero[i].gid
					end
					
					local addExp = {}	--英雄添加经验文字
					local showUpFlag = {}
				
					for i = 1 , 8 do
						local index = i - 1
						local addX , addY = 84 + index % 4 * 83 , 408 - math.floor( index / 4 ) * 93 
						if i > #allHero then
							local heroBtn = KNBtn:new( SCENECOMMON , { "skill_frame4.png" } , addX , addY ):getLayer()
							result_sprite:addChild( heroBtn )
						else
							local curData = resultData._D_bag.general[ allHero[i] .. "" ]
							if curData then
								local isUp =  resultData._T_hero_lvup and resultData._T_hero_lvup[ allHero[i].."" ] --当前英雄是否升级
								if not upStr then
									upStr = HeroLayer:coutUpTip( curData.id , true )
								end
								local heroBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , 
									addX , 
									addY ,
									{
										front = getImageByType( curData.cid ) ,
										other = isUp and ( { { COMMONPATH .. "select2.png" , -11 , -10 , -10 } , { COMMONPATH .. "egg_num_bg.png" , 42 , 42 } } ) or { COMMONPATH .. "egg_num_bg.png" , 42 , 42 } , 
										text = { curData.lv , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 21 , y = 20	} , nil , 20 } ,
									})
								result_sprite:addChild( heroBtn:getLayer() )
								
								--升级提示
								showUpFlag[ i .. "" ] = function()
															if isUp then
																local upFlag = display.newSprite( WIN_PATH .. "up_flag.png" )
																setAnchPos( upFlag , heroBtn:getX() + 34 ,heroBtn:getY()  , 0.5 )
																result_sprite:addChild( upFlag )
																
																local function loopPlayUp()
																	setAnchPos( upFlag , heroBtn:getX() + 34 , heroBtn:getY() , 0.5 )
																	local upAction = CCArray:create()
																	upAction:addObject( CCMoveTo:create( 1 , ccp( heroBtn:getX() + 34 , heroBtn:getY() + 40 ) ) )
																	upAction:addObject( CCCallFunc:create( loopPlayUp ) )
																	upFlag:runAction( CCSequence:create( upAction ) )
																end
																loopPlayUp()
															end
														end
								
								
								
								
								addExp[ i .. "" ] = display.strokeLabel( "+" .. resultData.T_hero_expadd[ curData.id .. "" ] , heroBtn:getX() - 3 , heroBtn:getY() , 18 , ccc3( 0x53 , 0xff , 0x15 ) , nil , nil , {
									dimensions_width = 70 ,
									dimensions_height = 20,
									align = 1
								})
								
								local expBar = KNBar:new("exp1" , addX , 454 + math.floor( index / 4 ) * 90 , { 
																			maxValue = curData.exp , 
																			curValue = 0 , 
																			color = ccc3(0x2c , 0x00 , 0x01 ) ,
																			actionTime = 0.5 , 
																			} )
								expBar:setIsShowText( false )
								expBar:setCurValue( curData.cur_exp , true )
								result_sprite:addChild( expBar )
							end
						end
					end
						local shadeMask = display.newSprite( PATH .. "exp_shade.png")
						setAnchPos( shadeMask , display.cx , display.cy - 33 , 0.5 , 0.5)
						result_sprite:addChild( shadeMask )
						
						local function clearShadeMask()
							shadeMask:removeFromParentAndCleanup(true)
							
--							local getUpgrad = {}--收集没有获得正常经验值的英雄名字
--							local isUpgrad = false
--							for key , v in pairs(resultData.T_hero_expadd) do
--								if  v < resultData.awards.exp then
--									isUpgrad = true
--									local cruData = resultData._D_bag.general[key .. ""]
--									getUpgrad[ #getUpgrad + 1 ] =  getConfig( getCidType(cruData.cid) , cruData.cid , "name" )
--								end 
--							end
--							
--							if isUpgrad then
--								local getherName = string.join(getUpgrad, ",")
--								local upgradTip = display.strokeLabel( "有英雄达到等级上限，需进化英雄或提升主角等级" , 40 , 10 , 18 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil , {
--									dimensions_width = 400 ,
--									dimensions_height = 50,
--									align = 1
--								})
--								result_sprite:addChild( upgradTip )
--							end
							
							local tipsText = display.strokeLabel( "每个英雄获得经验：+" .. resultData.awards.exp  , 0 ,275 , 18 , ccc3( 0x07 , 0xff , 0xfc ) , nil , nil , {
									dimensions_width = 480 ,
									dimensions_height = 30,
									align = 1
								})
							result_sprite:addChild( tipsText )
							
							for key , v in pairs(showUpFlag) do
								v()
							end
							
							showAarad()
							
						end
						local tempCount = 0
						for key , v in pairs(addExp) do
							tempCount = tempCount + 1
							local isLast = tempCount >= table.nums( addExp )
							result_sprite:addChild( v )
							
							transition.moveTo( v , { time = 1.5 , y = 40 , onComplete = 
																		function()
																			v:removeFromParentAndCleanup(true)
																			if isLast then
																				clearShadeMask()
																			end
																		end	})
						
						end
				end
				if upStr then
					result_sprite:addChild(  display.strokeLabel( upStr , 40 , 10 , 18 , ccc3( 0x5c , 0xe3 , 0xe5 ) , nil , nil , {
									dimensions_width = 400 ,
									dimensions_height = 50,
									align = 0
								}) )
				end
			end
			
			
			
			
			
			
			
			--生成主公信息
			local function showMan()
				local function createMan()
					local manLayer = display.newLayer()
					
					local expBar = KNBar:new("exp" , 121 , 297 , { 
																	maxValue = DATA_User:get("lvup_exp") , 
																	curValue = 0 , 
																	color = ccc3(0x2c , 0x00 , 0x01 ) ,
																	actionTime = 0.5 , 
																	} )
					expBar:setCurValue( DATA_User:get("cur_exp") , true )
					manLayer:addChild( expBar )
					
					local isManUp = resultData._T_lvup and tonumber( resultData._T_lvup.lv ) ~= 0	--主公是否升级
					local tempTable 
					if isManUp  then
						tempTable = {  
										{ IMG_PATH.."image/scene/common/navigation/level_bg.png" , -17 , 54 } ,
										{ COMMONPATH .. "select2.png" , -11 , -10 , -10 } , 
									}
					else
						tempTable = { IMG_PATH.."image/scene/common/navigation/level_bg.png" , -17 , 54 }
					end
					
					local manImage = KNBtn:new( COMMONPATH , { "sex".. DATA_User:get("sex") .. ".jpg" } , 
						display.cx - 174 , 
						display.cy + 98 ,
						{
							front = COMMONPATH.."role_frame.png" ,
							other = tempTable , 
							text = { DATA_User:get("lv") , 18 , ccc3( 0xbf , 0x3a , 0x01 ) , { x = -33 , y = 34	} , nil , 20 } ,
							callback = function()
							end
						}):getLayer()
					manLayer:addChild( manImage )
					
					--主公升级动画
					if isManUp then
						local upFlag = display.newSprite( WIN_PATH .. "up_flag.png" )
						setAnchPos( upFlag , 34 , 0 , 0.5    )
						manImage:addChild( upFlag , 10)
						
						local function loopPlayUp()
							setAnchPos( upFlag , 34 , 0 , 0.5 )
							local upAction = CCArray:create()
							upAction:addObject( CCMoveTo:create( 1 , ccp( 30 , 40) ) )
							upAction:addObject( CCCallFunc:create( loopPlayUp ) )
							upFlag:runAction( CCSequence:create( upAction ) )
						end
						loopPlayUp()
					end
					
					local manName= display.strokeLabel( DATA_User:get("name") , 152 , 576 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) )
					manLayer:addChild( manName )
					
					return manLayer
				end
				
				--生成宠物图像
				local function createPet()
					local petLayer = display.newLayer()
					
					
					local petData , addExp
					for key , v in pairs(resultData._T_pet_expadd) do
						petData = DATA_Bag:get("pet" , key )
						addExp = v
					end
					local lv , cur_exp , max_exp = DATA_Pet:calcExp(petData.exp)
					petData.lv = lv
					petData.cur_exp = cur_exp
					petData.max_exp = max_exp
					
					local isManUp = resultData._T_pet_lvup	--宠物是否升级
					
					local manImage = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } ,  
						373 , 528 ,
						{
							front = getImageByType( petData.cid ) ,
							other = isManUp and ( { { COMMONPATH .. "select2.png" , -11 , -10 , -10 } , { COMMONPATH .. "egg_num_bg.png" , 42 , 42 } } ) or { COMMONPATH .. "egg_num_bg.png" , 42 , 42 } , 
							text = { petData.lv , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 21 , y = 20	} , nil , 20 } ,
							callback = function()
							end
						})
					petLayer:addChild( manImage:getLayer() )
					
					local expBar = KNBar:new("exp1" , 372 , 335 , { 
																maxValue = petData.exp , 
																curValue = 0 , 
																color = ccc3(0x2c , 0x00 , 0x01 ) ,
																actionTime = 0.5 , 
																} )
					expBar:setIsShowText( false )
					expBar:setCurValue( petData.cur_exp , true )
					result_sprite:addChild( expBar )
					
					local expText = display.strokeLabel( "+" .. addExp , manImage:getX() - 3 , manImage:getY() , 18 , ccc3( 0x53 , 0xff , 0x15 ) , nil , nil , {
						dimensions_width = 70 ,
						dimensions_height = 20,
						align = 1
					})
					result_sprite:addChild( expText , 20 )
					transition.moveTo( expText , { delay = 0.2 , time = 1.5 , y = expText.y + 45 , onComplete = function() 
						expText:removeFromParentAndCleanup( true ) 
						expText = nil
						--宠物升级动画
						if isManUp then
							local upFlag = display.newSprite( WIN_PATH .. "up_flag.png" )
							setAnchPos( upFlag , 34 , 0 , 0.5    )
							manImage:getLayer():addChild( upFlag , 10)
							
							local function loopPlayUp()
								setAnchPos( upFlag , 34 , 0 , 0.5 )
								local upAction = CCArray:create()
								upAction:addObject( CCMoveTo:create( 1 , ccp( 30 , 40) ) )
								upAction:addObject( CCCallFunc:create( loopPlayUp ) )
								upFlag:runAction( CCSequence:create( upAction ) )
							end
							loopPlayUp()
						end
						
					end })
					
					result_sprite:addChild( petLayer )
				end
				result_sprite:addChild( createMan() )
				if resultData._T_pet_expadd then  createPet() end
					
			
				if awards.silver then
					--获得银两
					local silverSp = display.newSprite( COMMONPATH .. "silver.png" )
					setAnchPos( silverSp , 256 , 519 , 0 , 0 )
					result_sprite:addChild( silverSp )
					
					local silverNum = display.strokeLabel( "+" .. awards.silver , 288 , 523 , 18 , ccc3( 0x53 , 0xff , 0x15 ) , nil , nil , {
						dimensions_width = 100 ,
						dimensions_height = 20 ,
						align = 0
						} )
					result_sprite:addChild( silverNum )
					
					local prestigeNum = display.strokeLabel( "EXP:+" .. ( awards.prestige or 0 ), 150 , 523 , 18 , ccc3( 0x53 , 0xff , 0x15 ) , nil , nil , {
						dimensions_width = 100 ,
						dimensions_height = 20 ,
						align = 0
						} )
					result_sprite:addChild( prestigeNum )
				end
				
				--展示英雄数据
				local heroSp = careatTitle( "hero" )
				setAnchPos( heroSp , -50 , 486 , 0 , 0 )
				result_sprite:addChild( heroSp )
				transition.moveTo( heroSp , { delay = 0.2 , time = actionTime , x = 22 , onComplete = showHero } )
			end
			
			
			isRowBoss = false
			
			--主公标题
			local manSp = careatTitle( "man" )
			setAnchPos( manSp , -50 , 609 , 0 , 0 )
			result_sprite:addChild( manSp )
			transition.moveTo( manSp , { time = actionTime , x = 22 , onComplete =  showMan } )
		end
		
		
		
		
		
		local rowBossLayer 
		--切Boss奖励展示
		local function rowBossAward()
			rowBossLayer = display.newLayer()
			
			local function createProp( cid , num )
				local textData = num and { "+" .. num , 20 , ccc3( 0x3a , 0xe0 , 0x02 ) , { x = 55 , y = 0	} , nil , 20 } or nil
				local awardBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , 0 , 0 ,
				{
					front = getImageByType( cid ) ,
					text = textData
				}):getLayer()
				return awardBtn
			end
		 	local ROW_PATH = WIN_PATH .. "row/"
		 	--展示切牌掉落的道具奖励
		 	local function showAwardFun()
		 		if resultData.cut.drop then
				 	local rowBossTitle = careatTitle( "row_award" )
					setAnchPos( rowBossTitle , -50 , 323 , 0 , 0 )
					rowBossLayer:addChild( rowBossTitle )
					transition.moveTo( rowBossTitle , { time = actionTime , x = 22  } )
					
					
					local function createAward( cid , num )
						local textData = num and {num , 20 , ccc3( 0xff , 0xff , 0xff ) , { x = 21 , y = -21	} , nil , 20 } or nil
						local awardBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , 0 , 0 ,
						{
							front = getImageByType( cid ) ,
							text = textData , 
							other = { COMMONPATH .. "egg_num_bg.png" , 42 , 0 }
						}):getLayer()
						return awardBtn
					end
					
		 			local cids = {}
		 			
					local scroll = KNScrollView:new( 70 , 150 , 340, 160 , 10 , false   )
					local tempCutDrop = {}
					for cutKey , cutV in pairs(resultData.cut.drop)do
						tempCutDrop[#tempCutDrop + 1] =  { cid = cutKey , num = cutV }
					end
		 			for t = 1 , math.ceil(#tempCutDrop/4) do
		 				cids[#cids + 1] = { [1] = tempCutDrop[t*4-3] , [2] = tempCutDrop[t*4 - 2 ] ,[3] = tempCutDrop[t*4-1] , [4] = tempCutDrop[t*4] }
		 			end
		 			
		 			for t = 1 , #cids do
	 					local tempLayer = display.newLayer()
	 					tempLayer:setContentSize( CCSizeMake( 340 , 70 ) )
		 				for k = 1 , #cids[t] do
							local item = createAward( cids[t][k].cid , cids[t][k].num )
							setAnchPos( item , ( k - 1 ) * 90 , 0 , 0 , 0  )
							tempLayer:addChild(item)
		 				end
		 				scroll:addChild( tempLayer )
		 			end
					scroll:alignCenter()
					rowBossLayer:addChild(scroll:getLayer() )
					
					showConfirmBtn()
		 		else
		 			showConfirmBtn()
		 		end
		 	end
		 	--展示切boss得到的银币和金币
		 	local function showAwardSilver()
				
		 		resultData.cut = resultData.cut or {}
		 		if resultData.cut.silver or resultData.cut.gold then
				 	local rowBossTitle = careatTitle( "silver_title" )
					setAnchPos( rowBossTitle , -50 , 440 , 0 , 0 )
					rowBossLayer:addChild( rowBossTitle )
					transition.moveTo( rowBossTitle , { time = actionTime , x = 22 , onComplete =  showAwardFun } )
					
					local moneyIndex = 0
					if resultData.cut.silver then
						local silver = createProp( "silver" , resultData.cut.silver , moneyIndex )
						rowBossLayer:addChild( silver )
						local addX , addY = 75 + moneyIndex * 170 , 359
						setAnchPos( silver , addX , addY )
						moneyIndex = moneyIndex + 1
					end
					if resultData.cut.gold then
						local gold = createProp( "gold" , resultData.cut.gold , moneyIndex )
						rowBossLayer:addChild( gold )
						local addX , addY = 75 + moneyIndex * 170 , 359
						setAnchPos( gold , addX , addY )
						moneyIndex = moneyIndex + 1
					end

		 		else
		 			showAwardFun()
		 		end
		 	end
		 	
		 	local rowBossTitle = careatTitle( "row_boss_num" )
			setAnchPos( rowBossTitle , -50 , 609 , 0 , 0 )
			rowBossLayer:addChild( rowBossTitle )
			transition.moveTo( rowBossTitle , { time = actionTime , x = 22 , onComplete =
			function()
				local rowNumBg = display.newSprite( ROW_PATH .. "row_num_bg.png" )
				setAnchPos(rowNumBg , display.cx , 541 , 0.5 , 0.5)
				rowBossLayer:addChild(rowNumBg)
				
				local rowNum = getImageNum( resultData.cut_num , ROW_PATH.."num.png" , { decimals = true })
				setAnchPos(rowNum , display.cx , 541 , 0.5 , 0.5)
				rowBossLayer:addChild(rowNum)
				rowNum:setScale(5)
				transition.scaleTo( rowNum , { time = 0.3 , scale = 1 , onComplete = showStar ,  easing  = "BACKOUT" , onComplete =  showAwardSilver })
			end } )
			
			
			result_sprite:addChild( rowBossLayer )
		end
		--背景图
		M:baseWin({ type = params.type == "mopUp" and "mopUp" or nil , actionFun = isRowBoss and rowBossAward or showOther , showGirl = false , showBgFrame = false })
		
		-- 确定按钮
		confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, display.cx - 146 / 2 , 65 , 
							{ 
								priority = -132 , 
								scale = true , 
								front = COMMONPATH.."confirm.png" , 
								callback = 
								function()
									if isRowBoss then
										local function clearRowBoss()
											rowBossLayer:removeFromParentAndCleanup(true)
											showOther()
										end
										transition.moveTo(rowBossLayer , {time = 0.5 , x = - 480 ,onComplete = clearRowBoss })
									else
										backFun()
									end  
								end 
							} )
		confirmBtn:getLayer():setVisible(false)
		confirmBtn:setEnable(false)
		result_sprite:addChild( confirmBtn:getLayer() )
		
		mask = KNMask:new( { item = result_sprite } )
	else
		-- 失败  点击返回首页
		mask = KNMask:new( { item = result_sprite } )
		if params.backFun then
			mask:click( params.backFun )	--磨练的藏宝楼同任务结算相同，但返不同
		else
			mask:click(backFun)
		end
	end

	
	layer:addChild( mask:getLayer() )
	
    return layer
end



--副本结算
function M:instance_result()
	local fbLayer = requires(IMG_PATH,"GameLuaScript/Scene/fb/fblayer")
	local fbMode = {
				 inshero  = "hero" ,		
				 inspet   = "pet", 	
				 insskill = "skill" , 	
				 insequip = "equip" ,
				 rob      = "rob" ,
				}
	local layer = display.newLayer()
	
	local mask
	
	--战斗输赢
	local win = DATA_Battle:get("win")
	if resultData.success == 0 then win = 0 end

	--返回事件处理
	local function backFun()
		if award_handle ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(award_handle)
			award_handle = nil
		end
		
		local function jumpOutFun()
			if resultData.type == "rob" then
					HTTP:call("rob", "get", {},
								{ 
									success_callback =
									 function(data)
										switchScene( "pvp" , { state = fbMode[resultData.type] , robData = data , star = resultData.star } )
									end
								})
			else
				local func, dig
				if resultData.type == "insequip" then
					if win == 1 then
						if resultData.get.ins_id == 25 and resultData.get.current_map == DATA_Instance:get("equip", "max", "map_id") then 
							dig = true
							if resultData.get.current_map == 6 then
								KNMsg.getInstance():flashShow("恭喜您已通关藏宝楼所有副本！~")
							else
								func  = function()
									KNMsg.getInstance():flashShow("恭喜通关藏宝楼第"..resultData.get.current_map.."层，第"..(resultData.get.current_map + 1).."层已开启")
								end
							end
						elseif resultData.get["ins_id"] == 25 then
							dig = true
						end
					end
				end	
				switchScene( "fb" , { state = fbMode[resultData.type], coming = true, map =  resultData.get.current_map, dig = dig } , func)
			end
		end
    
		
		if resultData._T_hero_lvup or ( resultData._T_lvup and tonumber( resultData._T_lvup.lv ) ~= 0 ) or  getGuideInfo() then
			if resultData.type ~= "insequip" then mask:remove() end
			Upgrade:mainHero( resultData , { backFun = jumpOutFun} )
		else
			if resultData.type ~= "insequip" and resultData.type ~= "rob" then 
				mask:remove() 
			end
			jumpOutFun()
		end 
	end
	
	--藏宝楼结算 同任务
	if resultData.type == "insequip" then
		return M:mission_result( { backFun = backFun } )
	end
	
	local baseY = 256
	local baseX = 42
	-- 添加战斗背景图片
	if win == 1 and ( resultData.type == "insskill" or resultData.type == "rob" )then
		addType = 1
		--不存在英雄锦囊
		--背景图
		M:baseWin({ actionFun = showOther , showGirl = true , showBgFrame = true })
		
		
		--奖励功勋
		local getSkillTitle = display.newSprite( WIN_PATH .. ( resultData.type ~= "rob" and "get_skill.png" or "get_text.png" ) )
		setAnchPos( getSkillTitle , 70 , 475 , 0 , 0.5 )
		result_sprite:addChild( getSkillTitle )

		--确定按钮
		confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png","btn_bg_red_pre.png" }, display.cx - 146 / 2 , 50 , { priority = -132 , scale = true , front = COMMONPATH.."confirm.png" , callback = backFun } )
		layer:addChild( confirmBtn:getLayer() , 2 )

		confirmBtn:getLayer():setVisible(false)
		confirmBtn:setEnable(false)


		local awards = resultData.awards or {}
		--获得奖励信息
		local function showAwards()
			--显示确定按钮
			local function showConfirmBtn()
				confirmBtn:getLayer():setVisible(true)
				confirmBtn:setEnable(true)
			end
			if awards.drop and table.nums(awards.drop) ~= 0 then
				local function mopUpAward( cid , num )
					local robElement = {
										soul_1 = { name = "一星将魂" , star = 1 , path = IMG_PATH .. "image/scene/forge/general_icon_1.png" } ,
										soul_2 = { name = "二星将魂" , star = 2 , path = IMG_PATH .. "image/scene/forge/general_icon_2.png" } ,
										chip_1 = { name = "一星碎片" , star = 1 , path = IMG_PATH .. "image/scene/forge/equip_icon_1.png" } ,
										chip_2 = { name = "二星碎片" , star = 2 , path = IMG_PATH .. "image/scene/forge/equip_icon_2.png" } ,}
					
					local num = num or 0
					local curName , star
					local otherData , textData
					if robElement[ cid ] then
						curName = robElement[ cid ].name
						star = robElement[ cid ].star
						
						otherData = {}
						for j = 1 , star do
							otherData[ #otherData + 1 ] = { IMG_PATH .. "image/scene/home/star.png" ,  7 - star * 12 + j * 24  , -27 }
						end
						textData = { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 }
					else
						curName = getConfig( getCidType( cid ) ,  cid , "name" ) 
						star = getConfig( getCidType( cid ) ,  cid , "star" )
					
						otherData = {}
						for j = 1 , star do
							otherData[ #otherData + 1 ] = { IMG_PATH .. "image/scene/home/star.png" ,  7 - star * 12 + j * 24  , -27 }
						end
						if num > 1 then
							otherData[ star+1 ] = { COMMONPATH .. "egg_num_bg.png" , 53 , 54 } 
						end
						
						local isPetskill =( getCidType(cid) == "petskill" )
						textData = {}
						if isPetskill then
							otherData[ #otherData + 1 ] = {IMG_PATH.."image/scene/bag/kind_bg.png", 0 , 2 }
							textData = { {"兽",16, ccc3(255,255,255), ccp(-20, 23),nil, 17} , { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 } , ( (num > 1) and { num , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 32} , nil , 20 } or nil ) }
						else
							textData = ( num > 1) and {{ curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 } , { num , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 32} , nil , 20 } } or { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 }
						end
					end
					
					local awardBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , 0 , 0 ,
							{
								front =  ( robElement[ cid ] and robElement[ cid ].path or getImageByType( cid ) ) ,
								other = otherData , 
								text = textData ,
								callback = function()end,
							}):getLayer()
					return awardBtn
				end
				for key , v in pairs(awards.drop) do
					local tempAward = resultData.type == "rob" and mopUpAward( v , 0 )  or mopUpAward( key , v ) 
					setAnchPos(tempAward , 110 , 378 )
					result_sprite:addChild( tempAward )
				end
				showConfirmBtn()
			else
				showConfirmBtn()
			end
		end

		-- 触发定时器
		award_handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(award_handle)
			award_handle = nil
			showAwards()
		end , 0.2 , false)
	else
		-- 失败  点击返回首页
		mask = KNMask:new({ item = result_sprite })
		mask:click(backFun)
		layer:addChild( mask:getLayer() )
		return layer
	end
	

	
	mask = KNMask:new({ item = result_sprite })
	layer:addChild( mask:getLayer() )
	

    return layer
end





--竞技结算页面
function M:athletics_result()
	local layer = display.newLayer()
	local mask

	--战斗输赢
	local win = DATA_Battle:get("win")
	
	--返回事件处理
	local function backFun()
		if resultData._T_lvup and tonumber( resultData._T_lvup.lv ) ~= 0 then
			mask:remove()
			Upgrade:new( resultData._T_lvup , { backFun = function() switchScene( "athletics" , {data = resultData["data"], challenge = true } ) end } )
		else
			switchScene("athletics",{data = resultData["data"], challenge = true})
		end 
	end
	
	if win == 1 then
		M:baseWin({ showGirl = true , showBgFrame = true })
		
		--奖励功勋
		local athleticsAwardText = display.newSprite( WIN_PATH .. "get_silver.png" )
		setAnchPos( athleticsAwardText , 70 , 445 , 0 , 0.5 )
		result_sprite:addChild( athleticsAwardText )
		--奖励功勋数量
		local fameT = display.strokeLabel("+" .. ( resultData.awards.silver or 0 )   , 0, 0 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 85 , dimensions_height = 30 , align = 0 } )
		setAnchPos( fameT , 227 , 442 , 0.5 , 0.5 )
		result_sprite:addChild( fameT )
		
		--连胜次数
		local  winning_streak_text = display.newSprite( WIN_PATH .. "winning_streak.png" )
		setAnchPos( winning_streak_text , 70 , 373 , 0 , 0.5 )
		result_sprite:addChild( winning_streak_text )
		
		--连胜次数
		local winning_streak_num = display.strokeLabel( ( resultData.my.successionwin or 0 ) , 0, 0 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 85 , dimensions_height = 30 , align = 0 } )
		setAnchPos( winning_streak_num , 180 , 368 , 0.5 , 0.5 )
		result_sprite:addChild( winning_streak_num )
	
		
	
		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		
		--确定按钮
		confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, display.cx - 146 / 2 , 50  , { priority = -132 , scale = true , front = COMMONPATH.."confirm.png" , callback = backFun } )
		layer:addChild( confirmBtn:getLayer() , 2 )
	else
		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		-- 失败  点击返回首页
		mask:click(backFun)
	end

    return layer
end
--好友切磋复仇结算页面
function M:friends_result()
	local layer = display.newLayer()
	local mask

	--战斗输赢
	local win = DATA_Battle:get("win")
	--返回事件处理
	local function backFun()
		switchScene( "friend" , { activity = resultData["data"] } )
	end
	
	if win == 1 then
		M:baseWin({ showGirl = true , showBgFrame = true })
		
		if resultData.action == 1 then			--切磋
			if resultData.awards and resultData.awards.silver then		--有奖励则提示
				local athleticsAwardText = display.newSprite( WIN_PATH .. "get_silver.png" )
				setAnchPos( athleticsAwardText , 70 , 445 , 0 , 0.5 )
				result_sprite:addChild( athleticsAwardText )
				--奖励功勋数量
				local fameT = display.strokeLabel("+" .. ( resultData.awards.silver or 0 )   , 0, 0 , 20 , ccc3( 0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 85 , dimensions_height = 30 , align = 0 } )
				setAnchPos( fameT , 227 , 442 , 0.5 , 0.5 )
				result_sprite:addChild( fameT )
			else
				result_sprite:addChild( display.newSprite( WIN_PATH .. "compare_notes.png" ,  52 , 390 , 0 , 0 ) )
			end
		elseif resultData.action == 2 then		--复仇
			result_sprite:addChild( display.newSprite( WIN_PATH .. "revenge.png" ,  52 , 390 , 0 , 0 ) )
		end

		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		
		--确定按钮
		confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, display.cx - 146 / 2 , 50  , { priority = -132 , scale = true , front = COMMONPATH.."confirm.png" , callback = backFun } )
		layer:addChild( confirmBtn:getLayer() , 2 )
	else
		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		-- 失败  点击返回首页
		mask:click(backFun)
	end

    return layer
end
--矿山结算页面
function M:mining_result()
	local layer = display.newLayer()
	local mask

	--战斗输赢
	local win = DATA_Battle:get("win")
	if resultData.success == 0 then win = 0 end
	
	--返回事件处理
	local function backFun()
		switchScene( "diggings" ,resultData.data)
	end
	
	if win == 1 then
		M:baseWin({ showGirl = true , showBgFrame = true })
		
		result_sprite:addChild( display.newSprite( WIN_PATH .. "mine.png" ,  52 , 390 , 0 , 0 ) )

		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		
		--确定按钮
		confirmBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, display.cx - 146 / 2 , 50  , { priority = -132 , scale = true , front = COMMONPATH.."confirm.png" , callback = backFun } )
		layer:addChild( confirmBtn:getLayer() , 2 )
	else
		mask = KNMask:new({ item = result_sprite })
		layer:addChild( mask:getLayer() )
		-- 失败  点击返回首页
		mask:click(backFun)
	end

    return layer
end



--演示战斗
function M:guide_result()

	local layer = display.newLayer()
	local mask
	
	local function backFun()
		local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
		if logic:getParams().resultCallFun then
			logic:getParams().resultCallFun()
		end
	end
	
	--战斗失败
	M:warLost()
	
	mask = KNMask:new({ item = result_sprite })
	layer:addChild( mask:getLayer() )
	
	mask:click(backFun)

    return layer
end


--[[播放卡牌获得动画]]
function M:playGetCards(cids , backFun , params )
	params = params or {}
	local scene = display.getRunningScene()

	card_mask = KNMask:new({priority = -133})
	scene:addChild(card_mask:getLayer() , 100)

	local callback
	callback = function(index)
		local next_index = index + 1
		if cids[next_index] then
			M:playOneCard(cids[next_index] , next_index , callback , params )
		else
			scene:removeChild(card_mask:getLayer() , true)

			if backFun then
				backFun()
			end
		end
	end
	
	
	M:playOneCard(cids[1] , 1 , callback , params )
end

function M:playOneCard(cid , index , callback , params )
	local curLayer = params.parentLayer or result_sprite
	local tempData = DATA_Result:get().awards or {}
	if tempData.dropkit then
		M:popOneCard( cid , index , callback)
	else
		local baseX = 42
		local baseY = 256
	
		local card_x = baseX + 49 + (index - 1) * 74
		local card_y = baseY - 153
		
		
		
		local curName = getConfig( getCidType( cid ) ,  cid , "name" ) 
		local star = getConfig( getCidType( cid ) ,  cid , "star" )
		local otherData = {}
		for j = 1 , star do
			otherData[ #otherData + 1 ] = { IMG_PATH .. "image/scene/home/star.png" ,  7 - star * 12 + j * 24  , -27 }
		end
		local isPetskill =( getCidType(cid) == "petskill" )
		local textData = {}
		if isPetskill then
			otherData[ #otherData + 1 ] = {IMG_PATH.."image/scene/bag/kind_bg.png", 0 , 2 }
			textData = { {"兽",16, ccc3(255,255,255), ccp(-20, 23),nil, 17} , { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 } }
		else
			textData = { curName , 18 , ccc3( 0xfe , 0xfc , 0xd3 ) , { x = 1 , y = -70	} , nil , 20 }
		end
		
		local addX
		local addY
		if addType == 0 	then addX = 80 + ( index - 1 ) * 130 addY = 180
		elseif addType == 1	then addX = 100 addY = 373
		elseif addType == 2	then addX = 70 + ( index - 1 ) % 4 * 90 addY = 245 - math.floor(( index - 1 )/4)*85
		end
		
		
		local awardBtn = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , addX , addY ,
				{
					front = getImageByType( cid ) ,
					other = addType ~= 2 and otherData or nil , 
					text = addType ~= 2 and textData or nil ,
					callback = function()end,
				}):getLayer()

		curLayer:addChild( awardBtn )
		
		
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
	
			M:popOneCard(cid , index , callback)
		end , 0.22 , false)
	end
end

function M:popOneCard(cid , index , callback)
	local baseX = 42
	local baseY = 189
	local card_x = ( addType == 0 and 80 or 100) + ( index - 1 ) * 130 
	local card_y = ( addType == 0 and 189 or 373)

	local top_tips = nil
	local tempData = DATA_Result:get().awards
	if tempData.dropkit then
		top_tips = display.newLayer()
		
		
		local roleImageBg = display.newSprite( IMG_PATH .. "image/scene/common/box.png")
		setAnchPos(roleImageBg , 50 , -14 )
		
		local roleImage = display.newSprite( getImageByType(logic:getfoeAgent() , "s"))
		setAnchPos(roleImage , 53 , -5 )
		
		--击败文字
		local talkText = display.newSprite( PATH .. "talk_text.png" )
		setAnchPos(talkText , 127, -15)
		
		--威望
		local prestigeText = display.newSprite( IMG_PATH .. "image/scene/battle/result/prestige.png" )
		setAnchPos(prestigeText , 53 , -400)
		
		--经验
		local expText = display.newSprite( IMG_PATH .. "image/scene/battle/result/exp.png" )
		setAnchPos(expText , 186 , -400)
		
		--银两
		local silverText = display.newSprite( IMG_PATH .. "image/scene/battle/result/silver.png" )
		setAnchPos(silverText , 53 , -430)
		
		
		
		local expT = display.strokeLabel("+" .. ( tempData.exp or 0 ) , 236, -410 , 16 , ccc3( 0xff , 0xff , 0xff ) , nil , nil , { dimensions_width = 85 , dimensions_height = 30 , align = 0 } )
		local prestigeT = display.strokeLabel( "+" .. ( tempData.prestige or 0 ) , 106 , -410 , 16 , ccc3( 0xff , 0xff , 0xff ) , nil , nil , { dimensions_width = 85 , dimensions_height = 30 , align = 0 } )
		local silverT = display.strokeLabel(  "+" ..  ( tempData.silver or 0 ) , 106, -430 , 16 , ccc3( 0xff , 0xff , 0xff ) , nil , nil , { dimensions_width = 85 , dimensions_height = 20 , align = 0 } )
		
		top_tips:addChild(expT)
		top_tips:addChild(prestigeT)
		top_tips:addChild(silverT)
		
--		local cid_type = getCidType(cid)
--		local config = getConfig(cid_type , cid)
--		local top_tips_label = CCLabelTTF:create(config["name"] , FONT , 30)
--		top_tips_label:setColor( ccc3( 0xff , 0xfb , 0xd4 ) )
--		setAnchPos(top_tips_label , 190 , 0 , 0.5)
--	
--		function top_tips:setOpacity(opacity)
--			top_tips_sprite:setOpacity(opacity)
--			top_tips_label:setOpacity(opacity)
--		end
--		top_tips:addChild(top_tips_label)
		setAnchPos(top_tips , 60 , 720)
		
		top_tips:addChild(roleImageBg)
		top_tips:addChild(roleImage)
		
		top_tips:addChild(talkText)
		top_tips:addChild(expText)
		
		top_tips:addChild(prestigeText)
		top_tips:addChild(silverText)
	end


	local card_popup = KNCardpopup:new(cid , function()
		callback(index)
	end , {
		init_x = card_x - 196,
		init_y = card_y - 211,
		end_x = card_x - 196,
		end_y = card_y - 211 - 230 ,
		top_tips = top_tips,
	})


	card_mask:getLayer():addChild( card_popup:play() )
end

return M
